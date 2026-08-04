"""Default stage definitions for the AI Team Manager pipeline.

Each handler receives the project_id and returns the generated output
(typically a markdown string that is also written to disk).
"""

from __future__ import annotations

import os
from pathlib import Path
from typing import Any

from .models import Stage


def _write_output(filename: str, content: str, project_root: Path = Path(".")) -> str:
    """Write stage output to a markdown file and return the content."""
    output_path = project_root / filename
    output_path.write_text(content, encoding="utf-8")
    return content


# ---------------------------------------------------------------------------
# Handler factories
# ---------------------------------------------------------------------------

def make_pm_handler(project_root: Path = Path(".")) -> Any:
    def handler(project_id: str) -> str:
        from .llm import generate_pm_output  # noqa: PLC0415 — lazy import
        content = generate_pm_output(project_id)
        return _write_output("pm_output.md", content, project_root)
    return handler


def make_architect_handler(project_root: Path = Path(".")) -> Any:
    def handler(project_id: str) -> str:
        from .llm import generate_architect_output  # noqa: PLC0415
        content = generate_architect_output(project_id)
        return _write_output("architect_output.md", content, project_root)
    return handler


def make_designer_handler(project_root: Path = Path(".")) -> Any:
    def handler(project_id: str) -> str:
        from .llm import generate_designer_output  # noqa: PLC0415
        content = generate_designer_output(project_id)
        return _write_output("designer_output.md", content, project_root)
    return handler


def make_developer_handler(project_root: Path = Path(".")) -> Any:
    def handler(project_id: str) -> str:
        from .llm import generate_developer_output  # noqa: PLC0415
        content = generate_developer_output(project_id)
        return _write_output("developer_output.md", content, project_root)
    return handler


# ---------------------------------------------------------------------------
# Default stage list
# ---------------------------------------------------------------------------

def default_stages(project_root: Path = Path(".")) -> list[Stage]:
    """Return the ordered stage list for the AI Team Manager pipeline."""
    return [
        Stage(
            name="pm",
            description="Product Manager: requirements & PRD generation",
            handler=make_pm_handler(project_root),
            max_retries=3,
            retry_delay=2.0,
        ),
        Stage(
            name="architect",
            description="Software Architect: tech stack & API design",
            handler=make_architect_handler(project_root),
            max_retries=3,
            retry_delay=2.0,
        ),
        Stage(
            name="designer",
            description="UX Designer: screen specs & user flows",
            handler=make_designer_handler(project_root),
            max_retries=3,
            retry_delay=2.0,
        ),
        Stage(
            name="developer",
            description="Developer: code implementation",
            handler=make_developer_handler(project_root),
            max_retries=3,
            retry_delay=5.0,
        ),
    ]
