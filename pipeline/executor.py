from __future__ import annotations

import logging
import time

from .models import Stage, StageResult, StageStatus

logger = logging.getLogger(__name__)


def _backoff_delay(base: float, attempt: int, max_delay: float = 60.0) -> float:
    """Exponential backoff: base * 2^(attempt-1), capped at max_delay."""
    return min(base * (2 ** (attempt - 1)), max_delay)


class StageExecutor:
    """Executes a single stage with configurable retry-on-failure."""

    def __init__(self, *, sleep_fn=time.sleep) -> None:
        # sleep_fn is injectable for testing
        self._sleep = sleep_fn

    def run(self, stage: Stage, project_id: str) -> StageResult:
        """Run stage, retrying up to stage.max_retries times on failure.

        Attempts:  1 (initial) + max_retries retries
        Backoff:   exponential starting from stage.retry_delay seconds
        """
        last_error: str = ""

        for attempt in range(1, stage.max_retries + 2):
            result = StageResult(
                status=StageStatus.RUNNING,
                attempt=attempt,
                started_at=time.time(),
            )
            logger.info(
                "[%s] attempt %d/%d starting",
                stage.name,
                attempt,
                stage.max_retries + 1,
            )

            try:
                output = stage.handler(project_id)
                result.status = StageStatus.COMPLETED
                result.output = output
                result.finished_at = time.time()
                logger.info("[%s] attempt %d succeeded", stage.name, attempt)
                return result

            except Exception as exc:  # noqa: BLE001
                last_error = str(exc)
                result.status = StageStatus.FAILED
                result.error = last_error
                result.finished_at = time.time()
                logger.warning(
                    "[%s] attempt %d failed: %s", stage.name, attempt, last_error
                )

                is_last = attempt == stage.max_retries + 1
                if not is_last:
                    delay = _backoff_delay(stage.retry_delay, attempt)
                    logger.info(
                        "[%s] waiting %.1fs before retry %d/%d",
                        stage.name,
                        delay,
                        attempt + 1,
                        stage.max_retries + 1,
                    )
                    self._sleep(delay)

        # All attempts exhausted
        return StageResult(
            status=StageStatus.FAILED,
            error=last_error,
            attempt=stage.max_retries + 1,
            started_at=result.started_at,
            finished_at=result.finished_at,
        )
