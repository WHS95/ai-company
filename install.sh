#!/usr/bin/env bash
#
# AI Company - 환경 설정 도우미
#
# 이 스크립트는 플러그인 설치 후 1회 실행하여 다음을 자동화합니다:
#   1. Claude Code 버전 확인 (v2.1.32+)
#   2. Agent Teams 실험 플래그 활성화
#   3. tmux teammateMode 설정 (선택)
#   4. jq 가용성 확인
#
# 사용법:
#   curl -fsSL https://raw.githubusercontent.com/WHS95/ai-company/main/install.sh | bash
#   또는 (로컬 설치 후):
#   bash ~/.claude/plugins/ai-company/install.sh

set -u

# ─── 색상 ───
if [ -t 1 ]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_RED=$'\033[31m'
  C_BLUE=$'\033[34m'
  C_DIM=$'\033[2m'
else
  C_RESET=""; C_BOLD=""; C_GREEN=""; C_YELLOW=""; C_RED=""; C_BLUE=""; C_DIM=""
fi

ok()    { echo "${C_GREEN}✓${C_RESET} $*"; }
warn()  { echo "${C_YELLOW}⚠${C_RESET} $*"; }
err()   { echo "${C_RED}✗${C_RESET} $*"; }
info()  { echo "${C_BLUE}→${C_RESET} $*"; }

echo ""
echo "${C_BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
echo "${C_BOLD}  AI Company · 환경 설정 도우미${C_RESET}"
echo "${C_BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
echo ""

# ─── 1. Claude Code 확인 ───
info "Claude Code 버전 확인 중..."

if ! command -v claude >/dev/null 2>&1; then
  err "Claude Code가 설치되어 있지 않습니다."
  echo "    → https://claude.com/code 에서 설치 후 다시 실행하세요."
  exit 1
fi

CLAUDE_VERSION=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
if [ -z "$CLAUDE_VERSION" ]; then
  warn "Claude Code 버전을 감지할 수 없습니다. 계속 진행합니다."
else
  ok "Claude Code v$CLAUDE_VERSION"

  # 버전 비교 (v2.1.32 필요)
  REQUIRED="2.1.32"
  if [ "$(printf '%s\n' "$REQUIRED" "$CLAUDE_VERSION" | sort -V | head -1)" != "$REQUIRED" ]; then
    warn "v$REQUIRED 이상을 권장합니다. Agent Teams가 지원되지 않을 수 있습니다."
    echo "    → claude update 명령으로 업그레이드 가능합니다."
  fi
fi

echo ""

# ─── 2. settings.json 위치 결정 ───
info "Claude Code 설정 파일 위치 확인 중..."

SETTINGS_DIR="$HOME/.claude"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"

mkdir -p "$SETTINGS_DIR"

if [ ! -f "$SETTINGS_FILE" ]; then
  info "settings.json이 없습니다. 새로 생성합니다."
  echo "{}" > "$SETTINGS_FILE"
fi

ok "설정 파일: $SETTINGS_FILE"
echo ""

# ─── 3. Agent Teams 플래그 ───
info "Agent Teams 실험 플래그 점검 중..."

if ! command -v jq >/dev/null 2>&1; then
  err "jq가 필요합니다. 설치 후 다시 실행하세요."
  echo "    macOS:  brew install jq"
  echo "    Linux:  apt-get install jq  또는  dnf install jq"
  echo ""
  echo "${C_DIM}jq 없이 수동 설정하려면 settings.json에 다음을 추가하세요:${C_RESET}"
  cat <<'EOF'

  {
    "env": {
      "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
    },
    "teammateMode": "auto"
  }

EOF
  exit 1
fi

# 백업
cp "$SETTINGS_FILE" "${SETTINGS_FILE}.bak.$(date +%Y%m%d%H%M%S)"
ok "백업 생성: ${SETTINGS_FILE}.bak.*"

# 현재 값 확인
CURRENT_FLAG=$(jq -r '.env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS // ""' "$SETTINGS_FILE" 2>/dev/null)

if [ "$CURRENT_FLAG" = "1" ]; then
  ok "Agent Teams 플래그가 이미 활성화되어 있습니다."
else
  info "Agent Teams 플래그를 활성화합니다..."
  TMP=$(mktemp)
  jq '.env = (.env // {}) | .env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1"' \
    "$SETTINGS_FILE" > "$TMP" && mv "$TMP" "$SETTINGS_FILE"
  ok "활성화 완료"
fi

echo ""

# ─── 4. tmux 점검 + teammateMode ───
info "tmux / 분할창 모드 확인 중..."

if command -v tmux >/dev/null 2>&1; then
  TMUX_VERSION=$(tmux -V 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1)
  ok "tmux $TMUX_VERSION 감지됨"

  # teammateMode를 auto로 (이미 tmux 안이면 분할창, 아니면 in-process)
  CURRENT_MODE=$(jq -r '.teammateMode // ""' "$SETTINGS_FILE" 2>/dev/null)
  if [ -z "$CURRENT_MODE" ]; then
    info "teammateMode를 'auto'로 설정합니다 (tmux 세션 안이면 분할창)."
    TMP=$(mktemp)
    jq '.teammateMode = "auto"' "$SETTINGS_FILE" > "$TMP" && mv "$TMP" "$SETTINGS_FILE"
    ok "teammateMode=auto 설정 완료"
  else
    ok "teammateMode=$CURRENT_MODE (기존 설정 유지)"
  fi
else
  warn "tmux 미설치 — 분할창 모드 사용 불가 (in-process 모드만 가능)"
  echo "    macOS:  brew install tmux"
  echo "    Linux:  apt-get install tmux  또는  dnf install tmux"
fi

echo ""

# ─── 5. 플러그인 설치 안내 ───
info "플러그인 설치 상태 확인 중..."

PLUGIN_DIR_USER="$HOME/.claude/plugins/ai-company"
PLUGIN_DIR_MARKETPLACE="$HOME/.claude/plugins/.../ai-company"

if [ -d "$PLUGIN_DIR_USER" ]; then
  ok "플러그인이 설치되어 있습니다: $PLUGIN_DIR_USER"
elif ls $HOME/.claude/plugins/*/ai-company 2>/dev/null | head -1 > /dev/null; then
  FOUND=$(ls -d $HOME/.claude/plugins/*/ai-company 2>/dev/null | head -1)
  ok "플러그인이 marketplace 경유로 설치되어 있습니다: $FOUND"
else
  warn "플러그인이 아직 설치되지 않은 것 같습니다."
  echo ""
  echo "    Claude Code 안에서 다음을 실행하세요:"
  echo ""
  echo "      ${C_BOLD}/plugin marketplace add WHS95/ai-company${C_RESET}"
  echo "      ${C_BOLD}/plugin install ai-company@ai-company${C_RESET}"
  echo ""
fi

echo ""

# ─── 6. 마무리 ───
echo "${C_BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
echo "${C_GREEN}${C_BOLD}  ✅ 환경 설정 완료${C_RESET}"
echo "${C_BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
echo ""
echo "${C_BOLD}다음 단계:${C_RESET}"
echo ""
echo "  1. 프로젝트 디렉토리로 이동"
echo "       cd /path/to/your-project"
echo ""
echo "  2. Claude Code 실행"
echo "       claude"
echo ""
echo "  3. 회사 설립 (1회만)"
echo "       /company-init"
echo ""
echo "  4. 새 요청"
echo "       /new-request <자연어로 요청 내용>"
echo ""
echo "${C_DIM}자세한 문서: https://github.com/WHS95/ai-company${C_RESET}"
echo ""
