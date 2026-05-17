#!/usr/bin/env bash
#
# AI Company - 이벤트 로깅 훅
#
# 사용법: log-event.sh <event_type>
#   stdin으로 Claude Code의 hook payload(JSON)를 받아
#   .ai-company/chronicles/events.jsonl에 한 줄을 append하고
#   .ai-company/dashboard/data.json을 부분 갱신합니다.
#
# 실패해도 Claude Code의 흐름을 막지 않기 위해 항상 exit 0.

set -u

EVENT_TYPE="${1:-unknown}"
CHRONICLES_DIR=".ai-company/chronicles"
DASHBOARD_DIR=".ai-company/dashboard"
EVENTS_FILE="$CHRONICLES_DIR/events.jsonl"
DATA_FILE="$DASHBOARD_DIR/data.json"

# 디렉토리가 없으면 만든다 (init 안 됐어도 안전하게)
mkdir -p "$CHRONICLES_DIR/meetings" "$CHRONICLES_DIR/daily" "$DASHBOARD_DIR" 2>/dev/null

# stdin 페이로드 읽기 (없으면 빈 객체)
PAYLOAD=$(cat 2>/dev/null || echo "{}")
[ -z "$PAYLOAD" ] && PAYLOAD="{}"

TS=$(date -Iseconds 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")

# jq 가용성 확인
if command -v jq >/dev/null 2>&1; then
  # jq 있음 - 구조화된 이벤트
  EVENT=$(echo "$PAYLOAD" | jq -c \
    --arg ts "$TS" \
    --arg et "$EVENT_TYPE" \
    '{timestamp: $ts, event_type: $et, payload: .}' 2>/dev/null) \
    || EVENT="{\"timestamp\":\"$TS\",\"event_type\":\"$EVENT_TYPE\",\"payload_parse_error\":true}"
else
  # jq 없음 - 단순 fallback
  ESCAPED=$(echo "$PAYLOAD" | tr -d '\n' | sed 's/"/\\"/g')
  EVENT="{\"timestamp\":\"$TS\",\"event_type\":\"$EVENT_TYPE\",\"raw_payload\":\"$ESCAPED\"}"
fi

# events.jsonl에 append
echo "$EVENT" >> "$EVENTS_FILE" 2>/dev/null

# dashboard/data.json 증분 갱신
# (전체 재생성은 별도 스크립트 rebuild-dashboard.sh가 담당)
if command -v jq >/dev/null 2>&1 && [ -f "$DATA_FILE" ]; then
  # 간단한 metrics 업데이트
  TMP=$(mktemp)
  jq --arg ts "$TS" '.last_updated = $ts' "$DATA_FILE" > "$TMP" 2>/dev/null && mv "$TMP" "$DATA_FILE" 2>/dev/null
fi

# 매 50개 이벤트마다 dashboard 전체 재생성 (rebuild-dashboard.sh가 있다면)
if [ -f "$EVENTS_FILE" ]; then
  COUNT=$(wc -l < "$EVENTS_FILE" 2>/dev/null | tr -d ' ')
  REBUILD_SCRIPT="${CLAUDE_PLUGIN_ROOT:-}/hooks/rebuild-dashboard.sh"
  if [ -n "$COUNT" ] && [ "$COUNT" != "0" ] && [ -x "$REBUILD_SCRIPT" ]; then
    if [ $((COUNT % 50)) -eq 0 ]; then
      "$REBUILD_SCRIPT" >/dev/null 2>&1 &
    fi
  fi
fi

# 항상 성공 종료 (Claude 흐름 차단 방지)
exit 0
