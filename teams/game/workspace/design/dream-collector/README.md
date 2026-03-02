# 📖 Dream Collector - 게임 기획 문서

이 폴더는 'Dream Collector' 프로젝트의 모든 게임 기획 문서를 관리합니다. 문서는 목적과 현재 상태에 따라 다음과 같이 분류되어 있습니다.

### 📂 폴더 구조

-   `01_vision/`
    -   **목적**: 게임의 정체성과 핵심 비전을 정의하는 최상위 문서가 위치합니다. 모든 기획과 개발은 이 문서의 방향성을 따릅니다.
    -   **주요 문서**: `00_INTEGRATED_GAME_CONCEPT.md`

-   `02_core_design/`
    -   **목적**: 게임의 주요 시스템(카드, 타로, 전투 등)을 상세히 설명하는 현재 유효한 핵심 기획 문서입니다.
    -   **주요 문서**: 
        - `CARD_COMBAT_SYSTEM_DESIGN.md`: 카드 전투 시스템 완전 설계 (ATB/TB 통합)
        - `CARD_FUNCTION_DESIGN_GUIDE.md`: 카드 기능 상세 설명
        - `TAROT_SYSTEM_GUIDE.md`: 타로 시스템 설계
    -   **대상**: 기획팀, 개발팀

-   `03_implementation_guides/`
    -   **목적**: 특정 시스템을 어떻게 구현할지에 대한 기술적인 명세와 가이드입니다. 프로토타이핑이나 실제 개발 시 참조합니다.
    -   **combat/ (전투 시스템)**:
        - `COMBAT_UNIFIED_DESIGN_v1.md`: 통합 설계 (ATB & 턴베이스)
        - `COMBAT_ATB_COMPLETE_v1.md`: ATB 전투 상세 설계
        - `COMBAT_TURNBASED_COMPLETE_v1.md`: 턴베이스 전투 상세 설계
        - `REACTION_ATB_v1.md`: ATB 리액션 시스템 상세
        - `REACTION_TURNBASED_v1.md`: TB 리액션 시스템 상세
    -   **대상**: 개발팀 (구현 중)

-   `04_narrative_and_lore/`
    -   **목적**: 게임의 스토리, 캐릭터, 세계관, 설정 등 서사와 관련된 모든 문서가 위치합니다.
    -   **대상**: 기획팀, 시나리오 작가, 아트팀

-   `05_development_tracking/`
    -   **목적**: 프로젝트의 개발 진행 상황, 체크리스트, 기술 결정 사항 등을 추적하는 문서입니다. OpenClaw와 개발팀이 함께 관리합니다.
    -   **주요 문서**: `PROGRESS.md`, `PROGRESS_TRACKER.md`, `DEVELOPMENT_CHECKLIST.md`, `SYSTEM_REQUIREMENTS.md`, `TECH_DECISIONS.md`
    -   **대상**: PM(Atlas), 개발팀

-   `_archive/`
    -   **목적**: 현재는 사용되지 않는 과거 버전의 기획 문서나 컨셉 아이디어를 보관합니다. 기록 보존의 의미를 가집니다.

---
*문서 구조 최종 업데이트: 2026-02-27 by Atlas (dev→design 통합)*
