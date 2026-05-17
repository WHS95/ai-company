# 배포 가이드 (For Maintainer)

이 문서는 **Ale님(메인테이너)**이 플러그인을 GitHub에 공개하여 다른 사람들이 설치할 수 있도록 만드는 절차입니다.

## 한눈에 보기

```
┌─────────────────────────────────────────────────────────────┐
│  1. GitHub repo 생성                                          │
│  2. 코드 push                                                 │
│  3. README 미리보기 확인 + GitHub Actions 통과 확인              │
│  4. v0.2.0 태그·릴리스 생성                                    │
│  5. 다른 사람에게 알릴 한 줄:                                   │
│     /plugin marketplace add WHS95/ai-company                  │
│     /plugin install ai-company@ai-company                     │
└─────────────────────────────────────────────────────────────┘
```

---

## 1단계 — GitHub repo 생성

[github.com/new](https://github.com/new) 에서:

- **Repository name**: `ai-company` (소문자·하이픈만)
- **Description**: `프로젝트별 동적 AI 개발팀을 구성하는 Claude Code 플러그인`
- **Visibility**: `Public` (다른 사람이 설치하려면 필수)
- **Initialize**: 아무것도 체크하지 마세요 (이미 로컬에 파일 있음)

## 2단계 — 로컬에서 push

플러그인 디렉토리에서:

```bash
cd /path/to/ai-company

git init
git add .
git commit -m "feat: initial release v0.2.0 — dynamic AI Company plugin"

git branch -M main
git remote add origin https://github.com/WHS95/ai-company.git
git push -u origin main
```

## 3단계 — 검증

### GitHub Actions 확인

push 직후 GitHub repo의 `Actions` 탭에서 **Validate Plugin** 워크플로우가 ✅로 통과하는지 확인. 실패 시:

```bash
# 로컬에서도 검증 가능
jq -e '.name and .version' .claude-plugin/plugin.json
jq -e '.plugins' .claude-plugin/marketplace.json
bash -n hooks/*.sh install.sh
```

### README 미리보기 확인

repo 메인 페이지에서 README가 의도대로 렌더링되는지 확인. 특히:
- 배지(Badge)들이 보이는지
- 디렉토리 트리 코드 블록이 깨지지 않는지
- 링크들(`./CLAUDE.md`, `./LICENSE` 등)이 작동하는지

## 4단계 — 릴리스 만들기

릴리스가 있어야 사용자가 안정 버전을 다운받을 수 있고, 검색에 잘 잡힙니다.

```bash
git tag -a v0.2.0 -m "v0.2.0 — Dynamic AI Company"
git push origin v0.2.0
```

그다음 GitHub repo의 `Releases` → `Draft a new release`:

- **Tag**: `v0.2.0`
- **Title**: `v0.2.0 — Dynamic AI Company`
- **Description**: `CHANGELOG.md`의 v0.2.0 섹션을 복사 + 설치 명령 한 번 더

## 5단계 — 다른 사람 안내

이제 누구나 Claude Code에서 다음 두 줄로 설치 가능합니다:

```bash
/plugin marketplace add WHS95/ai-company
/plugin install ai-company@ai-company
```

이걸 다음 채널에 알리세요:
- 블로그 ([coding-daily.tistory.com](https://coding-daily.tistory.com))
- `awesome-claude-plugins` 같은 디렉토리에 PR
- 사내 PMGrow 슬랙
- 트위터/X, LinkedIn

---

## 추후 업데이트 배포

### Patch (버그 수정, v0.2.1)

```bash
# CHANGELOG.md 갱신
# .claude-plugin/plugin.json, marketplace.json의 version 갱신
git add .
git commit -m "fix: <설명>"
git push

git tag -a v0.2.1 -m "v0.2.1 — Bugfix"
git push origin v0.2.1
# GitHub에서 Release 작성
```

사용자는 다음 명령으로 업데이트:

```bash
/plugin update ai-company@ai-company
```

### Minor (호환 기능 추가, v0.3.0)

같은 절차, 단 PR/이슈로 충분히 논의 후. 컨셉을 깨면 안 됨.

### Major (Breaking change, v1.0.0)

이전 버전 사용자를 위한 **마이그레이션 가이드**를 CHANGELOG와 Release notes에 반드시 명시.

---

## Anthropic 공식 marketplace 등록 (장기 목표)

v1.0 안정화 후, 다음 폼으로 제출 가능:

- 웹 콘솔: [platform.claude.com/plugins/submit](https://platform.claude.com/plugins/submit)
- 통과 시 누구나 더 짧은 명령으로 설치 가능:
  ```bash
  /plugin install ai-company@claude-plugins-official
  ```

심사 기준 (현재 알려진 것):
- 명확한 문서
- LICENSE 명시
- 동작 시연 가능한 데모 (영상 또는 GIF)
- 안정성 (몇 주간 활성 사용 사례)
- 사용자 피드백/이슈 응답성

---

## 트러블슈팅

### "plugin not found" 에러를 사용자가 신고함

```bash
# 사용자에게 알려줄 것
/plugin marketplace update ai-company
# 그래도 안 되면
/plugin marketplace remove ai-company
/plugin marketplace add WHS95/ai-company
```

### marketplace.json을 수정했는데 반영 안 됨

xiaolai/claude-plugin-marketplace의 알려진 이슈처럼, **로컬 클론이 갱신되지 않아서**입니다. 사용자가 `/plugin marketplace update`를 실행해야 합니다.

### settings.json 충돌

사용자가 이미 다른 설정을 갖고 있다면 `install.sh`가 `jq`로 안전하게 머지합니다. 백업은 `~/.claude/settings.json.bak.*`로 자동 생성됩니다.

---

## 체크리스트 (배포 직전)

- [ ] `plugin.json` 버전 갱신
- [ ] `marketplace.json` 버전 갱신
- [ ] `CHANGELOG.md`에 변경사항 기록
- [ ] README의 버전 배지 갱신
- [ ] 로컬에서 `git status` 깔끔한가 확인
- [ ] `.gitignore`로 인해 `.ai-company/` 제외되는지 확인 (테스트 흔적 누설 방지)
- [ ] GitHub Actions 통과
- [ ] 태그·릴리스 작성
- [ ] 깨끗한 새 디렉토리에서 직접 `/plugin install` 테스트
