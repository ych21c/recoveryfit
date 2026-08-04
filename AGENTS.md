# AI Team Manager — RecoveryFit

## 프로젝트 개요
RecoveryFit용 AI 팀 매니저 파이프라인. PM → 아키텍트 → 디자이너 → 개발자 순서로 AI 에이전트가 단계별 산출물을 생성한다.

## 파이프라인 패키지 (`pipeline/`)

| 파일 | 역할 |
|------|------|
| `models.py` | `Stage`, `StageStatus`, `StageResult`, `PipelineState` 데이터 모델 |
| `executor.py` | 단일 단계 실행 + 지수 백오프 재시도 (`StageExecutor`) |
| `pipeline.py` | 전체 파이프라인 오케스트레이션 (`Pipeline`) |
| `state.py` | 파이프라인 상태 JSON 영속화 (`StateStore`) |
| `stages.py` | 4개 단계(pm/architect/designer/developer) 기본 정의 |
| `llm.py` | OpenAI API 호출 래퍼 (`OPENAI_API_KEY` 환경변수 필요) |
| `cli.py` | `run` / `retry` / `status` CLI 명령 |

## 단계 재시도 설계

- **재시도 트리거**: `Pipeline.retry_stage(stage_name)` 호출 시 해당 단계의 이전 결과를 초기화하고 재실행
- **자동 재시도**: `StageExecutor.run()`이 `max_retries` 횟수만큼 실패 시 자동 재시도 (1 초기 실행 + max_retries 재시도)
- **지수 백오프**: `base_delay * 2^(attempt-1)`, 최대 60초로 상한
- **상태 저장**: 각 단계 실행 후 `.pipeline_state/{project_id}.json`에 자동 저장

## CLI 사용법

```bash
# 전체 파이프라인 실행 (완료된 단계 건너뜀)
python -m pipeline --project c052dd6b run

# 특정 단계부터 재실행
python -m pipeline --project c052dd6b run --from-stage architect

# 단계 재시도 (단독)
python -m pipeline --project c052dd6b retry --stage architect

# 단계 재시도 후 이후 단계 이어서 실행
python -m pipeline --project c052dd6b retry --stage architect --continue

# 현재 상태 확인
python -m pipeline --project c052dd6b status
```

## 테스트

```bash
python -m pytest tests/test_retry.py -v
```

- `sleep_fn` 주입으로 실제 대기 없이 재시도 로직 테스트
- 21개 테스트 모두 통과 확인

## 기존 산출물 파일

- `pm_output.md` — PM 단계 산출물 (요구사항/PRD)
- `architect_output.md` — 아키텍트 단계 산출물 (기술 스택/API 명세)
- `designer_output.md` — 디자이너 단계 산출물 (UX 설계)
- 두 파일 모두 내용이 잘려 있음 → 해당 단계 재시도로 재생성 필요
