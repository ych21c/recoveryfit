"""Tests for the step-retry pipeline feature."""

from __future__ import annotations

import json
import tempfile
from pathlib import Path
from unittest.mock import MagicMock, call

import pytest

from pipeline.executor import StageExecutor, _backoff_delay
from pipeline.models import PipelineState, Stage, StageStatus
from pipeline.pipeline import Pipeline, StageNotFoundError
from pipeline.state import StateStore


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _no_sleep(seconds: float) -> None:  # noqa: ARG001
    """Drop-in for time.sleep that does nothing."""


def _make_stage(
    name: str,
    handler,
    max_retries: int = 2,
    retry_delay: float = 0.0,
) -> Stage:
    return Stage(
        name=name,
        description=f"Test stage {name}",
        handler=handler,
        max_retries=max_retries,
        retry_delay=retry_delay,
    )


def _make_pipeline(stages, state_dir: Path) -> Pipeline:
    return Pipeline(
        project_id="test-project",
        stages=stages,
        store=StateStore(state_dir),
        executor=StageExecutor(sleep_fn=_no_sleep),
    )


# ---------------------------------------------------------------------------
# _backoff_delay
# ---------------------------------------------------------------------------

class TestBackoffDelay:
    def test_first_attempt_equals_base(self):
        assert _backoff_delay(2.0, 1) == 2.0

    def test_doubles_each_attempt(self):
        assert _backoff_delay(2.0, 2) == 4.0
        assert _backoff_delay(2.0, 3) == 8.0

    def test_caps_at_max_delay(self):
        assert _backoff_delay(2.0, 10, max_delay=30.0) == 30.0


# ---------------------------------------------------------------------------
# StageExecutor
# ---------------------------------------------------------------------------

class TestStageExecutor:
    def test_succeeds_on_first_attempt(self):
        handler = MagicMock(return_value="output-data")
        stage = _make_stage("s1", handler)
        executor = StageExecutor(sleep_fn=_no_sleep)

        result = executor.run(stage, "proj")

        assert result.status == StageStatus.COMPLETED
        assert result.output == "output-data"
        assert result.attempt == 1
        handler.assert_called_once_with("proj")

    def test_retries_on_failure_and_succeeds(self):
        handler = MagicMock(side_effect=[ValueError("oops"), "ok"])
        stage = _make_stage("s2", handler, max_retries=2)
        executor = StageExecutor(sleep_fn=_no_sleep)

        result = executor.run(stage, "proj")

        assert result.status == StageStatus.COMPLETED
        assert result.attempt == 2
        assert handler.call_count == 2

    def test_exhausts_retries_returns_failed(self):
        handler = MagicMock(side_effect=RuntimeError("always fails"))
        stage = _make_stage("s3", handler, max_retries=2)
        executor = StageExecutor(sleep_fn=_no_sleep)

        result = executor.run(stage, "proj")

        assert result.status == StageStatus.FAILED
        assert "always fails" in result.error
        # 1 initial + 2 retries = 3 total calls
        assert handler.call_count == 3

    def test_sleep_called_between_retries(self):
        sleep_mock = MagicMock()
        handler = MagicMock(side_effect=[ValueError("fail"), "ok"])
        stage = _make_stage("s4", handler, max_retries=2, retry_delay=3.0)
        executor = StageExecutor(sleep_fn=sleep_mock)

        executor.run(stage, "proj")

        # One sleep call (before the second attempt)
        sleep_mock.assert_called_once_with(3.0)  # base * 2^(1-1) = 3.0

    def test_no_sleep_on_last_attempt(self):
        sleep_mock = MagicMock()
        handler = MagicMock(side_effect=ValueError("always fails"))
        stage = _make_stage("s5", handler, max_retries=1)
        executor = StageExecutor(sleep_fn=sleep_mock)

        executor.run(stage, "proj")

        # 1 initial + 1 retry = 2 attempts; sleep before retry but NOT after last
        assert sleep_mock.call_count == 1

    def test_result_has_duration(self):
        handler = MagicMock(return_value="done")
        stage = _make_stage("s6", handler)
        executor = StageExecutor(sleep_fn=_no_sleep)

        result = executor.run(stage, "proj")

        assert result.duration is not None
        assert result.duration >= 0.0


# ---------------------------------------------------------------------------
# Pipeline.run
# ---------------------------------------------------------------------------

class TestPipelineRun:
    def test_runs_all_stages(self, tmp_path):
        order = []
        stages = [
            _make_stage("pm", lambda pid: order.append("pm") or "pm-out"),
            _make_stage("arch", lambda pid: order.append("arch") or "arch-out"),
        ]
        pipeline = _make_pipeline(stages, tmp_path)

        state = pipeline.run()

        assert order == ["pm", "arch"]
        assert state.is_completed("pm")
        assert state.is_completed("arch")

    def test_skips_already_completed_stage(self, tmp_path):
        handler = MagicMock(return_value="output")
        stages = [_make_stage("pm", handler)]
        pipeline = _make_pipeline(stages, tmp_path)

        # Complete once
        pipeline.run()
        first_call_count = handler.call_count

        # Run again — should skip
        pipeline.run()

        assert handler.call_count == first_call_count

    def test_stops_at_failed_stage(self, tmp_path):
        second_called = []
        stages = [
            _make_stage("pm", MagicMock(side_effect=RuntimeError("fail")), max_retries=0),
            _make_stage("arch", lambda pid: second_called.append(True)),
        ]
        pipeline = _make_pipeline(stages, tmp_path)

        pipeline.run()

        assert pipeline.state.get_status("pm") == StageStatus.FAILED
        assert second_called == []  # not reached

    def test_from_stage_skips_earlier_stages(self, tmp_path):
        pm_handler = MagicMock(return_value="pm-out")
        arch_handler = MagicMock(return_value="arch-out")
        stages = [
            _make_stage("pm", pm_handler),
            _make_stage("arch", arch_handler),
        ]
        pipeline = _make_pipeline(stages, tmp_path)

        pipeline.run(from_stage="arch")

        pm_handler.assert_not_called()
        arch_handler.assert_called_once()


# ---------------------------------------------------------------------------
# Pipeline.retry_stage
# ---------------------------------------------------------------------------

class TestPipelineRetryStage:
    def test_retry_reruns_failed_stage(self, tmp_path):
        attempts = []
        def flaky(pid):
            attempts.append(1)
            if len(attempts) == 1:
                raise ValueError("first run fails")
            return "recovered"

        stages = [_make_stage("pm", flaky, max_retries=0)]
        pipeline = _make_pipeline(stages, tmp_path)

        pipeline.run()
        assert pipeline.state.get_status("pm") == StageStatus.FAILED

        pipeline.retry_stage("pm")
        assert pipeline.state.get_status("pm") == StageStatus.COMPLETED

    def test_retry_resets_completed_stage(self, tmp_path):
        call_count = [0]
        def handler(pid):
            call_count[0] += 1
            return f"output-{call_count[0]}"

        stages = [_make_stage("pm", handler)]
        pipeline = _make_pipeline(stages, tmp_path)

        pipeline.run()
        assert pipeline.state.stage_results["pm"].output == "output-1"

        pipeline.retry_stage("pm")
        assert pipeline.state.stage_results["pm"].output == "output-2"

    def test_retry_unknown_stage_raises(self, tmp_path):
        stages = [_make_stage("pm", lambda pid: "ok")]
        pipeline = _make_pipeline(stages, tmp_path)

        with pytest.raises(StageNotFoundError, match="nonexistent"):
            pipeline.retry_stage("nonexistent")

    def test_retry_does_not_affect_other_stages(self, tmp_path):
        arch_handler = MagicMock(return_value="arch-out")
        stages = [
            _make_stage("pm", lambda pid: "pm-out"),
            _make_stage("arch", arch_handler),
        ]
        pipeline = _make_pipeline(stages, tmp_path)
        pipeline.run()

        arch_call_count_before = arch_handler.call_count

        pipeline.retry_stage("pm")

        # Retrying pm should NOT re-run arch
        assert arch_handler.call_count == arch_call_count_before


# ---------------------------------------------------------------------------
# State persistence
# ---------------------------------------------------------------------------

class TestStatePersistence:
    def test_state_saved_after_each_stage(self, tmp_path):
        stages = [_make_stage("pm", lambda pid: "pm-out")]
        pipeline = _make_pipeline(stages, tmp_path)

        pipeline.run()

        state_file = tmp_path / "test-project.json"
        assert state_file.exists()
        data = json.loads(state_file.read_text())
        assert data["stage_results"]["pm"]["status"] == "completed"

    def test_state_loaded_on_pipeline_init(self, tmp_path):
        stages = [_make_stage("pm", MagicMock(return_value="pm-out"))]

        pipeline1 = _make_pipeline(stages, tmp_path)
        pipeline1.run()

        # New pipeline instance reads persisted state
        pipeline2 = _make_pipeline(stages, tmp_path)
        assert pipeline2.state.is_completed("pm")

    def test_failed_state_persisted(self, tmp_path):
        stages = [
            _make_stage("pm", MagicMock(side_effect=RuntimeError("fail")), max_retries=0)
        ]
        pipeline = _make_pipeline(stages, tmp_path)
        pipeline.run()

        pipeline2 = _make_pipeline(stages, tmp_path)
        assert pipeline2.state.get_status("pm") == StageStatus.FAILED


# ---------------------------------------------------------------------------
# StageResult serialization
# ---------------------------------------------------------------------------

class TestStageResultSerialization:
    def test_roundtrip(self):
        from pipeline.models import StageResult

        original = StageResult(
            status=StageStatus.COMPLETED,
            output={"key": "value"},
            attempt=2,
            started_at=1000.0,
            finished_at=1005.0,
        )
        restored = StageResult.from_dict(original.to_dict())

        assert restored.status == original.status
        assert restored.output == original.output
        assert restored.attempt == original.attempt
        assert restored.duration == pytest.approx(5.0)
