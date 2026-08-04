"""Command-line interface for the AI Team Manager pipeline.

Commands
--------
run     Run the full pipeline (skip completed stages).
retry   Retry a specific stage, then continue the rest of the pipeline.
status  Print the current status of every stage.

Examples
--------
::

    python -m pipeline run --project c052dd6b
    python -m pipeline retry --project c052dd6b --stage architect
    python -m pipeline status --project c052dd6b
"""

from __future__ import annotations

import argparse
import logging
import sys
from pathlib import Path

from .pipeline import Pipeline, StageNotFoundError
from .stages import default_stages
from .state import StateStore


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="pipeline",
        description="AI Team Manager — pipeline runner",
    )
    parser.add_argument(
        "--project",
        required=True,
        metavar="PROJECT_ID",
        help="Unique project identifier (e.g. c052dd6b)",
    )
    parser.add_argument(
        "--state-dir",
        default=".pipeline_state",
        metavar="DIR",
        help="Directory for persisted pipeline state (default: .pipeline_state)",
    )
    parser.add_argument(
        "--log-level",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR"],
        help="Logging verbosity (default: INFO)",
    )

    sub = parser.add_subparsers(dest="command", required=True)

    # run
    run_p = sub.add_parser("run", help="Run the full pipeline")
    run_p.add_argument(
        "--from-stage",
        metavar="STAGE",
        default=None,
        help="Start from this stage (inclusive), skipping earlier stages",
    )

    # retry
    retry_p = sub.add_parser("retry", help="Retry a specific stage")
    retry_p.add_argument(
        "--stage",
        required=True,
        metavar="STAGE",
        help="Stage name to retry (e.g. pm, architect, designer, developer)",
    )
    retry_p.add_argument(
        "--continue",
        dest="continue_pipeline",
        action="store_true",
        default=False,
        help="After retrying the stage, continue running subsequent stages",
    )

    # status
    sub.add_parser("status", help="Print current status of all stages")

    return parser


def _make_pipeline(project_id: str, state_dir: str) -> Pipeline:
    return Pipeline(
        project_id=project_id,
        stages=default_stages(),
        store=StateStore(Path(state_dir)),
    )


def main(argv: list[str] | None = None) -> int:
    parser = _build_parser()
    args = parser.parse_args(argv)

    logging.basicConfig(
        level=args.log_level,
        format="%(asctime)s %(levelname)-8s %(message)s",
        datefmt="%H:%M:%S",
    )

    pipeline = _make_pipeline(args.project, args.state_dir)

    try:
        if args.command == "run":
            pipeline.run(from_stage=args.from_stage)

        elif args.command == "retry":
            pipeline.retry_stage(args.stage)
            if args.continue_pipeline:
                # Find index after retried stage and continue from the next one
                stages = pipeline.stages
                idx = next(i for i, s in enumerate(stages) if s.name == args.stage)
                next_stage = stages[idx + 1].name if idx + 1 < len(stages) else None
                if next_stage:
                    pipeline.run(from_stage=next_stage)

        elif args.command == "status":
            pass  # summary printed below

    except StageNotFoundError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1

    _print_summary(pipeline)
    return 0


def _print_summary(pipeline: Pipeline) -> None:
    print()
    print(f"Pipeline: {pipeline.project_id}")
    print("-" * 40)
    for stage_name, status in pipeline.status_summary().items():
        icon = {"completed": "✓", "failed": "✗", "running": "⟳", "pending": "·"}.get(
            status, "?"
        )
        print(f"  {icon} {stage_name:<15} {status}")
    print()
