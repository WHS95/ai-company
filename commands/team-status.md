---
description: 현재 활성 팀의 상태, 각 팀원의 진행 상황, 작업 목록을 한눈에 표시합니다.
allowed-tools: Read, Bash
---

# 팀 현황

## 절차

```bash
DATA=".ai-company/dashboard/data.json"

if [ ! -f "$DATA" ]; then
  echo "⚠️ 활성 팀이 없습니다. /new-request로 새 요청을 시작하세요."
  exit 0
fi

# 데이터 읽기
cat "$DATA"
```

위 JSON과 `.ai-company/agents/` 디렉토리를 읽어서 **이 프로젝트의 실제 전문가 이름**으로 다음 형식으로 출력:

```
🏢 현재 팀: <team_name>
프로젝트: <project_name> (회사 설립일: <when>)
시작 시각: <started_at> (경과: Xh Xm)

👥 팀원 (X명) — 이 프로젝트의 동적 전문가
  • <expert-name-1>   [Opus]    🟢 활동중 / 🟡 대기 / 🔴 오류
  • <expert-name-2>   [Sonnet]  ...
  • <expert-name-3>   [Opus]    ...
  • chronicler        [Haiku]   🟢 활동중 (공통)

📊 진행률
  ████████░░░░░░░░  8 / 12 작업 완료 (66%)

🎯 현재 진행 중
  • task-009 ... (<expert-name>, 1h 진행중)
  • task-010 ... (<expert-name>, 30m 진행중)

⏭ 대기 중
  • task-011 ... (<expert-name>, deps: task-009)
  • task-012 ... (<expert-name>, deps: task-010, task-011)

📝 오늘의 회의: 1건
```

## 추가 옵션 제안

```
다음 액션:
  /kanban-today        칸반 뷰
  /dashboard-open      웹 대시보드
  /meeting-history     회의록 검색

특정 팀원에게 직접 메시지를 보내려면 tmux pane을 클릭하거나
Shift+Down(in-process 모드)으로 전환하세요.
```
