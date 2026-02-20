# 🎮 게임 인터페이스 공통 플랫폼
## teams/game/interface/

> 꿈 수집가(Dream Collector)와 던전 기생충(Dungeon Parasite)의 **메타 UI를 통합 관리**하는 폴더입니다.
> 인게임(전투/탐험)을 제외한 모든 UI는 이 플랫폼에서 개발하고 두 게임이 공유합니다.

---

## 📂 폴더 구성

| 파일 | 설명 |
|------|------|
| `COMMON_UI_PLATFORM.md` | **핵심 기획서** — 전체 구조, 테마 시스템, 컴포넌트 계층 |
| `UI_COMPONENTS.md` | **컴포넌트 상세 사양** — 치수, 색상, 상태, 코드 구조 |
| `SCREEN_FLOW.md` | **화면 흐름도** — 전체 네비게이션 맵, 전환 규칙 |
| `IMPLEMENTATION_GUIDE.md` | **구현 가이드** — Figma 작업 순서, Unity/Godot 코드 |

---

## 🔑 핵심 원칙

```
구조(Structure)와 로직(Logic)은 공통   →  두 게임이 공유
에셋(Assets)만 교체                     →  Dream / Dark 테마
```

**개발 효율:** 메타 UI 코드의 **~75% 재사용** → 두 번째 게임 UI 개발 시간 50~60% 단축

---

## 🎨 테마 전환 한눈에 보기

| | 꿈 수집가 | 던전 기생충 |
|-|-----------|------------|
| **테마** | Dream (몽환) | Dark (기생체) |
| **주 색상** | 소프트 블루 `#7B9EF0` | 다크 크림슨 `#8B1A1A` |
| **액센트** | 화이트 파티클 | 청록 기생체 `#00CED1` |
| **폰트** | Nunito (둥근) | Crimson Text (날카로운) |
| **카드 모서리** | 16px (부드러움) | 4px (각짐) |

---

## 📅 현재 상태

- [x] 기획 문서 v1.0 완성 (2026-02-20)
- [ ] Figma 와이어프레임 (이번 주 목표)
- [ ] Figma Hi-Fi 프로토타입 (2주차)
- [ ] Unity/Godot 구현 (3~6주차)

---

## 📎 관련 문서

- [꿈 수집가 GDD](../workspace/design/꿈수집가_GDD.md)
- [던전 기생충 GDD](../workspace/design/던전기생충_GDD.md)
- [마스터 로드맵](../../project-management/MASTER_ROADMAP.md)
