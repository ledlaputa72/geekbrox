# Combat Integration Plan

## 목표
기존 Combat 화면을 InRun_v3에 완전히 통합

## 구조 매핑

### 기존 Combat.tscn
```
Combat (844px)
├─ TopBar (54px) - Hero HP + Energy
├─ BattleScene (280px) - 가로 액자
│  ├─ Hero (왼쪽)
│  └─ Monsters (오른쪽, 2x2)
├─ CombatLog (100px) - 전투 로그
├─ ActionButtons (110px) - Pass/Auto/Menu
└─ EnergyArea (300px) - 카드 핸드 + 에너지
```

### 새로운 InRun_v3.tscn
```
InRun_v3 (844px)
├─ RunProgressBar (35px)
├─ TopArea (422px) ← BattleScene을 여기에
│  └─ CombatView
│     ├─ TopBar (54px)
│     └─ BattleScene (368px)
└─ BottomArea (377px) ← EnergyArea + Buttons를 여기에
   └─ CombatUI
      ├─ HandContainer (상단 150px)
      ├─ EnergyOrb + DeckInfo (중간 50px)
      ├─ CombatLog (중간 100px)
      └─ ActionButtons (하단 77px)
```

## 작업 단계
1. ✅ 백업 완료
2. InRun_v3.tscn CombatView 재구성
3. InRun_v3.tscn CombatUI 재구성
4. InRun_v3.gd 전투 로직 통합
5. CombatManager/DeckManager 연결
6. 테스트

## 파일 수정
- ui/screens/InRun_v3.tscn
- ui/screens/InRun_v3.gd
