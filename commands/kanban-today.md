---
description: 오늘의 작업 칸반을 터미널에 표시하고 일별 마크다운 스냅샷을 갱신합니다.
allowed-tools: Read, Write, Bash
---

# 오늘의 칸반

다음을 수행하십시오:

## 1. 오늘 날짜의 이벤트 추출

```bash
TODAY=$(date +%Y-%m-%d)
EVENTS_FILE=".ai-company/chronicles/events.jsonl"

if [ ! -f "$EVENTS_FILE" ]; then
  echo "⚠️ AI Company가 초기화되지 않았습니다. /company-init을 먼저 실행하세요."
  exit 0
fi

# 오늘 이벤트만 필터
grep "\"timestamp\":\"$TODAY" "$EVENTS_FILE" > /tmp/today-events.jsonl 2>/dev/null
TOTAL=$(wc -l < /tmp/today-events.jsonl)
echo "오늘 발생 이벤트: $TOTAL건"
```

## 2. 작업 상태별 집계

`dashboard/data.json`을 읽어 작업을 상태별로 분류:

- ✅ Done: status == "completed"
- 🚧 In Progress: status == "in_progress"
- ⏳ Todo: status == "pending"
- 🚫 Blocked: status == "blocked"

## 3. 터미널에 박스 형식으로 출력

다음 형식으로 출력 (담당자 이름은 **현재 프로젝트의 실제 전문가 이름**으로 표시):

```
╔══════════════════════════════════════════════════════════════╗
║  📋 KANBAN — 2026-05-17                                     ║
╠══════════════════════════════════════════════════════════════╣
║  ✅ DONE (8)                                                 ║
║    • task-001  ...               [<expert-name>]   2h       ║
║    • task-002  ...               [<expert-name>]   3h       ║
║    ...                                                       ║
║                                                              ║
║  🚧 IN PROGRESS (2)                                          ║
║    • task-009  ...               [<expert-name>]   1h 진행중║
║    ...                                                       ║
║                                                              ║
║  ⏳ TODO (2)                                                 ║
║    • task-011  ...               [<expert-name>]   deps:009 ║
║    ...                                                       ║
║                                                              ║
║  🚫 BLOCKED (0)                                              ║
║    _없음_                                                    ║
╚══════════════════════════════════════════════════════════════╝

오늘의 회의 (1)
  📝 08:20  <회의 주제>
            → .ai-company/chronicles/meetings/<timestamp>-*.md
```

## 4. 마크다운 스냅샷 저장

같은 내용을 chronicler 형식 마크다운으로 `chronicles/daily/YYYY-MM-DD.md`에 저장 (덮어쓰기).

## 5. 다음 액션 제안

- 진행 중 작업이 있으면: "X 작업을 모니터링하시겠습니까?"
- 막힌 작업이 있으면: "Y 작업이 막혀있습니다. 개입하시겠습니까?"
- 모두 완료면: "모든 작업이 완료되었습니다. 팀을 정리할까요?"
