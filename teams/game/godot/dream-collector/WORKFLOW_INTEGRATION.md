# 통합 워크플로우 - Cursor + Claude Code + Atlas + 팀

**작성**: Atlas (2026-02-25)  
**목적**: 모든 도구/팀원 간 일관성 유지 및 효율적 협업

---

## 📊 시스템 아키텍처

```
┌─────────────────────────────────────────────────────────┐
│                    PROJECT_CONTEXT.md                   │
│              (모든 도구가 읽는 공통 진실)                 │
└──────────────┬─────────────┬────────────────┬───────────┘
               │             │                │
        ┌──────▼─────┐ ┌─────▼──────┐ ┌──────▼─────┐
        │   Cursor   │ │ Claude Code│ │   Atlas    │
        │    IDE     │ │   (VSCode) │ │ (Telegram) │
        └──────┬─────┘ └─────┬──────┘ └──────┬─────┘
               │             │                │
               └─────────────┴────────────────┘
                             │
                    ┌────────▼─────────┐
                    │   CHANGELOG.md   │
                    │ (작업 이력 공유)  │
                    └──────────────────┘
                             │
                    ┌────────▼─────────┐
                    │  Git + Notion    │
                    │ (최종 반영/문서)  │
                    └──────────────────┘
```

---

## 🎯 역할 분담

### 1. Cursor IDE
**강점**: 멀티파일 수정, 대규모 리팩터링, 빠른 반복

**사용 시나리오**:
- 여러 파일 동시 수정
- 프로젝트 전체 구조 변경
- 반복적인 패턴 적용
- 무제한 작업 (로컬 모델)

**예시**:
```
"DreamCardSelection, GameManager, InRun_v4에서
 카드 선택 로직을 전부 리팩터링해줘"
→ 3개 파일 동시 수정
```

---

### 2. Claude Code (VSCode)
**강점**: 대화형 디버깅, Git 통합, 단일 파일 집중

**사용 시나리오**:
- 버그 원인 분석
- 단계별 기능 구현
- Git 작업과 통합
- VSCode 익숙한 사용자

**예시**:
```
@PROJECT_CONTEXT.md
@ui/screens/DreamCardSelection.gd

"이 함수에서 왜 에러가 나는지 한 단계씩 설명해줘"
→ 대화형으로 디버깅
```

---

### 3. Atlas (Telegram)
**강점**: 프로젝트 전략, 아키텍처 설계, Git/Notion 관리

**사용 시나리오**:
- 큰 그림 결정 (아키텍처, 시스템 설계)
- Git push 승인 및 실행
- Notion 업데이트
- 복잡한 멀티시스템 작업
- 모바일에서 빠른 지시

**예시**:
```
Steve → Atlas:
"전투 시스템 전체를 턴제에서 실시간으로 변경하고 싶어"
→ Atlas가 아키텍처 설계 후 Cursor/Claude Code에 작업 분배
```

---

## 🔄 통합 워크플로우

### 시나리오 1: 간단한 버그 수정

```
┌─────────────────────────────────────────────┐
│ 1. Steve discovers bug in Godot             │
└──────────────┬──────────────────────────────┘
               │
        ┌──────▼──────┐
        │   Option A  │ Cursor IDE
        └──────┬──────┘
               │ OR
        ┌──────▼──────┐
        │   Option B  │ Claude Code
        └──────┬──────┘
               │
┌──────────────▼──────────────────────────────┐
│ 2. Fix code locally                         │
│    - Read @PROJECT_CONTEXT.md               │
│    - Modify file                            │
│    - Test in Godot                          │
└──────────────┬──────────────────────────────┘
               │
┌──────────────▼──────────────────────────────┐
│ 3. Document                                 │
│    - Update CHANGELOG.md                    │
│    - Add code comment (if significant)      │
│    - Git commit (local)                     │
└──────────────┬──────────────────────────────┘
               │
┌──────────────▼──────────────────────────────┐
│ 4. Report to Atlas (Telegram)               │
│    "✅ [Cursor/Claude Code] 작업 완료"       │
└──────────────┬──────────────────────────────┘
               │
        ┌──────▼──────┐
        │   Atlas     │ Reviews CHANGELOG
        └──────┬──────┘
               │
┌──────────────▼──────────────────────────────┐
│ 5. (Optional) Git push                      │
│    Steve requests → Atlas executes          │
└─────────────────────────────────────────────┘
```

**시간**: 10-30분  
**비용**: $0.02-0.10 (거의 무료)

---

### 시나리오 2: 새 기능 추가

```
┌─────────────────────────────────────────────┐
│ 1. Steve plans new feature                 │
│    "새 화면 'AchievementScreen' 필요해"      │
└──────────────┬──────────────────────────────┘
               │
        ┌──────▼──────┐
        │   Atlas?    │ Complex design needed?
        └──────┬──────┘
               │
          ┌────┴────┐
          │  YES    │  NO
          │         │
   ┌──────▼──────┐  │
   │   Atlas     │  │ Design architecture
   │  (Telegram) │  │ Create spec
   └──────┬──────┘  │
          │         │
          └────┬────┘
               │
        ┌──────▼──────┐
        │ Cursor OR   │ Implement
        │ Claude Code │
        └──────┬──────┘
               │
┌──────────────▼──────────────────────────────┐
│ 2. Implementation                           │
│    - Read PROJECT_CONTEXT.md                │
│    - Reference similar files                │
│    - Follow coding style                    │
│    - Test incrementally                     │
└──────────────┬──────────────────────────────┘
               │
┌──────────────▼──────────────────────────────┐
│ 3. Documentation                            │
│    - CHANGELOG.md (detailed)                │
│    - Code comments                          │
│    - Git commit                             │
└──────────────┬──────────────────────────────┘
               │
┌──────────────▼──────────────────────────────┐
│ 4. Report + Review                          │
│    Steve → Atlas: "작업 완료"                │
│    Atlas: Reviews changes                   │
└──────────────┬──────────────────────────────┘
               │
┌──────────────▼──────────────────────────────┐
│ 5. Integration                              │
│    - Git push (after approval)              │
│    - Notion GDD update (after approval)     │
│    - Team notification                      │
└─────────────────────────────────────────────┘
```

**시간**: 1-3시간  
**비용**: $0.10-0.50

---

### 시나리오 3: 대규모 리팩터링

```
┌─────────────────────────────────────────────┐
│ 1. Strategic Decision                       │
│    Steve + Atlas: Discuss approach          │
└──────────────┬──────────────────────────────┘
               │
┌──────────────▼──────────────────────────────┐
│ 2. Atlas: Create Plan                       │
│    - Affected files list                    │
│    - Migration strategy                     │
│    - Testing checklist                      │
└──────────────┬──────────────────────────────┘
               │
        ┌──────▼──────┐
        │   Cursor    │ Best for multi-file
        └──────┬──────┘
               │
┌──────────────▼──────────────────────────────┐
│ 3. Incremental Refactoring                  │
│    Phase 1: Core files                      │
│    Phase 2: Dependent files                 │
│    Phase 3: Integration                     │
│    (Test after each phase!)                 │
└──────────────┬──────────────────────────────┘
               │
┌──────────────▼──────────────────────────────┐
│ 4. Documentation (Detailed)                 │
│    - CHANGELOG.md (full breakdown)          │
│    - Migration notes                        │
│    - Breaking changes                       │
│    - Git commits per phase                  │
└──────────────┬──────────────────────────────┘
               │
┌──────────────▼──────────────────────────────┐
│ 5. Team Review                              │
│    Steve + Atlas: Verify all systems work   │
└──────────────┬──────────────────────────────┘
               │
┌──────────────▼──────────────────────────────┐
│ 6. Git Push + Notion Documentation          │
│    (After thorough testing)                 │
└─────────────────────────────────────────────┘
```

**시간**: 3-8시간  
**비용**: $1-5

---

## 📝 공통 문서 시스템

### PROJECT_CONTEXT.md (진실의 원천)
**누가 읽나**: Cursor, Claude Code, Atlas, 팀장, 새 팀원

**내용**:
- 프로젝트 구조
- 코딩 스타일
- 핵심 시스템
- 워크플로우 규칙
- 알려진 이슈

**업데이트**:
- 주요 구조 변경 시
- 새 시스템 추가 시
- 스타일 가이드 변경 시

---

### CHANGELOG.md (작업 이력)
**누가 쓰나**: Cursor, Claude Code, Atlas

**형식**:
```markdown
## [Unreleased]

### Added
- New feature X (Cursor)

### Changed
- Refactored Y (Claude Code)

### Fixed
- Bug Z (Atlas)

## [2026-02-25] - Steve + Atlas
(Completed work)
```

**목적**:
- 팀 동기화
- 변경 이력 추적
- 리뷰 용이성
- 롤백 참고

---

### 도구별 가이드

| 파일 | 대상 | 목적 |
|------|------|------|
| **CURSOR_GUIDE.md** | Cursor 사용자 | 상세 사용법 |
| **CLAUDE_CODE_GUIDE.md** | Claude Code 사용자 | 상세 사용법 |
| **.cursorrules** | Cursor AI | 자동 컨텍스트 |
| **.clinerules** | Claude Code AI | 자동 컨텍스트 |

---

## 🔒 승인 프로세스

### Git Push 승인

```
┌─────────────────────────────────────────────┐
│ Developer (Cursor/Claude Code)              │
│ - 로컬 작업 완료                             │
│ - 테스트 완료                                │
│ - CHANGELOG 업데이트                         │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│ Report to Atlas (Telegram)                  │
│ 🔄 [Git Push 승인 요청]                      │
│ - 커밋 메시지                                │
│ - 변경 파일 목록                             │
│ - 변경 요약                                  │
│ - 테스트 상태                                │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│ Atlas Reviews                               │
│ - CHANGELOG 확인                            │
│ - 변경 내용 검토                             │
│ - 프로젝트 목표 일치 확인                    │
└──────────────┬──────────────────────────────┘
               │
          ┌────┴────┐
          │ OK?     │
     ┌────┴────┐    │
     │  YES    │    │ NO
     │         │    │
     ▼         │    ▼
┌─────────┐   │  ┌──────────┐
│ Push    │   │  │ Request  │
│ Execute │   │  │ Changes  │
└────┬────┘   │  └────┬─────┘
     │        │       │
     └────────┴───────┘
              │
              ▼
┌─────────────────────────────────────────────┐
│ Notify Team (if needed)                     │
└─────────────────────────────────────────────┘
```

---

### Notion 업데이트 승인

```
┌─────────────────────────────────────────────┐
│ Developer Reports                           │
│ 📊 [Notion 업데이트 요청]                    │
│ - 대상 페이지                                │
│ - 추가 내용                                  │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│ Atlas Reviews                               │
│ - 내용 검토                                  │
│ - 포맷 확인                                  │
│ - 문서 정합성 확인                           │
└──────────────┬──────────────────────────────┘
               │
          ┌────┴────┐
          │ OK?     │
     ┌────┴────┐    │
     │  YES    │    │ NO
     │         │    │
     ▼         │    ▼
┌─────────┐   │  ┌──────────┐
│ Update  │   │  │ Request  │
│ Execute │   │  │ Revision │
└─────────┘   │  └──────────┘
              │
              ▼
┌─────────────────────────────────────────────┐
│ Confirm Update                              │
└─────────────────────────────────────────────┘
```

---

## 💡 모범 사례

### 1. 작업 시작 전

**모든 도구 공통**:
```
1. Git pull (최신 코드)
2. PROJECT_CONTEXT.md 읽기
3. CHANGELOG 최신 항목 확인
4. 작업 내용 명확히 정의
```

### 2. 작업 중

**Cursor**:
- Composer로 멀티파일 수정
- .cursorrules 자동 적용 확인

**Claude Code**:
- @PROJECT_CONTEXT.md 명시적 로드
- @-mention으로 파일 참조
- 단계별 진행

**Atlas**:
- 큰 그림 유지
- 아키텍처 가이드
- 팀 동기화

### 3. 작업 후

**모든 도구 공통**:
```
1. CHANGELOG.md 업데이트
2. 코드 주석 (중요 변경만)
3. Git commit (로컬)
4. Godot 테스트
5. 텔레그램 보고
```

---

## 🎓 학습 곡선

### 개발자 온보딩 (신규 팀원)

**Day 1**:
1. PROJECT_CONTEXT.md 정독 (30분)
2. Cursor 또는 Claude Code 설치 (10분)
3. 간단한 수정 시도 (색상 변경 등) (30분)

**Day 2-3**:
1. CURSOR_GUIDE.md 또는 CLAUDE_CODE_GUIDE.md 읽기
2. 버그 수정 연습
3. CHANGELOG 작성 연습

**Day 4-7**:
1. 새 기능 추가
2. 리팩터링 연습
3. Atlas와 협업 연습

**Week 2+**:
- 독립적 작업
- 아키텍처 제안
- 신규 팀원 멘토링

---

## 📊 성공 지표

### 팀 효율성

**측정 항목**:
- 버그 수정 시간: < 1시간
- 새 기능 추가: < 3시간
- CHANGELOG 업데이트율: 100%
- Git history 깔끔함: 높음
- 팀 동기화: 원활

### 비용 최적화

**목표**:
- API 비용: 하루 < $5
- 작업 1회: < $0.50
- 전체 절감: 60-80%

### 코드 품질

**지표**:
- GDScript 에러: 0
- 스타일 일관성: 100%
- 주석 커버리지: > 30%
- Git commit 품질: 높음

---

## 🔧 문제 해결

### 도구 간 컨텍스트 불일치

**증상**: Cursor와 Claude Code가 다른 정보로 작업

**원인**: PROJECT_CONTEXT.md 업데이트 미반영

**해결**:
1. PROJECT_CONTEXT.md 최신화
2. .cursorrules와 .clinerules 동기화
3. 모든 도구 재시작

---

### 문서 중복/충돌

**증상**: CHANGELOG 중복 항목, 누락

**원인**: 여러 도구 동시 작업

**해결**:
1. Git pull 자주 하기
2. 작업 전 최신 CHANGELOG 확인
3. 충돌 시 Atlas가 조정

---

### 승인 병목

**증상**: Git push 대기 시간 길어짐

**원인**: 승인 프로세스 지연

**해결**:
1. 작업 단위 작게 (빠른 승인)
2. 비긴급 작업 묶어서 승인
3. 긴급 작업 명확히 표시

---

## 🚀 미래 확장

### 추가 팀원

**새 개발자 조인 시**:
1. PROJECT_CONTEXT.md 공유
2. 선호 도구 선택 (Cursor/Claude Code)
3. 해당 가이드 읽기
4. Atlas와 첫 작업 함께 진행

### 새 도구 추가

**예: Copilot 추가 시**:
1. PROJECT_CONTEXT.md 확장
2. Copilot 전용 가이드 작성
3. .copilot-rules 파일 생성
4. 통합 워크플로우 업데이트

---

## 📞 연락망

### 주요 채널
- **텔레그램**: Steve PM ↔ Atlas (24시간)
- **CHANGELOG**: 비동기 작업 공유
- **Git**: 코드 동기화
- **Notion**: 문서화

### 긴급 상황
- **크리티컬 버그**: 텔레그램 → Atlas 즉시
- **배포 차단**: Git push 보류, Atlas 컨택
- **아키텍처 의사결정**: Steve + Atlas 논의 후 진행

---

## 🎯 요약

### 핵심 원칙

1. **하나의 진실**: PROJECT_CONTEXT.md
2. **투명한 소통**: CHANGELOG.md
3. **명확한 역할**: Cursor, Claude Code, Atlas
4. **승인 프로세스**: Git push, Notion
5. **지속적 문서화**: 모든 작업 기록

### 성공 공식

```
PROJECT_CONTEXT.md (컨텍스트 공유)
+ 
올바른 도구 선택 (Cursor/Claude Code/Atlas)
+
CHANGELOG.md (투명한 이력)
+
승인 프로세스 (품질 보장)
=
효율적이고 일관된 개발 🎉
```

---

**이 워크플로우를 따르면:**
- ✅ 팀 동기화 완벽
- ✅ 코드 품질 일관성
- ✅ 비용 최적화
- ✅ 빠른 개발 속도
- ✅ 명확한 책임 소재

---

**Last Updated**: 2026-02-25 by Atlas  
**Version**: 1.0  
**Status**: Active
