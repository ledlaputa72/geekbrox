# 🎮 게임팀 스타트업 가이드 (30분)

> 새로운 게임팀 멤버를 위한 30분 온보딩

---

## 📋 30분 안에 해야 할 일

### ⏱️ 0-5분: 팀 이해하기
```
Team Lead: Kim.G (Gemini 2.5 Pro - AI)
프로젝트: Dream Collector (로그라이크 덱빌딩 RPG)
현재 상태: Phase 3 - 전투 시스템 구현 중
```

### ⏱️ 5-10분: 폴더 이해하기

```
teams/game/
├── workspace/        ← 팀 문서 & 기획
│   ├── design/      (게임 기획 문서)
│   ├── planning/    (Phase 3 계획)
│   ├── guides/      (개발 가이드)
│   └── roadmap/     (팀 로드맵)
│
├── godot/           ← 게임 코드 (Cursor IDE로 열기)
│   └── dream-collector/
│       ├── scripts/ (GDScript 코드)
│       ├── scenes/  (화면 설계)
│       └── assets/  (이미지, 음성)
│
└── data/            (게임 데이터)
    ├── cards/
    ├── monsters/
    └── balance/
```

### ⏱️ 10-15분: 문서 읽기

**필수 (지금 읽으세요):**
1. [`teams/game/README.md`](./README.md) - 팀 구조 & 역할
2. [`teams/game/workspace/README.md`](./workspace/README.md) - 폴더 가이드
3. [`teams/game/workspace/planning/PHASE3_NEXT_TASKS.md`](./workspace/planning/PHASE3_NEXT_TASKS.md) - 현재 진행 상황

**강력 추천:**
4. [`teams/game/workspace/guides/CODE_REVIEW.md`](./workspace/guides/CODE_REVIEW.md) - 코드 스타일
5. [`WORKFLOW_INTEGRATION.md`](../../WORKFLOW_INTEGRATION.md) - Telegram-Cursor 워크플로우

### ⏱️ 15-20분: 개발 환경 설정

```bash
# 1. Cursor IDE 열기
open -a "Cursor" ~/Projects/geekbrox/teams/game/godot/dream-collector

# 2. Godot 프로젝트 확인
# Cursor 탭에서: teams/game/godot/dream-collector/project.godot

# 3. Git 클론 확인
cd ~/Projects/geekbrox
git status  # ✅ 모든 파일이 tracked 상태인지 확인
```

### ⏱️ 20-25분: Team Lead 지시 받기

```
Kim.G가 Telegram에서 지시할 때까지 대기

예: "CardDatabase.gd 작성하세요. 
     TAROT_SYSTEM_GUIDE.md 참고, 30개 카드 입력.
     완료 후 PR 생성"

→ 지시를 받으면 시작!
```

### ⏱️ 25-30분: 첫 번째 작업 시작

```
1. 지시받은 파일 열기 (예: CardDatabase.gd)
2. 요구사항 재확인 (TAROT_SYSTEM_GUIDE.md 읽기)
3. 코드 작성 시작
4. 코드 스타일 확인 (CODE_REVIEW.md)
5. Commit & PR 준비
```

---

## 🎯 첫 번째 작업 체크리스트

Team Lead가 지시했을 때:

- [ ] 지시사항을 3번 읽었다
- [ ] 참고 문서를 찾아서 읽었다
- [ ] 요구사항을 완전히 이해했다
- [ ] Cursor IDE에서 파일을 열었다
- [ ] 코드 작성을 시작했다
- [ ] CODE_REVIEW.md의 스타일을 따르고 있다

---

## 💬 소통 방법

### Telegram (Team Lead ↔ 개발자)

**받을 지시:**
```
"Cursor IDE: CardDatabase.gd 작성
- 요구사항: TAROT_SYSTEM_GUIDE.md 참고, 30개 카드
- 완료 후: PR 생성"
```

**해야 할 보고:**
```
✅ 완료: "CardDatabase.gd 완료했습니다: [PR 링크]"
🔄 진행중: "CardDatabase.gd 70% 완료, 내일 완료 예상"
🛑 블로커: "CardDatabase import 오류. 도움 요청합니다."
```

---

## 🔀 기본 워크플로우

```
1. Telegram에서 지시 받기
   ↓
2. Cursor IDE에서 파일 열기
   ↓
3. 코드 작성 (CODE_REVIEW.md 준수)
   ↓
4. 로컬 테스트 (게임 실행해보기)
   ↓
5. Git Commit ("feat: CardDatabase에 30개 카드 추가")
   ↓
6. GitHub PR 생성 (변경사항 설명)
   ↓
7. Telegram에서 Team Lead에 PR 링크 올리기
   ↓
8. Team Lead 리뷰 & 병합
   ↓
9. 다음 태스크 받기
```

---

## 📁 중요 파일 위치

| 파일 | 위치 | 용도 |
|------|------|------|
| **게임 코드** | `teams/game/godot/dream-collector/` | Cursor IDE로 열기 |
| **기획 문서** | `teams/game/workspace/design/` | 요구사항 확인 |
| **코드 스타일** | `teams/game/workspace/guides/CODE_REVIEW.md` | 코드 작성 시 참고 |
| **현재 진행** | `teams/game/workspace/planning/PHASE3_NEXT_TASKS.md` | 무엇을 할지 확인 |
| **팀 로드맵** | `teams/game/workspace/roadmap/` | 장기 계획 |

---

## ❓ 문제 해결

### 문제: "CardDatabase.gd를 찾을 수 없어요"
**해결:**
```
teams/game/godot/dream-collector/scripts/CardDatabase.gd
```

### 문제: "코드 스타일이 뭐예요?"
**해결:**
```
CODE_REVIEW.md를 읽으세요!
teams/game/workspace/guides/CODE_REVIEW.md
```

### 문제: "TAROT_SYSTEM_GUIDE.md를 찾을 수 없어요"
**해결:**
```
teams/game/workspace/design/02_core_design/TAROT_SYSTEM_GUIDE.md
```

### 문제: "PR 생성 방법을 모르겠어요"
**해결:**
```
WORKFLOW_INTEGRATION.md의 "Step 3: PR 생성" 섹션 읽기
WORKFLOW_INTEGRATION.md → 검색: "Step 3"
```

---

## 📞 도움말

**"뭘 해야 하나요?"**
→ Team Lead (Kim.G)에게 Telegram에서 물어보세요

**"코드를 어떻게 작성하나요?"**
→ CODE_REVIEW.md 읽고, 기존 코드 참고 (`teams/game/godot/dream-collector/scripts/`)

**"에러가 났어요"**
→ 에러 메시지를 Team Lead에게 보내세요 (Telegram)

**"이 문서를 못 찾았어요"**
→ 정확한 경로를 위 "파일 위치" 테이블에서 찾으세요

---

## 🎯 다음 30분

1. **지금**: 이 문서 읽기 ✅
2. **다음**: `teams/game/README.md` 읽기
3. **그다음**: Cursor IDE로 게임 프로젝트 열기
4. **마지막**: Team Lead의 첫 지시 받을 준비

---

**준비 완료? 이제 시작하세요! 🚀**

**Last Updated:** 2026-02-28  
**Status:** ✅ READY TO ONBOARD
