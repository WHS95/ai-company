---
description: 일별 칸반 대시보드(HTML)를 브라우저로 엽니다. 마우스로 클릭 가능한 인터랙티브 뷰입니다.
allowed-tools: Bash, Read, Write
---

# 칸반 대시보드 열기

## 절차

```bash
PLUGIN_DIR="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/plugins/ai-company}"
DASHBOARD_HTML="$PLUGIN_DIR/dashboard/index.html"
DATA_JSON=".ai-company/dashboard/data.json"

# 데이터 파일 확인
if [ ! -f "$DATA_JSON" ]; then
  echo "⚠️ 데이터 파일이 없습니다. /company-init 또는 /new-request를 먼저 실행하세요."
  exit 0
fi

# 대시보드 HTML이 데이터 파일을 동일 디렉토리에서 찾도록 임시 복사
mkdir -p .ai-company/dashboard
cp "$DASHBOARD_HTML" .ai-company/dashboard/index.html 2>/dev/null \
  || { echo "❌ 대시보드 파일을 찾을 수 없습니다: $DASHBOARD_HTML"; exit 1; }

OUT=".ai-company/dashboard/index.html"

# OS별 열기
case "$(uname -s)" in
  Darwin)  open "$OUT" ;;
  Linux)   xdg-open "$OUT" 2>/dev/null || echo "수동으로 여세요: $OUT" ;;
  MINGW*|CYGWIN*) start "$OUT" ;;
  *)       echo "수동으로 여세요: $OUT" ;;
esac

echo "✅ 대시보드 열림: $OUT"
echo "   데이터 갱신은 자동으로 hooks가 처리합니다."
```

## 회장에게 안내

```
🖥 대시보드가 열렸습니다.
• 데이터 파일: .ai-company/dashboard/data.json
• 페이지는 5초마다 자동 새로고침됩니다 (대시보드 내장)
• 칸반 / 타임라인 / 회의록 탭을 전환할 수 있습니다
```
