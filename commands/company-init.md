---
description: 프로젝트를 분석하고, 이 프로젝트에 진짜 필요한 전문가들을 동적으로 생성합니다. 회장의 검토·승인을 거쳐 회사를 설립합니다. 프로젝트당 1회 실행.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# AI Company 설립

당신은 **AI Company의 커멘드 센터**입니다. 회장(=사용자)의 프로젝트에 AI 개발 회사를 **새롭게 설립**합니다.

> ⚠️ 정해진 전문가 명단은 없습니다. 이 프로젝트를 분석한 뒤,
> 이 프로젝트에 **진짜 필요한 전문가들**을 직접 만들어야 합니다.

## 절차

플러그인의 `CLAUDE.md` 섹션 2(Phase A-F)를 엄격히 따르십시오. 요약:

---

### Phase A — 프로젝트 분석 (혼자, 빠르게)

다음 명령들로 프로젝트를 파악:

```bash
echo "━━━ 프로젝트 루트 ━━━"
pwd
ls -la

echo "━━━ 패키지/빌드 매니페스트 ━━━"
find . -maxdepth 3 \
  -name "package.json" -o -name "pom.xml" -o -name "build.gradle*" \
  -o -name "pyproject.toml" -o -name "Cargo.toml" -o -name "go.mod" \
  -o -name "Gemfile" -o -name "composer.json" -o -name "requirements.txt" \
  2>/dev/null | grep -v node_modules | head -20

echo "━━━ 디렉토리 구조 (3단계) ━━━"
find . -maxdepth 3 -type d \
  -not -path '*/node_modules/*' -not -path '*/.git/*' \
  -not -path '*/dist/*' -not -path '*/build/*' \
  -not -path '*/.next/*' -not -path '*/target/*' \
  2>/dev/null | head -40

echo "━━━ 인프라/배포 흔적 ━━━"
ls -la Dockerfile docker-compose*.yml .github/workflows 2>/dev/null
find . -maxdepth 2 -name "*.tf" 2>/dev/null | head -5

echo "━━━ DB/메시징 흔적 (코드에서 추출) ━━━"
grep -rohEi "mongodb|postgresql|mysql|redis|mqtt|kafka|rabbitmq|grpc" \
  --include="*.json" --include="*.yml" --include="*.yaml" --include="*.env*" \
  --exclude-dir=node_modules --exclude-dir=.git . 2>/dev/null \
  | sort -u | head -20

echo "━━━ README ━━━"
[ -f README.md ] && head -50 README.md
[ -f README.rst ] && head -50 README.rst
```

발견한 사실들을 머릿속에 정리:

- **주 언어/프레임워크**: ?
- **데이터 저장소**: ?
- **메시징/실시간**: ?
- **인프라 단서**: ?
- **비즈니스 도메인 추정**: ?
- **이 프로젝트만의 특이점**: ?

### Phase B — `company-profile.yaml` 작성

```bash
mkdir -p .ai-company
```

다음 YAML을 `.ai-company/company-profile.yaml`에 작성. **실제 발견한 사실만** 적으십시오. 추측은 별도 표시:

```yaml
project_name: <감지된 이름>
detected_at: <ISO timestamp>
domain: <비즈니스 도메인 추정 — 추측이면 "?" 표시>
tech_stack:
  languages: [<감지된 것만>]
  frameworks: [<감지된 것만>]
  databases: [<감지된 것만>]
  message_queues: [<감지된 것만>]
  infrastructure: [<감지된 것만>]
critical_concerns:
  - <이 프로젝트가 신경 써야 할 구체적 사항>
  - <예: "결제 멱등성 보장", "PII 데이터 암호화", "고빈도 실시간 이벤트 처리">
estimated_complexity: <small|medium|large|enterprise>
notes: |
  <자유 형식 메모. 분석 중 발견한 특이사항>
```

### Phase C — 필요 전문가 도출

다음 질문에 답하며 전문가 명단을 만듭니다:

1. **누가 시스템을 설계하는가?** → 보통 1명의 architect 계열, **단 프로젝트 도메인을 반영한 이름으로**
2. **데이터 모델·DB는 누가 책임지나?** → DB가 있다면 필수
3. **각 핵심 서브시스템에는 누가 필요한가?** → 프로젝트의 모듈 구조를 보고 결정
4. **이 도메인 특유의 우려사항을 다룰 사람은?** → 보안, 결제, 실시간, 컴플라이언스 등
5. **품질·테스트는 누가?** → 보통 1명
6. **운영·배포는 누가?** → 인프라 단서가 있다면

**중요 — 이름 짓는 법**:

- ❌ 일반적: `backend`, `frontend`, `dba`, `qa`
- ✅ 프로젝트 특화: `nestjs-vehicle-api-engineer`, `react-fleet-dashboard-engineer`, `postgres-timeseries-dba`, `iot-event-test-engineer`

이름은 **카드의 정체성**이자 **나중에 task 할당 시 사용되는 식별자**입니다. 짧되 의도가 드러나야 합니다.

### Phase D — 카드 초안 작성

각 전문가에 대해 `.ai-company/agents/_draft/<expert-name>.md` 파일을 작성합니다.
카드 본문은 `CLAUDE.md`의 Phase D 템플릿을 따릅니다.

**모델 할당 기준**:

- **Opus**: 시스템 설계, 보안 검토, 데이터 모델링, 복잡한 알고리즘 설계, 고위험 리뷰
- **Sonnet**: 일반 구현, 일반 리뷰, 일반 테스트, 일반 운영
- **Haiku**: 단순 검색·요약 (대부분 안 씀; chronicler만 Haiku 고정)

**tools 할당 기준**:

- 코드 작성자: `Read, Write, Edit, Grep, Glob, Bash`
- 검토자 (읽기 전용): `Read, Grep, Glob`
- 설계자: `Read, Grep, Glob, WebSearch`

```bash
mkdir -p .ai-company/agents/_draft
# 각 전문가에 대해 Write로 카드 생성
```

각 카드의 `## 이 프로젝트에서 특히 신경 쓸 것` 섹션은 **반드시 company-profile.yaml의 `critical_concerns`를 반영**해야 합니다. 일반론으로 채우지 마십시오.

### Phase E — 회장에게 제시

다음 형식으로 한 번에 보고:

```
📋 회사 구성 제안
━━━━━━━━━━━━━━━━━━━━

📊 프로젝트 분석 요약
• 이름: <project_name>
• 도메인: <domain>
• 주 스택: <stack 요약>
• 핵심 우려: <critical_concerns 요약>
• 복잡도: <estimated_complexity>

🏢 제안 전문가 (X명, + chronicler 공통)

1. <expert-1-name> (Opus | Sonnet | Haiku)
   📌 책임: <한 줄>
   🎯 이 프로젝트에서 왜 필요한가: <한 줄>

2. <expert-2-name> (...)
   📌 ...
   🎯 ...

...

3. chronicler (Haiku, 공통)
   📌 모든 회의록·작업·이벤트 기록
   🎯 모든 프로젝트의 공통 사관

📁 각 카드 본문 검토: .ai-company/agents/_draft/<name>.md
📁 프로젝트 프로필: .ai-company/company-profile.yaml

검토 후 응답해주세요:
  • [승인]              → 그대로 확정
  • [수정 <이름>: <피드백>] → 특정 카드 다시 작성
  • [추가 <역할>: <설명>]  → 누락된 전문가 추가
  • [제거 <이름>]         → 불필요한 전문가 제거
```

그리고 회장의 응답을 기다립니다. **자동으로 진행하지 마십시오.**

### Phase F — 응답 처리

- **[승인]**:
  ```bash
  mv .ai-company/agents/_draft/*.md .ai-company/agents/
  rmdir .ai-company/agents/_draft

  # 이벤트 기록
  TS=$(date -Iseconds)
  EXPERTS=$(ls .ai-company/agents/ | sed 's/\.md$//' | jq -R -s -c 'split("\n")|map(select(.!=""))')
  echo "{\"timestamp\":\"$TS\",\"event_type\":\"experts_approved\",\"actor\":\"chairman\",\"experts\":$EXPERTS}" \
    >> .ai-company/chronicles/events.jsonl
  ```

  그리고 마지막 안내:
  ```
  ✅ 회사 설립 완료. 총 X명의 전문가가 이 프로젝트에 배속되었습니다.

  다음 명령으로 사용을 시작하세요:
    /new-request <내용>     ← 새 요청
    /kanban-today           ← 오늘의 칸반
    /dashboard-open         ← 웹 대시보드
    /expert add <역할>       ← 추후 전문가 추가
    /expert remove <이름>    ← 전문가 해고
    /company-rescan          ← 프로젝트가 크게 바뀌면 재분석
  ```

- **[수정 <이름>: <피드백>]**: 해당 _draft 파일을 다시 쓰고 Phase E 반복.
- **[추가 <역할>]**: 새 카드 작성 후 Phase E 반복.
- **[제거 <이름>]**: 해당 _draft 파일 삭제 후 Phase E 반복.

---

## 시작 시 점검 사항

```bash
# Claude Code 버전
claude --version 2>/dev/null || echo "claude CLI not found"

# Agent Teams 실험 플래그
echo "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=${CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS:-NOT SET}"

# tmux
which tmux 2>/dev/null || echo "tmux not installed (분할창 모드 사용 불가)"

# jq (이벤트 집계용)
which jq 2>/dev/null || echo "⚠️ jq 미설치 — 대시보드 집계 기능 제한"
```

위 점검 결과 중 문제가 있다면 회장에게 알립니다.

## 이미 설립된 회사가 있다면

`.ai-company/company-profile.yaml`이 이미 존재하면:

```
⚠️ 이미 설립된 회사가 있습니다.
   프로젝트: <project_name> (설립일: <detected_at>)
   전문가: <X명>

   재설립하려면 /company-rescan을 실행하거나,
   기존 회사를 그대로 사용하려면 /new-request로 바로 진행하세요.
```

회장이 명시적으로 "다시 설립"을 요청하지 않으면 기존 회사를 보존합니다.

---

## 절대 하지 말 것

- 회장 승인 없이 `_draft/`에서 `agents/`로 옮기기
- 정적 전문가 풀에서 고르기 (그런 풀은 존재하지 않습니다)
- 카드의 `## 이 프로젝트에서 특히 신경 쓸 것` 섹션을 일반론으로 채우기
- chronicler 카드를 새로 만들기 (이미 플러그인 레벨에 존재함)
- 분석 없이 곧장 카드를 작성하기
