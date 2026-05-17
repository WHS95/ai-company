---
description: 과거 회의록을 날짜·주제로 검색하여 조회합니다.
argument-hint: <검색어 (선택, 비우면 최근 10건)>
allowed-tools: Read, Bash, Grep, Glob
---

# 회의록 검색: $ARGUMENTS

## 절차

```bash
MEETINGS_DIR=".ai-company/chronicles/meetings"

if [ ! -d "$MEETINGS_DIR" ]; then
  echo "⚠️ 회의록이 없습니다. /company-init 후 회의가 1회 이상 있어야 합니다."
  exit 0
fi

QUERY="$ARGUMENTS"

if [ -z "$QUERY" ]; then
  # 최근 10건
  echo "📚 최근 회의록 10건"
  ls -t "$MEETINGS_DIR"/*.md 2>/dev/null | head -10 | while read f; do
    BASENAME=$(basename "$f" .md)
    TOPIC=$(grep -m1 "^# 회의:" "$f" | sed 's/^# 회의: //')
    DATE=$(grep -m1 "일시" "$f" | sed 's/.*: //')
    echo "  • $BASENAME"
    echo "    └ $TOPIC ($DATE)"
  done
else
  # 키워드 검색
  echo "🔍 '$QUERY' 검색 결과"
  grep -l -i "$QUERY" "$MEETINGS_DIR"/*.md 2>/dev/null | while read f; do
    BASENAME=$(basename "$f" .md)
    TOPIC=$(grep -m1 "^# 회의:" "$f" | sed 's/^# 회의: //')
    MATCH=$(grep -i -m1 "$QUERY" "$f" | head -c 100)
    echo "  • $BASENAME — $TOPIC"
    echo "    └ ...$MATCH..."
  done
fi
```

## 결과 표시 후

회장에게:
```
📂 회의록 위치: .ai-company/chronicles/meetings/
특정 회의록을 자세히 볼까요? 파일명(또는 날짜)을 알려주세요.
```

회장이 특정 회의록을 지정하면 `Read`로 읽어서 핵심 결정사항만 요약 표시.
