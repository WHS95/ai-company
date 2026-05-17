# Changelog

All notable changes to AI Company will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Level 3 기록: ChromaDB 연동, 과거 회의록 RAG 컨텍스트 주입
- 카드 학습: 좋은 카드 패턴을 다음 프로젝트의 카드 작성 시 참조
- 인사 평가: 전문가별 처리 시간·성공률 자동 분석
- Slack/Discord 알림 통합

## [0.2.0] - 2026-05-17

### Changed
- **BREAKING**: 정적 전문가 풀(11명)을 제거하고 **동적 전문가 생성**으로 전면 재설계
- `/company-init`이 프로젝트를 분석하여 그 프로젝트만의 전문가 카드를 동적 생성
- 회장(사용자)의 카드 검토·승인 절차 추가 (`_draft/` 디렉토리 활용)
- 전문가는 이제 `.ai-company/agents/`에 프로젝트별로 저장
- 대시보드에 **Company 탭** 추가 (회사 프로필 + 동적 전문가 카드 시각화)
- `chronicler`만 플러그인 레벨에 남는 유일한 공통 전문가로 정리

### Added
- `/expert add|remove|list|edit` 명령 — 회사 인사 관리
- `/company-rescan` 명령 — 프로젝트 변화 후 재분석
- `company-profile.yaml` — 프로젝트의 회사 DNA 저장
- `rebuild-dashboard.sh`가 `company-profile`과 `agents/`를 읽어 대시보드에 반영

## [0.1.0] - 2026-05-17

### Added
- 초기 릴리스
- 11명 정적 전문가 풀 (architect, backend, frontend, dba, devops, security-reviewer, performance-analyst, qa, reviewer, detective, chronicler)
- `/company-init`, `/new-request`, `/kanban-today`, `/dashboard-open`, `/meeting-history`, `/team-status` 명령
- Hooks 기반 자동 이벤트 기록 (events.jsonl)
- 칸반 대시보드 HTML (Kanban / Timeline / Meetings 3개 탭)
- 하이브리드 회의 프로토콜 (병렬 분석 → 충돌 감지 → 타겟 토론)
