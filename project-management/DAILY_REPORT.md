# 일일 아침 보고 (Daily Morning Report)

**설정일:** 2026-02-20  
**담당:** Atlas (PM)  
**자동화:** OpenClaw Cron Job

---

## 📋 개요

매일 아침 9시 (PST/PDT)에 자동으로 텔레그램으로 일일 보고서가 전송됩니다.

**Cron Job ID:** `46d98aa5-860d-4532-9f9c-173acce663c4`  
**스케줄:** 매일 09:00 (America/Los_Angeles)  
**상태:** ✅ 활성화

---

## 📊 보고 내용

### 1. 📅 오늘 일정 (Today's Plan)
- 오늘 진행할 작업 목록
- 우선순위별 정리 (P0 → P1 → P2)
- 예상 소요 시간

### 2. ✅ 어제 완료 (Yesterday's Done)
- 전날 완료된 작업 요약
- 주요 산출물
- 완료 항목이 없으면 "없음" 표시

### 3. ⚠️ 지연 및 특이사항 (Delays & Issues)
- 일정 대비 지연 작업
- 블로커 또는 이슈
- 새로운 요청/변경사항
- 문제 없으면 "없음" 표시

### 4. 📊 전체 진행 현황 (Overall Progress)
- 현재 스프린트 완료율
- 이번 주 목표 대비 진행 상황
- 다음 마일스톤까지 남은 일정

---

## 🔧 작동 방식

### 자동화 프로세스
1. **매일 09:00 PST/PDT**: Cron job 트리거
2. **Isolated Session**: 별도 에이전트 세션에서 보고서 작성
3. **파일 참조**:
   - `~/Projects/geekbrox/project-management/tasks/IN_PROGRESS.md`
   - `~/Projects/geekbrox/project-management/tasks/DONE.md`
   - `~/Projects/geekbrox/project-management/sprints/2026-W08-sprint.md`
   - `~/.openclaw/workspace/memory/YYYY-MM-DD.md`
4. **전달**: 텔레그램으로 자동 전송 (announce mode)

---

## 📝 보고서 형식

**길이:** 500-800자 목표  
**톤:** 간결하고 명확, 액션 중심  
**스타일:** 이모지 사용으로 가독성 향상

**예시:**
```
📅 오늘 일정
🔴 경쟁작 플레이 (Slay the Spire) - 3h
🟠 종이 프로토타입 설계 - 2h
🟡 블로그 포스트 발행 - 1h

✅ 어제 완료
- GDD 한글 번역 완료 (32KB)
- PM 시스템 구축 (9개 문서)

⚠️ 지연/특이사항
없음

📊 진행 현황
스프린트 W08: 65% 완료
다음 마일스톤: M1.3 (39일 남음)
```

---

## 🔄 관리

### 보고서 확인
- **텔레그램**: 매일 아침 자동 수신
- **로그**: Cron job runs 확인 가능

### 일시 중지/재개
```bash
# OpenClaw CLI 사용
openclaw cron disable <job-id>
openclaw cron enable <job-id>
```

### 삭제
```bash
openclaw cron remove <job-id>
```

---

## 📌 참고사항

### 첫 실행
- **예정일:** 2026-02-21 (금) 09:00 PST

### 보고서 품질
- Atlas가 자동으로 최신 데이터 수집
- 파일 업데이트 시 자동 반영
- 주간 스프린트 파일 변경 시 (예: W09) 자동 적응

### 문제 해결
- 보고서 미수신 시: Cron job 상태 확인
- 내용 누락 시: 소스 파일 (IN_PROGRESS.md 등) 확인
- 타이밍 조정 필요 시: Cron job 업데이트

---

## 🛠️ 추가 기능 (향후)

- [ ] 주간 보고서 (매주 금요일)
- [ ] 월간 회고 (매월 말)
- [ ] 마일스톤 알림 (D-7, D-3, D-1)
- [ ] 블로커 자동 에스컬레이션

---

_Automated by Atlas | GeekBrox Project Management_
