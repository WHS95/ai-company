<div align="center">

# 🏢 AI Company

**프로젝트를 분석해서 그 프로젝트만의 AI 개발팀을 동적으로 구성하는 Claude Code 플러그인**

[![Version](https://img.shields.io/badge/version-0.2.0-5ee3a8?style=flat-square)](./CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-7aa2f7?style=flat-square)](./LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-v2.1.32+-f7768e?style=flat-square)](https://claude.com/code)
[![Agent Teams](https://img.shields.io/badge/Agent%20Teams-required-e0af68?style=flat-square)](https://code.claude.com/docs/agent-teams)

[설치](#-설치-1분이면-끝) · [동작 방식](#-동작-방식) · [명령 레퍼런스](#-명령-레퍼런스) · [예시](#-예시-pmgrow-같은-iot-프로젝트) · [문서](./CLAUDE.md)

</div>

---

## ✨ 핵심 컨셉

다른 멀티 에이전트 도구들이 **"백엔드 개발자"·"DBA"** 같은 일반 역할을 미리 정의해두는 반면,
**AI Company는 빈 채로 시작**합니다.

`/company-init` 한 줄이면:

1. 프로젝트의 코드·의존성·도메인을 분석합니다
2. **이 프로젝트에만 필요한** 전문가들을 직접 생성합니다
   - PMGrow 같은 IoT 프로젝트 → `mqtt-streaming-engineer`, `mongodb-changestream-specialist`
   - e-커머스 프로젝트 → `cart-checkout-engineer`, `payment-gateway-integrator`
3. 카드 초안을 마크다운으로 작성하여 **회장(=당신)에게 검토 요청**
4. 승인되면 회사 설립 완료

그 다음 `/new-request <자연어 요청>`을 보내면, 적합한 전문가들이 **회의 → 토론 → 합의 → 작업 분배 → 구현 → 기록**의 전 과정을 자동 수행합니다.

```
회장 ─→ 커멘드 센터(리더) ─→ 적합한 전문가들 (병렬)
                                    ↓
                          병렬 분석 → 충돌 감지 → 토론 (최대 2R)
                                    ↓
                          합의 → 작업 분배 → 구현 → 완료 보고
                                    ↓
                          chronicler가 모든 과정 기록
```

---

## 🚀 설치 (1분이면 끝)

### 1단계 — 플러그인 설치

Claude Code 안에서:

```bash
/plugin marketplace add WHS95/ai-company
/plugin install ai-company@ai-company
```

### 2단계 — Agent Teams 활성화

```bash
# 자동 설정 (jq 필요)
bash <(curl -fsSL https://raw.githubusercontent.com/WHS95/ai-company/main/install.sh)
```

또는 `~/.claude/settings.json`에 수동 추가:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "teammateMode": "auto"
}
```

> ⚠️ Claude Code v2.1.32+, jq, tmux(분할창 모드 사용 시) 필요.

### 3단계 — Claude Code 재시작

```bash
# 기존 세션을 종료하고
claude
```

이제 어떤 프로젝트 디렉토리에서든 `/company-init`로 시작할 수 있습니다.

---

## 📺 동작 방식

### 회사 설립 (1회)

```bash
cd ~/projects/my-iot-platform
claude

> /company-init
```

```
📋 회사 구성 제안
━━━━━━━━━━━━━━━━━━━━

📊 프로젝트 분석 요약
• 이름: my-iot-platform
• 도메인: ev-telematics
• 주 스택: NestJS, MongoDB, Redis, MQTT, Grafana
• 핵심 우려: 실시간 데이터 수집(일 40,000+), Change Stream 안정성

🏢 제안 전문가 (8명, + chronicler 공통)

1. nestjs-modular-architect (Opus)
   📌 모듈 경계와 의존성 그래프 설계
   🎯 NestJS 모노레포 + 다중 모듈 도메인 필요

2. mqtt-streaming-engineer (Sonnet)
   📌 MQTT 브로커 기반 IoT 메시지 처리
   🎯 일 40,000+ 차량 텔레메트리 이벤트 처리

3. mongodb-changestream-specialist (Opus)
   📌 Change Stream resume token 영속화, 컬렉션 설계
   🎯 데이터 유실 방지가 최우선

   ... (나머지 5명)

📁 각 카드 본문: .ai-company/agents/_draft/<name>.md

[승인] / [수정 <이름>: <피드백>] / [추가 <역할>] / [제거 <이름>]?

> 승인

✅ 회사 설립 완료.
```

### 신규 요청

```bash
> /new-request 충전소 예약 기능 추가해줘
```

```
📥 요청 접수
유형: 신규 기능 (풀스택)
영향 범위: 백엔드 API + 프론트 + DB
복잡도: 중간
위험도: 중간

🏢 추천 팀 구성 (회사 8명 중 5명 + chronicler)
• nestjs-modular-architect (Opus)        — 도메인 설계
• postgres-reservation-dba (Opus)        — 스키마·동시성
• mqtt-streaming-engineer (Sonnet)       — 실시간 알림
• react-fleet-dashboard-engineer (Sonnet)— 예약 UI
• vehicle-test-engineer (Sonnet)         — 테스트
• chronicler (Haiku)                     — 기록

진행할까요? [예]/[팀 조정]/[아니오]
```

### 모든 과정 가시화

tmux 분할창에서 각 전문가가 작업하는 모습을 실시간 모니터링하고, 필요할 때 직접 개입 가능합니다.

### 칸반 대시보드

```bash
> /dashboard-open
```

브라우저로 열리는 4탭 대시보드(Kanban / Timeline / Meetings / Company)가 5초마다 자동 갱신됩니다. 모든 전문가, 진행 작업, 회의록을 한눈에.

---

## 📚 명령 레퍼런스

### 회사 운영

| 명령 | 설명 |
|------|------|
| `/company-init` | 프로젝트 분석 + 동적 전문가 카드 생성 + 회장 승인 (1회) |
| `/company-rescan` | 프로젝트가 크게 바뀐 후 회사 재구성 |
| `/new-request <내용>` | ★ 신규 요청 처리 (메인 진입점) |
| `/team-status` | 현재 활성 팀 상태 |

### 인사 관리

| 명령 | 설명 |
|------|------|
| `/expert list` | 회사의 전문가 목록 |
| `/expert add <역할>` | 새 전문가 채용 (카드 초안 → 승인) |
| `/expert remove <이름>` | 전문가 해고 (백업 후 _archive로) |
| `/expert edit <이름>` | 카드 수정 |

### 기록 조회

| 명령 | 설명 |
|------|------|
| `/kanban-today` | 오늘의 칸반 (터미널) |
| `/dashboard-open` | 웹 대시보드 (4탭) |
| `/meeting-history [키워드]` | 회의록 검색 |

---

## 🏗 구조

### 플러그인 (글로벌, 가벼움)

```
ai-company/
├── .claude-plugin/
│   ├── plugin.json          # 매니페스트
│   └── marketplace.json     # 마켓플레이스 등록
├── agents/
│   └── chronicler.md        # ★ 유일한 공통 전문가 (사관)
├── commands/                # 8개 슬래시 커맨드
├── hooks/                   # 자동 이벤트 기록
├── dashboard/               # 칸반 대시보드 (단일 HTML)
├── CLAUDE.md                # 커멘드 센터 행동 강령
├── install.sh               # 환경 설정 도우미
└── README.md
```

### 프로젝트 (각자 다른 회사)

```
your-project/
└── .ai-company/
    ├── company-profile.yaml         # 이 프로젝트의 회사 DNA
    ├── agents/                      # 이 프로젝트만의 동적 전문가들
    │   ├── nestjs-modular-architect.md
    │   ├── mqtt-streaming-engineer.md
    │   ├── ... (프로젝트마다 다름)
    │   └── _archive/                # 해고된 전문가 백업
    ├── chronicles/
    │   ├── events.jsonl             # append-only 이벤트 로그
    │   ├── meetings/                # 회의록
    │   └── daily/                   # 일별 칸반 스냅샷
    └── dashboard/
        ├── index.html               # 대시보드 복사본
        └── data.json                # 집계 데이터 (자동 갱신)
```

---

## 🧠 회의 프로토콜

### 회사 설립 (Phase A-F, 1회)

1. **A** 프로젝트 분석
2. **B** `company-profile.yaml` 작성
3. **C** 필요 전문가 도출
4. **D** 카드 초안 `_draft/`에 작성
5. **E** 회장에게 명단·카드 제시
6. **F** 승인 후 `_draft/` → `agents/` 확정

### 신규 요청 (Phase 0-7, 매 요청마다)

1. **0** 요청 분석
2. **1** 팀 구성 제안 + 회장 승인
3. **2** 병렬 분석 (의견 오염 방지)
4. **3** 충돌 감지
5. **4** 타겟 토론 (최대 2R, 미해결 시 회장 에스컬레이션)
6. **5** 작업 분배
7. **6** 구현 모니터링
8. **7** 완료 보고

상세는 [CLAUDE.md](./CLAUDE.md) 참조.

---

## 💡 예시 (PMGrow 같은 IoT 프로젝트)

같은 플러그인이지만, **프로젝트별로 다른 전문가**가 생성됩니다.

| 프로젝트 도메인 | 생성될 수 있는 전문가 (예) |
|--------------|--------------------------|
| EV 텔레메트리 (PMGrow) | `nestjs-modular-architect`, `mqtt-streaming-engineer`, `mongodb-changestream-specialist`, `postgres-reservation-dba`, `grafana-observability-engineer`, `iot-security-reviewer`, `vehicle-test-engineer` |
| e-커머스 | `cart-checkout-engineer`, `payment-gateway-integrator`, `inventory-sync-specialist`, `order-state-machine-designer`, `pci-compliance-reviewer` |
| 금융 (대출 심사) | `credit-scoring-modeler`, `regulatory-compliance-reviewer`, `audit-log-engineer`, `actuarial-tester` |
| AI/ML 플랫폼 | `mlops-pipeline-architect`, `feature-store-specialist`, `model-serving-engineer`, `data-drift-monitor` |

**공통**으로 모든 회사에는 `chronicler`(사관)가 자동 포함됩니다.

---

## 🛣 로드맵

- [ ] **Level 3 기록**: ChromaDB 연동, 과거 회의록 RAG 컨텍스트 주입
- [ ] **카드 학습**: 잘 작동한 카드 패턴을 다음 프로젝트에 참조
- [ ] **인사 평가**: 전문가별 처리 시간·성공률 자동 분석 → 인사 조정 제안
- [ ] **Slack/Discord 알림**: 회의 결과·완료 보고 자동 전달
- [ ] **회사 템플릿 export**: 잘 작동한 구성을 같은 도메인 다른 프로젝트에 빠르게 적용

---

## ⚠️ 알려진 한계

- Agent Teams는 Anthropic의 실험 기능 — API 변경 시 플러그인 수정 필요
- tmux 분할창은 macOS·Linux에서만 안정적 (Windows Terminal/Ghostty 미지원)
- 한 세션당 1팀만 (Agent Teams 자체 제한)
- 팀원은 자기 팀을 만들 수 없음 (중첩 불가)
- 동적 생성된 카드 품질은 LLM의 프로젝트 이해도에 의존 — 회장 검토가 안전망

---

## 🤝 기여

[CONTRIBUTING.md](./CONTRIBUTING.md) 참조. 이슈·PR 환영합니다.

---

## 📜 라이센스

[MIT](./LICENSE)

---

## 👤 만든 사람

[**@WHS95**](https://github.com/WHS95) · [blog](https://coding-daily.tistory.com)

<div align="center">
  <sub>Built with 🏢 by AI Company itself.</sub>
</div>
