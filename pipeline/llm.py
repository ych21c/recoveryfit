"""LLM call wrappers for each pipeline stage.

Reads OPENAI_API_KEY from the environment.  Each function constructs a
role-specific system prompt and returns the raw model output as a string.
"""

from __future__ import annotations

import os
from typing import Any


def _chat(system: str, user: str, model: str = "gpt-4o-mini") -> str:
    """Send a single chat completion request and return the response text."""
    try:
        import openai  # noqa: PLC0415
    except ImportError as exc:
        raise RuntimeError(
            "openai package is required: pip install openai"
        ) from exc

    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        raise RuntimeError("OPENAI_API_KEY environment variable is not set")

    client = openai.OpenAI(api_key=api_key)
    response = client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
    )
    return response.choices[0].message.content or ""


# ---------------------------------------------------------------------------
# Per-stage generators
# ---------------------------------------------------------------------------

_PM_SYSTEM = """\
You are a senior Product Manager. Given a project ID, produce a comprehensive
Product Requirements Document (PRD) in Korean, formatted as Markdown.
Include: executive summary, feature requirements (P0/P1/P2), acceptance
criteria, and success metrics.
"""

_ARCHITECT_SYSTEM = """\
You are a senior Software Architect. Given a project ID and its PM output,
produce a full technical architecture document in Korean, formatted as Markdown.
Include: tech stack decisions, API specification (OpenAPI-style), data models,
deployment architecture, and security considerations.
"""

_DESIGNER_SYSTEM = """\
You are a senior UX Designer. Given a project ID and its PM output,
produce a comprehensive UX design specification in Korean, formatted as Markdown.
Include: design principles, user flows, screen wireframes (ASCII art), component
specs, and accessibility guidelines.
"""

_DEVELOPER_SYSTEM = """\
You are a senior Full-Stack Developer. Given a project ID and its architecture
and design documents, produce the initial implementation plan and scaffolding
code in Korean/English, formatted as Markdown.
Include: directory structure, key file contents, and step-by-step setup guide.
"""


def generate_pm_output(project_id: str) -> str:
    return _chat(
        system=_PM_SYSTEM,
        user=f"Project ID: {project_id}\nGenerate the PRD now.",
        model="gpt-4o-mini",
    )


def generate_architect_output(project_id: str) -> str:
    return _chat(
        system=_ARCHITECT_SYSTEM,
        user=f"Project ID: {project_id}\nGenerate the architecture document now.",
        model="gpt-4o-mini",
    )


def generate_designer_output(project_id: str) -> str:
    return _chat(
        system=_DESIGNER_SYSTEM,
        user=f"Project ID: {project_id}\nGenerate the UX design specification now.",
        model="gpt-4o-mini",
    )


def generate_developer_output(project_id: str) -> str:
    return _chat(
        system=_DEVELOPER_SYSTEM,
        user=f"Project ID: {project_id}\nGenerate the implementation plan now.",
        model="gpt-4o-mini",
    )
