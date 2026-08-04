from __future__ import annotations

import logging
from typing import Sequence

from .executor import StageExecutor
from .models import PipelineState, Stage, StageStatus
from .state import StateStore

logger = logging.getLogger(__name__)


class StageNotFoundError(Exception):
    pass


class Pipeline:
    """Orchestrates sequential stage execution with per-stage retry support.

    Usage
    -----
    Run the full pipeline (skip already-completed stages)::

        pipeline.run()

    Retry a specific stage regardless of its current status::

        pipeline.retry_stage("architect")

    Re-run from a specific stage onward::

        pipeline.run(from_stage="architect")
    """

    def __init__(
        self,
        project_id: str,
        stages: Sequence[Stage],
        *,
        store: StateStore | None = None,
        executor: StageExecutor | None = None,
    ) -> None:
        self.project_id = project_id
        self.stages: list[Stage] = list(stages)
        self._store = store or StateStore()
        self._executor = executor or StageExecutor()
        self._state = self._store.load(project_id)

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    @property
    def state(self) -> PipelineState:
        return self._state

    def run(self, from_stage: str | None = None) -> PipelineState:
        """Run stages in order.

        Args:
            from_stage: If given, start execution from this stage name
                        (inclusive), skipping earlier stages.
        """
        start_idx = 0
        if from_stage is not None:
            start_idx = self._index_of(from_stage)

        for stage in self.stages[start_idx:]:
            if self._state.is_completed(stage.name):
                logger.info("[%s] already completed — skipping", stage.name)
                continue
            self._execute_stage(stage)
            if not self._state.is_completed(stage.name):
                logger.error(
                    "[%s] stage failed after all retries — stopping pipeline",
                    stage.name,
                )
                break

        return self._state

    def retry_stage(self, stage_name: str) -> PipelineState:
        """Force-retry a single stage, resetting its previous result.

        Downstream stages that depend on this stage's output are NOT
        automatically invalidated — callers should decide whether to
        run the full pipeline afterward.

        Args:
            stage_name: The ``Stage.name`` to retry.

        Raises:
            StageNotFoundError: If ``stage_name`` is not registered.
        """
        idx = self._index_of(stage_name)
        stage = self.stages[idx]

        logger.info("[%s] retrying stage (resetting previous result)", stage.name)
        # Clear previous result so the executor records a fresh one
        self._state.stage_results.pop(stage.name, None)
        self._execute_stage(stage)
        return self._state

    def status_summary(self) -> dict[str, str]:
        """Return a mapping of stage name → status string."""
        summary: dict[str, str] = {}
        for stage in self.stages:
            summary[stage.name] = self._state.get_status(stage.name).value
        return summary

    # ------------------------------------------------------------------
    # Internal helpers
    # ------------------------------------------------------------------

    def _index_of(self, stage_name: str) -> int:
        for i, stage in enumerate(self.stages):
            if stage.name == stage_name:
                return i
        names = [s.name for s in self.stages]
        raise StageNotFoundError(
            f"Stage {stage_name!r} not found. Available stages: {names}"
        )

    def _execute_stage(self, stage: Stage) -> None:
        result = self._executor.run(stage, self.project_id)
        self._state.set_result(stage.name, result)
        self._store.save(self._state)
        if result.status == StageStatus.COMPLETED:
            logger.info(
                "[%s] completed in %.2fs (attempt %d)",
                stage.name,
                result.duration or 0.0,
                result.attempt,
            )
        else:
            logger.error(
                "[%s] failed after %d attempt(s): %s",
                stage.name,
                result.attempt,
                result.error,
            )
