# Dream Collector - 개발 관리 문서

> Godot 4 개발 진행 관리 및 추적 시스템

**생성일:** 2026-02-24  
**관리자:** Atlas

---

## 📁 문서 구조

이 폴더는 Dream Collector Godot 개발의 진행 상황을 추적하고 관리하기 위한 문서들을 포함합니다.

### 문서 목록

| 문서 | 용도 | 업데이트 빈도 |
|------|------|---------------|
| **[DEVLOG.md](./DEVLOG.md)** | 날짜별 개발 일지 | 매일 |
| **[CHECKLIST.md](./CHECKLIST.md)** | 기능별 체크리스트 | 작업 완료 시 |
| **[PROGRESS_TRACKER.md](./PROGRESS_TRACKER.md)** | 진행 상황 대시보드 | 주 1회 |
| **[TECHNICAL_SUMMARY.md](./TECHNICAL_SUMMARY.md)** | 기술 스택 및 아키텍처 | 필요 시 |
| **[README.md](./README.md)** | 이 문서 (인덱스) | 필요 시 |

---

## 📊 현재 진행 상황 (2026-02-24)

### 전체 진행률
```
████████████░░░░░░░░░░░░░░░░░░░░ 44%
```

### 영역별 진행률
- **UI 화면:** 4/12 (33%)
- **컴포넌트:** 3/5 (60%)
- **시스템:** 3/8 (38%)
- **문서:** 5/8 (63%)

### 최근 완료된 작업
- ✅ 재화 시스템 UI (⚡💎🪙) - 2026-02-24
- ✅ AlertModal 버그 수정 - 2026-02-24
- ✅ Shop 재설계 (IAP + 재화 교환) - 2026-02-23
- ✅ DeckBuilder 화면 - 2026-02-22

---

## 🎯 문서 사용 가이드

### 1. DEVLOG.md (개발 일지)
**용도:** 날짜별 개발 활동 기록

**사용 시점:**
- 매일 개발 종료 시 작성
- 완료된 작업, 발견된 버그, Git 커밋 기록

**작성 예시:**
```markdown
## 📅 2026-02-24 (월)

### ✅ 완료된 작업
- 재화 시스템 UI 구현
- AlertModal 버그 수정

### 🐛 발견된 이슈
- z-order 문제 → 해결 완료

### 📝 Git 커밋
- `d5dbc5c`: Godot UI 구현
```

---

### 2. CHECKLIST.md (체크리스트)
**용도:** 기능별 완료 여부 추적

**사용 시점:**
- 작업 시작 시 체크리스트 확인
- 작업 완료 시 체크박스 업데이트

**체크박스 규칙:**
```markdown
- [ ] 미완료
- [x] 완료 ✅ YYYY-MM-DD
```

**카테고리:**
- UI 화면 (12개)
- 컴포넌트 (5개)
- 시스템 (8개)
- 문서 (8개)
- 게임 콘텐츠 (3개)

---

### 3. PROGRESS_TRACKER.md (진행 상황 추적)
**용도:** 실시간 진행 상황 대시보드

**사용 시점:**
- 주 1회 업데이트 (금요일 저녁)
- 마일스톤 변경 시
- 긴급 상황 발생 시

**포함 내용:**
- 전체 진행률 바
- 주간 진행 현황
- 누적 통계
- 마일스톤 진행 상황
- 속도 지표
- 리스크 및 이슈

---

### 4. TECHNICAL_SUMMARY.md (기술 요약)
**용도:** 기술 스택 및 아키텍처 문서

**사용 시점:**
- 새로운 시스템 추가 시
- 아키텍처 변경 시
- 신규 개발자 온보딩 시

**포함 내용:**
- 기술 스택
- 프로젝트 구조
- 핵심 시스템 아키텍처
- 디자인 시스템
- 개발 도구
- 빌드 및 배포

---

## 🔄 업데이트 워크플로우

### 일일 업데이트
1. **개발 작업 수행**
2. **DEVLOG.md 업데이트** (완료된 작업 기록)
3. **CHECKLIST.md 업데이트** (체크박스 체크)
4. **Git 커밋 & 푸시**

### 주간 업데이트 (금요일)
1. **PROGRESS_TRACKER.md 업데이트**
   - 주간 진행 현황 추가
   - 전체 진행률 갱신
   - 다음 주 계획 작성
2. **Telegram 주간 리포트 발송**

### 마일스톤 완료 시
1. **모든 문서 최종 검토**
2. **TECHNICAL_SUMMARY.md 업데이트** (필요 시)
3. **Notion 업데이트**
4. **GitHub 릴리즈 노트 작성**

---

## 📈 통계 및 지표

### 현재 지표 (2026-02-24)
- **총 개발 시간:** 44시간 (7일)
- **코드 라인 수:** ~6,500줄
- **문서 라인 수:** ~2,500줄
- **커밋 수:** 4개
- **완료 작업:** 16개/36개

### 목표 지표
- **주간 개발 시간:** 40시간
- **주간 커밋 수:** 5개+
- **작업 완료 속도:** 4 작업/주
- **문서 커버리지:** 80%+

---

## 🎯 마일스톤 로드맵

### M1: 프로토타입 (2026-02-20 ~ 2026-03-15)
- **목표:** 12개 UI 화면 완성, 핵심 시스템 구현
- **진행률:** 44%
- **예상 완료:** 2026-03-10 (5일 앞당김)

### M2: 알파 버전 (2026-03-16 ~ 2026-04-30)
- **목표:** 게임 콘텐츠 완성, 밸런싱 1차 패스
- **진행률:** 0%

### M3: 베타 버전 (2026-05-01 ~ 2026-06-30)
- **목표:** 아트/사운드 통합, 내부 테스트
- **진행률:** 0%

### M4: 런칭 (2026-07-01 ~)
- **목표:** 스토어 출시, 마케팅

---

## 🔗 관련 문서 링크

### 프로젝트 문서
- [GDD v2.0](../../workspace/design/GDD_Dream_Collector_v2.md)
- [프로토타입 룰북](../../workspace/prototype/PROTOTYPE_RULEBOOK.md)
- [카드 디자인](../../workspace/prototype/CARD_DESIGNS.md)

### Godot 구현 가이드
- [Godot UI Workflow](../GODOT_UI_WORKFLOW.md)
- [Implementation Guide](../IMPLEMENTATION_GUIDE.md)
- [Quick Start](../QUICK_START.md)

### 외부 리소스
- [GitHub Repo](https://github.com/ledlaputa72/geekbrox)
- [Figma Design](https://www.figma.com/design/Wo1MKHvWNE9Yl5bsmD4pkK/)
- [Notion 프로젝트 페이지](https://notion.so/30dea4274fb6815780f8d36c695428a9)

---

## ⚙️ 개발 환경 설정

### 필수 도구
- Godot 4.x (최신 stable)
- Git
- VS Code (또는 선호하는 에디터)

### 권장 VS Code 확장
- `godot-tools`: GDScript 지원
- `markdown-all-in-one`: Markdown 편집
- `gitlens`: Git 시각화

### 초기 설정
```bash
cd ~/Projects/geekbrox/teams/game/godot/dream-collector
godot --editor project.godot
```

---

## 📞 문의 및 지원

### 담당자
- **프로젝트 매니저:** Steve PM
- **개발 리드:** Atlas (AI Assistant)

### 연락처
- Telegram: Steve PM
- GitHub Issues: [geekbrox/issues](https://github.com/ledlaputa72/geekbrox/issues)

---

## 📝 변경 이력

| 날짜 | 변경 내용 | 작성자 |
|------|-----------|--------|
| 2026-02-24 | 개발 관리 문서 시스템 구축 | Atlas |
| 2026-02-24 | DEVLOG, CHECKLIST, PROGRESS_TRACKER, TECHNICAL_SUMMARY 생성 | Atlas |

---

**마지막 업데이트:** 2026-02-24 15:45 PST  
**버전:** 1.0
