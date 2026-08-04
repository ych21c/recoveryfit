from __future__ import annotations

import json
import logging
import os
from pathlib import Path

from .models import PipelineState

logger = logging.getLogger(__name__)

_DEFAULT_STATE_DIR = Path(".pipeline_state")


class StateStore:
    """Persists PipelineState as a JSON file on disk."""

    def __init__(self, state_dir: Path | str = _DEFAULT_STATE_DIR) -> None:
        self._dir = Path(state_dir)

    def _path(self, project_id: str) -> Path:
        return self._dir / f"{project_id}.json"

    def load(self, project_id: str) -> PipelineState:
        path = self._path(project_id)
        if path.exists():
            with path.open("r", encoding="utf-8") as fh:
                data = json.load(fh)
            logger.debug("Loaded pipeline state from %s", path)
            return PipelineState.from_dict(data)
        return PipelineState(project_id=project_id)

    def save(self, state: PipelineState) -> None:
        self._dir.mkdir(parents=True, exist_ok=True)
        path = self._path(state.project_id)
        with path.open("w", encoding="utf-8") as fh:
            json.dump(state.to_dict(), fh, indent=2, ensure_ascii=False)
        logger.debug("Saved pipeline state to %s", path)
