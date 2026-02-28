# Dream Collector - Cursor IDE Quick Start

**이 파일은 Cursor IDE로 작업하는 개발자를 위한 빠른 시작 가이드입니다.**

---

## 🚀 빠른 시작 (3분)

### 1. 프로젝트 열기
```bash
cd ~/Projects/geekbrox/teams/game/godot/dream-collector
cursor .
```

### 2. 첫 작업 시도
**Cursor Composer 열기**: `Cmd+I`

**입력 예시**:
```
DreamCardSelection.gd의 카드 애니메이션 속도를 0.3초로 변경해줘
```

**Cursor가 자동으로**:
- 파일 찾기
- 해당 함수 찾기
- Tween duration 수정
- 관련 코드 업데이트

### 3. 테스트
```bash
# Godot 에디터 열기
open project.godot
```

### 4. 문서화
작업 완료 후:
1. `CHANGELOG.md` 업데이트
2. 텔레그램으로 Atlas/Steve에게 보고

---

## 📚 주요 문서

| 문서 | 용도 | 위치 |
|------|------|------|
| **`.cursorrules`** | Cursor AI 컨텍스트 (자동 작동) | 프로젝트 루트 |
| **`CURSOR_GUIDE.md`** | 상세 사용 가이드 | 프로젝트 루트 |
| **`CHANGELOG.md`** | 변경 사항 기록 | 프로젝트 루트 |
| **`README_CURSOR.md`** | 이 파일 (빠른 시작) | 프로젝트 루트 |

---

## 🎯 자주 하는 작업

### 코드 수정
```
Cmd+I → "파일X의 함수Y를 Z로 수정해줘"
```

### 버그 수정
```
Cmd+L → "파일X에서 에러 발생: [에러 메시지 복사]"
```

### 새 기능 추가
```
Cmd+I → "새 화면 'AchievementScreen' 만들어줘
         - BottomNav 포함
         - 업적 목록 표시
         - 기존 패턴 따라서"
```

### 코드 설명
```
Cmd+L → "InRun_v4.gd의 switch_to_combat() 함수 설명해줘"
```

---

## ⚠️ 주의사항

### ✅ DO
- Git commit 자주 하기 (로컬)
- CHANGELOG.md 업데이트하기
- 작업 후 Godot에서 테스트하기
- Atlas/Steve에게 보고하기

### ❌ DON'T
- Git push 전 승인 없이 push 하지 않기
- Godot 열린 상태에서 .tscn 파일 수정하지 않기
- CHANGELOG 업데이트 없이 작업 완료하지 않기

---

## 📞 도움이 필요할 때

1. **Cursor에게 먼저 물어보기**:
   ```
   Cmd+L → "이 에러 어떻게 고치지?"
   ```

2. **문서 확인**:
   - `CURSOR_GUIDE.md` 열어서 검색 (Cmd+F)

3. **Atlas에게 텔레그램으로 연락**:
   ```
   "Cursor에서 작업 중 문제 발생: [상세 설명]"
   ```

---

## 🔗 관련 링크

- **프로젝트 루트**: `~/Projects/geekbrox/teams/game/godot/dream-collector/`
- **주요 스크립트**: `scripts/`, `autoload/`
- **UI 화면**: `ui/screens/`
- **UI 컴포넌트**: `ui/components/`

---

## ✨ 팁

**Cursor를 처음 사용한다면**:
1. `CURSOR_GUIDE.md` 전체 읽기 (10분)
2. 간단한 수정부터 시도 (색상, 텍스트 변경 등)
3. 점점 복잡한 작업으로 확장

**익숙해졌다면**:
- Composer (Cmd+I) 적극 활용
- 여러 파일 동시 수정
- 리팩터링, 새 기능 추가

---

**Happy Coding with Cursor! 🎮✨**
