from __future__ import annotations

import time
from dataclasses import dataclass, field
from enum import Enum
from typing import Any, Callable


class StageStatus(str, Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"


@dataclass
class StageResult:
    status: StageStatus
    output: Any = None
    error: str | None = None
    attempt: int = 1
    started_at: float = field(default_factory=time.time)
    finished_at: float | None = None

    @property
    def duration(self) -> float | None:
        if self.finished_at is None:
            return None
        return self.finished_at - self.started_at

    def to_dict(self) -> dict:
        return {
            "status": self.status.value,
            "output": self.output,
            "error": self.error,
            "attempt": self.attempt,
            "started_at": self.started_at,
            "finished_at": self.finished_at,
        }

    @classmethod
    def from_dict(cls, data: dict) -> "StageResult":
        return cls(
            status=StageStatus(data["status"]),
            output=data.get("output"),
            error=data.get("error"),
            attempt=data.get("attempt", 1),
            started_at=data.get("started_at", 0.0),
            finished_at=data.get("finished_at"),
        )


@dataclass
class Stage:
    """Pipeline stage definition."""

    name: str
    description: str
    handler: Callable[[str], Any]
    max_retries: int = 3
    retry_delay: float = 2.0  # base delay in seconds (used with exponential backoff)

    def __repr__(self) -> str:
        return f"Stage(name={self.name!r}, max_retries={self.max_retries})"


@dataclass
class PipelineState:
    """Persisted state for the entire pipeline run."""

    project_id: str
    stage_results: dict[str, StageResult] = field(default_factory=dict)

    def get_status(self, stage_name: str) -> StageStatus:
        result = self.stage_results.get(stage_name)
        return result.status if result else StageStatus.PENDING

    def set_result(self, stage_name: str, result: StageResult) -> None:
        self.stage_results[stage_name] = result

    def is_completed(self, stage_name: str) -> bool:
        return self.get_status(stage_name) == StageStatus.COMPLETED

    def to_dict(self) -> dict:
        return {
            "project_id": self.project_id,
            "stage_results": {
                name: result.to_dict()
                for name, result in self.stage_results.items()
            },
        }

    @classmethod
    def from_dict(cls, data: dict) -> "PipelineState":
        state = cls(project_id=data["project_id"])
        for name, result_data in data.get("stage_results", {}).items():
            state.stage_results[name] = StageResult.from_dict(result_data)
        return state
