# Contributing to AI Company

AI Company에 기여해주셔서 감사합니다! 이 문서는 기여 절차를 안내합니다.

## 개발 환경 설정

```bash
# 저장소 클론
git clone https://github.com/WHS95/ai-company.git
cd ai-company

# 로컬 테스트용 플러그인 디렉토리에 심볼릭 링크
mkdir -p ~/.claude/plugins
ln -s "$(pwd)" ~/.claude/plugins/ai-company

# Agent Teams 활성화 (없으면 추가)
cat >> ~/.claude/settings.json <<'EOF'
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
EOF
```

이제 어떤 프로젝트 디렉토리에서든 `claude`를 실행하면 변경 사항이 즉시 반영됩니다.

## 기여할 수 있는 영역

### 🐛 버그 신고

이슈를 열어주세요. 다음을 포함하면 큰 도움이 됩니다:

- Claude Code 버전 (`claude --version`)
- OS / 터미널 / tmux 버전
- 재현 단계
- `.ai-company/chronicles/events.jsonl`의 관련 부분 (민감정보 제거 후)

### ✨ 기능 제안

이슈에서 먼저 논의 후 PR을 보내주세요. 컨셉의 핵심을 흐리는 변경(예: 정적 전문가 풀 부활)은 거절될 수 있습니다.

### 📝 문서 개선

오타, 명료성 개선, 번역 모두 환영합니다.

### 🎨 대시보드 디자인

`dashboard/index.html`은 단일 파일입니다. CSS·JS 모두 그 안에 있습니다.

## PR 가이드라인

1. **이슈 먼저, PR 나중에**: 큰 변경은 이슈에서 합의 후 시작
2. **한 PR은 한 가지**: 여러 변경을 섞지 마세요
3. **CHANGELOG 갱신**: 사용자 가시 변경은 `CHANGELOG.md`에 기록
4. **테스트**: 기능 변경 시 실제 프로젝트에서 한 사이클(`/company-init` → `/new-request` → 완료) 동작 확인

## 코드 컨벤션

### 마크다운 파일 (커맨드, 에이전트 카드)

- frontmatter 필드 순서: `name → description → model → tools → argument-hint → allowed-tools`
- 본문은 한국어 + 영어 식별자 혼용 OK (전문 용어는 영어 유지)
- 코드 블록의 언어 명시 (`bash`, `json`, `yaml`)

### 셸 스크립트

- `set -u` 권장 (`set -e`는 hooks에서 신중히)
- 항상 `exit 0`로 끝내서 Claude Code 흐름 차단 방지 (hooks)
- `jq` 미설치 환경에서도 동작하도록 fallback

### HTML/CSS/JS

- 대시보드는 빌드 단계 없이 단일 HTML
- 외부 폰트만 CDN 허용, 라이브러리는 임베드
- CSS 변수(`:root`)로 테마 통일

## 새 기능을 만들 때 지켜야 할 컨셉

이 플러그인의 핵심 가치를 깨지 마세요:

1. **프로젝트별 동적 회사** — 정적 라이브러리로 회귀 금지
2. **회장 승인 우선** — 카드 생성·삭제는 반드시 사용자 승인
3. **사관(chronicler)은 유일한 공통 전문가**
4. **회의 프로토콜** — 병렬 분석 → 충돌 감지 → 타겟 토론 (최대 2R) → 합의
5. **불변 기록** — events.jsonl은 append-only

## 릴리스

- 메인테이너만 릴리스 가능
- SemVer 준수: 컨셉을 깨는 변경은 major, 호환 기능 추가는 minor, 버그 수정은 patch
- 릴리스 시 GitHub Release 페이지에 CHANGELOG 발췌 + 마이그레이션 노트(있다면)

## 행동 규약

- 친절하게, 건설적으로
- 의견 차이는 코드와 근거로 해결
- 초보자 환영

질문이 있으면 GitHub Discussions를 이용해주세요.
