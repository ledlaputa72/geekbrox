# 픽셀 아트 UI 아이콘 (캐릭터/장비 화면 스타일)

- **스타일**: 두꺼운 검정 아웃라인, 칸칸한 픽셀, 참조 이미지와 동일한 팔레트
- **용도**: 상단 바(설정·다이아·골드·에너지), 스탯(HP·공격·방어), 하단 네비 등

## 현재 포함된 아이콘

| 파일명 | 용도 |
|--------|------|
| icon_settings.png | 설정 (톱니바퀴) |
| icon_diamond.png | 다이아몬드(보석) |
| icon_coin.png | 골드 코인 |
| icon_energy.png | 에너지(번개) |

## 사용 방법

- `UIManager.get_pixel_icon("settings")`, `get_pixel_icon("diamond")` 등으로 로드
- 상단 바·재화 패널에 TextureRect 등으로 표시

## 추가 제작 권장 아이콘

- **icon_heart.png** — HP 스탯
- **icon_sword.png** — 공격력 스탯
- **icon_shield.png** — 방어력 스탯
- **icon_nav_shop.png** — 하단 네비: 상점
- **icon_nav_character.png** — 하단 네비: 캐릭터
- **icon_nav_combat.png** — 하단 네비: 전투
- **icon_nav_upgrade.png** — 하단 네비: 업그레이드
- **icon_list.png** — 상단 바 리스트/클립보드

동일한 픽셀 아트 스타일(64x64, 두꺼운 아웃라인, 투명 배경)로 제작하면 UI와 통일됩니다.
