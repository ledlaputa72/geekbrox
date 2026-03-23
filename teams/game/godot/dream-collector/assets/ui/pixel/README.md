# Pixel UI — 꿈 탐험 판타지 RPG

고전 픽셀 스타일 UI 기본 세트. Dream Collector 전역에서 사용됩니다.

## 구조

- **panels/** — 패널/모달/툴팁 프레임 (9-patch margin 8)
- **buttons/** — primary, secondary, green, red, purple, disabled (margin 8)
- **bars/** — bar_track, bar_fill_hp/mana/exp/atb (margin 2~4)
- **slots/** — slot_empty, slot_normal, rare, epic, legend (margin 6)
- **tabs/** — tab_bar_frame, tab_active_bg (margin 8)
- **lists/** — list_item_normal, rare, legend (margin 8)
- **cards/** — card_attack, skill, power, curse, card_cost_badge
- **hud/** — hud_frame, hud_pill, section_header
- **badges/** — coin_badge
- **misc/** — divider_gold, divider_subtle

## 플레이스홀더 생성

```bash
python3 tools/generate_pixel_ui_placeholders.py
```

## PixelLab AI 에셋으로 교체

PixelLab MCP로 생성한 에셋이 완료되면 `get_map_object(object_id)`로 상태 확인 후  
다운로드 URL로 PNG를 받아 위 경로에 덮어쓰면 됩니다.  
(에셋은 8시간 후 자동 삭제되므로 완료 시점에 다운로드 필요.)

**다운로드 예 (패널 프레임):**
```bash
curl --fail -o assets/ui/pixel/panels/panel_frame.png \
  "https://api.pixellab.ai/mcp/map-objects/03ce140c-cb3c-4e0c-b467-0a5030c77088/download"
```
생성된 Object ID (대응 파일):  
`03ce140c...` → panels/panel_frame.png, `b0b83ad6...` → buttons/btn_primary.png,  
`db38e2ed...` → btn_secondary, `5c813ed0...` → slots/slot_empty,  
`c20a603f...` → panels/modal_frame, `c4238b41...` → bars/bar_track,  
`ebc2f5c2...` → bars/bar_fill_hp, `341bcefc...` → tabs/tab_bar_frame,  
`feef38c0...` → lists/list_item_normal, `3a861ff6...` → badges/coin_badge
