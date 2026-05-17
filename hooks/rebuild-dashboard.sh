#!/usr/bin/env bash
#
# AI Company - 대시보드 데이터 재생성
#
# events.jsonl을 처음부터 읽어 .ai-company/dashboard/data.json을 완전히 재생성한다.
# 또한 오늘 날짜의 .ai-company/chronicles/daily/YYYY-MM-DD.md 칸반 스냅샷을 갱신한다.

set -u

CHRONICLES_DIR=".ai-company/chronicles"
DASHBOARD_DIR=".ai-company/dashboard"
EVENTS_FILE="$CHRONICLES_DIR/events.jsonl"
DATA_FILE="$DASHBOARD_DIR/data.json"
TODAY=$(date +%Y-%m-%d)
DAILY_FILE="$CHRONICLES_DIR/daily/${TODAY}.md"

if [ ! -f "$EVENTS_FILE" ]; then
  echo "events.jsonl이 없습니다." >&2
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "⚠️ jq가 설치되어 있지 않아 대시보드 재생성을 건너뜁니다." >&2
  exit 0
fi

mkdir -p "$DASHBOARD_DIR" "$CHRONICLES_DIR/daily"

# 모든 이벤트를 배열로 묶기
ALL_EVENTS=$(jq -s '.' "$EVENTS_FILE" 2>/dev/null || echo "[]")

# 작업 상태 집계 (task_created → task_started → task_completed/task_blocked)
TASKS=$(echo "$ALL_EVENTS" | jq '[
  group_by(.payload.task_id // .payload.id // "no-id")[]
  | select(.[0].payload.task_id != null or .[0].payload.id != null)
  | {
      id: (.[0].payload.task_id // .[0].payload.id),
      title: (max_by(.payload.title // "") | .payload.title // "untitled"),
      assigned_to: (max_by(.payload.assigned_to // "") | .payload.assigned_to // "unassigned"),
      dependencies: (max_by(.payload.dependencies // []) | .payload.dependencies // []),
      status: (
        if any(.event_type == "task_completed") then "completed"
        elif any(.event_type == "task_blocked") then "blocked"
        elif any(.event_type == "task_started") then "in_progress"
        else "pending"
        end
      ),
      created_at: (map(select(.event_type == "task_created")) | first | .timestamp // null),
      started_at: (map(select(.event_type == "task_started")) | first | .timestamp // null),
      completed_at: (map(select(.event_type == "task_completed")) | first | .timestamp // null),
      day: (map(.timestamp) | first | split("T")[0])
    }
]' 2>/dev/null || echo "[]")

# 회의 집계
MEETINGS=$(echo "$ALL_EVENTS" | jq '[
  .[] | select(.event_type == "meeting_concluded" or .event_type == "consensus_reached")
  | {
      id: (.payload.id // "meeting-?"),
      topic: (.payload.topic // .payload.decision // "주제 미상"),
      started_at: .timestamp,
      decision: (.payload.decision // null)
    }
]' 2>/dev/null || echo "[]")

# 메트릭
COMPLETED_TODAY=$(echo "$TASKS" | jq --arg today "$TODAY" \
  '[.[] | select(.day == $today and .status == "completed")] | length' 2>/dev/null || echo 0)
IN_PROGRESS=$(echo "$TASKS" | jq '[.[] | select(.status == "in_progress")] | length' 2>/dev/null || echo 0)
BLOCKED=$(echo "$TASKS" | jq '[.[] | select(.status == "blocked")] | length' 2>/dev/null || echo 0)
PENDING=$(echo "$TASKS" | jq '[.[] | select(.status == "pending")] | length' 2>/dev/null || echo 0)
MEETINGS_TODAY=$(echo "$MEETINGS" | jq --arg today "$TODAY" \
  '[.[] | select(.started_at | startswith($today))] | length' 2>/dev/null || echo 0)

# 회사 프로필 + 전문가 목록 수집 (있다면)
PROFILE_JSON="{}"
if [ -f ".ai-company/company-profile.yaml" ]; then
  # 간단한 키만 추출 (YAML 풀파서 없이)
  PROJECT_NAME=$(grep -m1 "^project_name:" .ai-company/company-profile.yaml | sed 's/^project_name:[[:space:]]*//; s/[[:space:]]*$//' | tr -d '"')
  DOMAIN=$(grep -m1 "^domain:" .ai-company/company-profile.yaml | sed 's/^domain:[[:space:]]*//; s/[[:space:]]*$//' | tr -d '"')
  PROFILE_JSON=$(jq -n --arg n "$PROJECT_NAME" --arg d "$DOMAIN" '{project_name: $n, domain: $d}')
fi

EXPERTS_JSON="[]"
if [ -d ".ai-company/agents" ]; then
  EXPERTS_JSON=$(ls .ai-company/agents/*.md 2>/dev/null | while read f; do
    NAME=$(basename "$f" .md)
    MODEL=$(grep -m1 "^model:" "$f" | sed 's/^model:[[:space:]]*//; s/[[:space:]]*$//' | tr -d '"')
    DESC=$(grep -m1 "^description:" "$f" | sed 's/^description:[[:space:]]*//' | head -c 150 | tr -d '"\\')
    jq -n --arg n "$NAME" --arg m "$MODEL" --arg d "$DESC" \
      '{name: $n, model: $m, description: $d}'
  done | jq -s '.' 2>/dev/null || echo "[]")
fi

# data.json 작성
GENERATED_AT=$(date -Iseconds 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")
jq -n \
  --arg ts "$GENERATED_AT" \
  --argjson profile "$PROFILE_JSON" \
  --argjson experts "$EXPERTS_JSON" \
  --argjson tasks "$TASKS" \
  --argjson meetings "$MEETINGS" \
  --argjson done "$COMPLETED_TODAY" \
  --argjson prog "$IN_PROGRESS" \
  --argjson blk "$BLOCKED" \
  --argjson pen "$PENDING" \
  --argjson mt "$MEETINGS_TODAY" \
  '{
    generated_at: $ts,
    last_updated: $ts,
    company_profile: $profile,
    experts: $experts,
    tasks: $tasks,
    meetings: $meetings,
    metrics: {
      tasks_completed_today: $done,
      tasks_in_progress: $prog,
      tasks_blocked: $blk,
      tasks_pending: $pen,
      meetings_today: $mt
    }
  }' > "$DATA_FILE" 2>/dev/null

# 일별 마크다운 칸반 스냅샷 생성
{
  echo "# ${TODAY} — Daily Kanban"
  echo ""
  echo "> 자동 생성됨 · ${GENERATED_AT}"
  echo ""

  # 상태별 작업 추출
  for STATUS in completed in_progress pending blocked; do
    case "$STATUS" in
      completed)   ICON="✅"; LABEL="Done" ;;
      in_progress) ICON="🚧"; LABEL="In Progress" ;;
      pending)     ICON="⏳"; LABEL="Todo" ;;
      blocked)     ICON="🚫"; LABEL="Blocked" ;;
    esac

    COUNT=$(echo "$TASKS" | jq --arg s "$STATUS" --arg t "$TODAY" \
      '[.[] | select(.status == $s and .day == $t)] | length' 2>/dev/null || echo 0)

    echo ""
    echo "## ${ICON} ${LABEL} (${COUNT})"
    echo ""

    if [ "$COUNT" -eq 0 ]; then
      echo "_없음_"
    else
      echo "$TASKS" | jq -r --arg s "$STATUS" --arg t "$TODAY" \
        '.[] | select(.status == $s and .day == $t)
        | "- `" + .id + "` " + .title + " — _" + .assigned_to + "_"' 2>/dev/null
    fi
  done

  echo ""
  echo "## 📝 Today's Meetings"
  echo ""

  MEETINGS_LIST=$(echo "$MEETINGS" | jq -r --arg t "$TODAY" \
    '.[] | select(.started_at | startswith($t))
    | "- " + (.started_at | split("T")[1] | split("+")[0] | split(".")[0]) + " · " + .topic' 2>/dev/null)

  if [ -z "$MEETINGS_LIST" ]; then
    echo "_없음_"
  else
    echo "$MEETINGS_LIST"
  fi

} > "$DAILY_FILE"

exit 0
