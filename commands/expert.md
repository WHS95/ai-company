---
description: 회사의 전문가를 추가·제거·수정·조회합니다. 프로젝트 진행 중에 필요한 역할이 생기면 즉시 전문가를 채용할 수 있습니다.
argument-hint: <add|remove|list|edit> [이름 또는 역할 설명]
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# 전문가 관리: $ARGUMENTS

당신은 **AI Company의 커멘드 센터**입니다. 회장이 전문가 관리 명령을 내렸습니다:

> $ARGUMENTS

## 명령 해석

`$ARGUMENTS`의 첫 단어를 보고 분기:

- `list` (또는 빈 인자): 현재 회사의 전문가 명단 표시
- `add <역할>`: 새 전문가 카드 작성 → 회장 승인 → 확정
- `remove <이름>`: 특정 전문가 해고 (카드 파일 삭제, 단 회장 확인 필요)
- `edit <이름>`: 특정 전문가 카드 수정

회사가 설립되지 않은 경우(`company-profile.yaml`이 없음) 안내 후 종료:

```bash
if [ ! -f .ai-company/company-profile.yaml ]; then
  echo "❌ 회사가 설립되지 않았습니다. 먼저 /company-init을 실행하세요."
  exit 0
fi
```

---

## list

```bash
echo "🏢 현재 회사의 전문가 (.ai-company/agents/)"
echo ""
for card in .ai-company/agents/*.md; do
  [ -f "$card" ] || continue
  NAME=$(basename "$card" .md)
  MODEL=$(grep -m1 "^model:" "$card" | sed 's/model:[[:space:]]*//')
  DESC=$(grep -m1 "^description:" "$card" | sed 's/description:[[:space:]]*//' | head -c 80)
  printf "  • %-40s [%s]  %s\n" "$NAME" "$MODEL" "$DESC"
done

echo ""
echo "  + chronicler (Haiku, 플러그인 공통 - 모든 팀에 자동 포함)"
```

---

## add <역할>

새 전문가 카드를 작성합니다. `CLAUDE.md` Phase D의 템플릿을 따르되:

1. **이름 결정**: 역할 설명을 받았으므로 그에 맞는 이름을 짓습니다.
   - 회장이 이미 이름을 줬으면 그대로 사용
   - 아니면 짧고 의도가 드러나는 kebab-case 이름 생성 (예: `redis-cache-specialist`)

2. **company-profile 참조**: `.ai-company/company-profile.yaml`을 읽어 이 프로젝트의 컨텍스트를 카드에 반영. `## 이 프로젝트에서 특히 신경 쓸 것` 섹션은 일반론 금지.

3. **모델/툴 결정**:
   - 설계·검토·고난도 분석 → Opus
   - 구현·일반 리뷰 → Sonnet
   - 검토자(읽기 전용) → tools: `Read, Grep, Glob`
   - 구현자 → tools: `Read, Write, Edit, Grep, Glob, Bash`

4. **`_draft/`에 먼저 작성**:
   ```bash
   mkdir -p .ai-company/agents/_draft
   # Write로 _draft/<name>.md 작성
   ```

5. **회장에게 제시**:
   ```
   📋 새 전문가 카드 초안: <name>

   • 모델: <model>
   • 책임: <한 줄 요약>
   • 이 프로젝트에서의 역할: <한 줄>

   📁 전체 본문: .ai-company/agents/_draft/<name>.md

   [승인] / [수정: <피드백>] / [취소]?
   ```

6. **회장 응답 처리**:
   - **승인**: `mv _draft/<name>.md ../<name>.md`, `experts_approved` 이벤트 기록
   - **수정**: 피드백 반영하여 다시 작성 후 다시 제시
   - **취소**: `_draft/<name>.md` 삭제

```bash
# 승인 시
mv .ai-company/agents/_draft/<name>.md .ai-company/agents/
rmdir .ai-company/agents/_draft 2>/dev/null

TS=$(date -Iseconds)
echo "{\"timestamp\":\"$TS\",\"event_type\":\"expert_added\",\"actor\":\"chairman\",\"expert\":\"<name>\"}" \
  >> .ai-company/chronicles/events.jsonl
```

---

## remove <이름>

```bash
NAME="<이름>"
CARD=".ai-company/agents/${NAME}.md"

if [ ! -f "$CARD" ]; then
  echo "❌ '$NAME' 전문가가 존재하지 않습니다."
  ls .ai-company/agents/ | sed 's/\.md$//' | sed 's/^/  • /'
  exit 0
fi

# chronicler는 제거 불가
if [ "$NAME" = "chronicler" ]; then
  echo "⚠️ chronicler는 플러그인 공통 전문가로, 제거할 수 없습니다."
  exit 0
fi
```

회장에게 확인:

```
⚠️ '<name>' 전문가를 회사에서 해고합니다.

  📌 책임: <description>

  이 전문가가 진행 중인 작업이 있다면 다른 전문가로 재할당되거나
  중단됩니다. 카드 파일은 백업으로 _archive/에 보관됩니다.

  계속할까요? [예] / [아니오]
```

회장이 [예]하면:

```bash
mkdir -p .ai-company/agents/_archive
mv .ai-company/agents/${NAME}.md .ai-company/agents/_archive/${NAME}-$(date +%Y%m%d).md

TS=$(date -Iseconds)
echo "{\"timestamp\":\"$TS\",\"event_type\":\"expert_removed\",\"actor\":\"chairman\",\"expert\":\"${NAME}\"}" \
  >> .ai-company/chronicles/events.jsonl
```

---

## edit <이름>

기존 카드를 회장이 직접 편집할 수 있도록 안내:

```
📝 전문가 카드 편집: <name>

경로: .ai-company/agents/<name>.md

직접 편집기로 수정하거나, 변경하고 싶은 내용을 알려주시면
제가 대신 수정하겠습니다.

수정 후에는 자동으로 다음 요청부터 새 내용이 반영됩니다.
```

회장이 변경 내용을 자연어로 알려주면 `Read`로 현재 카드를 읽고 `Edit`로 부분 수정.
변경 후 이벤트 기록:

```bash
TS=$(date -Iseconds)
echo "{\"timestamp\":\"$TS\",\"event_type\":\"expert_edited\",\"actor\":\"chairman\",\"expert\":\"<name>\"}" \
  >> .ai-company/chronicles/events.jsonl
```

---

## 절대 하지 말 것

- 회장의 명시적 승인 없이 카드 추가·삭제·수정
- chronicler 카드 건드리기
- _archive/ 안의 파일을 임의로 삭제
- 카드 본문에 `## 이 프로젝트에서 특히 신경 쓸 것` 섹션을 비워두기
