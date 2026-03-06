#!/usr/bin/env python3
"""
Dream Collector - 200 Card Generator
Generates 200 game cards in JSON format based on classification system
"""

import json
import random
from datetime import datetime, timedelta

# Random seed for reproducibility
random.seed(42)

def generate_tarot_cards():
    """Generate 78 Tarot System cards"""
    cards = []
    card_id = 1
    
    # Major Arcana - 22 cards
    major_arcana = [
        ("0", "The Fool", "광대"),
        ("I", "The Magician", "마법사"),
        ("II", "High Priestess", "고위 여사제"),
        ("III", "The Empress", "여제"),
        ("IV", "The Emperor", "황제"),
        ("V", "The Hierophant", "교황"),
        ("VI", "The Lovers", "연인"),
        ("VII", "The Chariot", "전차"),
        ("VIII", "Strength", "힘"),
        ("IX", "The Hermit", "은둔자"),
        ("X", "Wheel of Fortune", "운명의 수레바퀴"),
        ("XI", "Justice", "정의"),
        ("XII", "The Hanged Man", "매달린 남자"),
        ("XIII", "Death", "죽음"),
        ("XIV", "Temperance", "절제"),
        ("XV", "The Devil", "악마"),
        ("XVI", "The Tower", "탑"),
        ("XVII", "The Star", "별"),
        ("XVIII", "The Moon", "달"),
        ("XIX", "The Sun", "태양"),
        ("XX", "Judgement", "심판"),
        ("XXI", "The World", "세계"),
    ]
    
    # Epic (5) + Rare (17)
    epic_indices = [2, 5, 8, 15, 16]  # Death, Devil, Tower, Moon, Judgement
    
    for idx, (roman, name, name_ko) in enumerate(major_arcana):
        rarity = "epic" if idx in epic_indices else "rare"
        card_type = ["attack", "defense", "buff", "debuff", "utility"][idx % 5]
        cost = 4 if rarity == "epic" else 3
        
        cards.append({
            "id": f"card_{str(card_id).zfill(3)}",
            "name": f"{roman}. {name}",
            "nameKo": name_ko,
            "category": "tarot",
            "subcategory": "major",
            "type": card_type,
            "rarity": rarity,
            "cost": cost,
            "costType": "mana",
            "description": f"Major Arcana {roman}: {name}",
            "descriptionKo": f"메이저 아르카나 {roman}: {name_ko}",
            "flavor": f"The fate of destiny turns with {name_ko}",
            "stats": {
                "attack": random.randint(2, 8) if card_type == "attack" else random.randint(1, 3),
                "defense": random.randint(2, 8) if card_type == "defense" else random.randint(1, 3),
                "speed": random.randint(1, 5)
            },
            "effects": [
                {
                    "id": f"effect_{card_id:03d}_1",
                    "type": "damage" if card_type == "attack" else "heal" if card_type == "heal" else "buff",
                    "value": random.randint(3, 8),
                    "target": "single" if card_type == "attack" else "ally",
                    "duration": 1
                }
            ],
            "availability": "gacha",
            "monetization": "free",
            "synergy": [],
            "releaseDate": "2026-03-15",
            "rotationEndDate": None
        })
        card_id += 1
    
    # Court Cards - 16 cards (4 suits × 4 ranks)
    suits = ["Wands", "Cups", "Swords", "Pentacles"]
    ranks = [("King", "왕", "rare"), ("Queen", "여왕", "rare"), 
             ("Knight", "기사", "uncommon"), ("Page", "시종", "uncommon")]
    
    for suit in suits:
        for rank_name, rank_ko, rarity in ranks:
            card_type = ["attack", "defense", "heal", "buff"][suits.index(suit) % 4]
            cost = random.randint(2, 3)
            
            cards.append({
                "id": f"card_{str(card_id).zfill(3)}",
                "name": f"{rank_name} of {suit}",
                "nameKo": f"{suit} {rank_ko}",
                "category": "tarot",
                "subcategory": "court",
                "type": card_type,
                "rarity": rarity,
                "cost": cost,
                "costType": "mana",
                "description": f"Court card: {rank_name} of {suit}",
                "descriptionKo": f"코트 카드: {suit}의 {rank_ko}",
                "flavor": f"The {rank_ko} of {suit} guides your path",
                "stats": {
                    "attack": random.randint(1, 6),
                    "defense": random.randint(1, 6),
                    "speed": random.randint(1, 5)
                },
                "effects": [
                    {
                        "id": f"effect_{card_id:03d}_1",
                        "type": "buff",
                        "value": random.randint(2, 4),
                        "target": "ally",
                        "duration": 2
                    }
                ],
                "availability": "gacha",
                "monetization": "free",
                "synergy": [],
                "releaseDate": "2026-03-15",
                "rotationEndDate": None
            })
            card_id += 1
    
    # Pip Cards - 40 cards (4 suits × 10 ranks)
    pip_ranks = list(range(1, 11))  # Ace (1) to 10
    
    for suit in suits:
        for pip in pip_ranks:
            rarity = "uncommon" if pip in [1, 10] else "common"
            card_type = ["attack", "defense", "heal", "utility"][suits.index(suit) % 4]
            cost = random.randint(1, 3)
            
            pip_names = {1: "Ace", 2: "Two", 3: "Three", 4: "Four", 5: "Five",
                        6: "Six", 7: "Seven", 8: "Eight", 9: "Nine", 10: "Ten"}
            
            cards.append({
                "id": f"card_{str(card_id).zfill(3)}",
                "name": f"{pip_names[pip]} of {suit}",
                "nameKo": f"{suit} {pip_names[pip]}",
                "category": "tarot",
                "subcategory": "pip",
                "type": card_type,
                "rarity": rarity,
                "cost": cost,
                "costType": "mana",
                "description": f"Pip card: {pip_names[pip]} of {suit}",
                "descriptionKo": f"숫자 카드: {suit}의 {pip_names[pip]}",
                "flavor": f"{pip_names[pip]} brings fortune",
                "stats": {
                    "attack": random.randint(1, 4),
                    "defense": random.randint(1, 4),
                    "speed": random.randint(1, 4)
                },
                "effects": [
                    {
                        "id": f"effect_{card_id:03d}_1",
                        "type": "damage",
                        "value": pip,
                        "target": "single",
                        "duration": 1
                    }
                ],
                "availability": "gacha",
                "monetization": "free",
                "synergy": [],
                "releaseDate": "2026-03-15",
                "rotationEndDate": None
            })
            card_id += 1
    
    return cards, card_id

def generate_dream_essence_cards(start_id):
    """Generate 50 Dream Essence cards"""
    cards = []
    card_id = start_id
    
    # Awakening Series - 15 cards
    for i in range(1, 16):
        rarity = ["rare", "uncommon", "common"][(i-1) % 3]
        card_type = ["attack", "defense", "heal"][i % 3]
        cost = random.randint(2, 4)
        
        cards.append({
            "id": f"card_{str(card_id).zfill(3)}",
            "name": f"Nox_Awakening_{i}",
            "nameKo": f"녹스의 각성 {i}",
            "category": "dream_essence",
            "subcategory": "awakening",
            "type": card_type,
            "rarity": rarity,
            "cost": cost,
            "costType": "soul",
            "description": f"Nox awakens further - Stage {i}",
            "descriptionKo": f"녹스가 한층 깨어남 - 단계 {i}",
            "flavor": f"A fragment of lost memory emerges",
            "stats": {
                "attack": random.randint(2, 7),
                "defense": random.randint(1, 6),
                "speed": random.randint(2, 6)
            },
            "effects": [
                {
                    "id": f"effect_{card_id:03d}_1",
                    "type": "buff",
                    "value": i,
                    "target": "ally",
                    "duration": 3
                }
            ],
            "availability": "gacha",
            "monetization": "free",
            "synergy": [f"card_{(start_id + j):03d}" for j in range(1, min(4, i))],
            "releaseDate": "2026-03-15",
            "rotationEndDate": None
        })
        card_id += 1
    
    # Memory Fragments - 15 cards
    for i in range(1, 16):
        rarity = ["rare", "epic", "uncommon"][(i-1) % 3]
        card_type = ["buff", "utility", "debuff"][i % 3]
        cost = random.randint(2, 5)
        
        cards.append({
            "id": f"card_{str(card_id).zfill(3)}",
            "name": f"Forgotten_Dream_{i}",
            "nameKo": f"잊힌 꿈의 조각 {i}",
            "category": "dream_essence",
            "subcategory": "memory",
            "type": card_type,
            "rarity": rarity,
            "cost": cost,
            "costType": "dream",
            "description": f"A memory from the past awakens - Fragment {i}",
            "descriptionKo": f"과거의 기억이 되살아남 - 조각 {i}",
            "flavor": f"What was lost now returns",
            "stats": {
                "attack": random.randint(1, 5),
                "defense": random.randint(1, 5),
                "speed": random.randint(1, 5)
            },
            "effects": [
                {
                    "id": f"effect_{card_id:03d}_1",
                    "type": "buff",
                    "value": random.randint(3, 6),
                    "target": "ally",
                    "duration": 2
                }
            ],
            "availability": "gacha",
            "monetization": "premium",
            "synergy": [],
            "releaseDate": "2026-03-15",
            "rotationEndDate": None
        })
        card_id += 1
    
    # Ethereal Guardians - 15 cards
    for i in range(1, 16):
        rarity = ["uncommon", "rare", "epic"][(i-1) % 3]
        card_type = ["buff", "defense", "utility"][i % 3]
        cost = random.randint(2, 4)
        
        cards.append({
            "id": f"card_{str(card_id).zfill(3)}",
            "name": f"Guardian_{i}",
            "nameKo": f"에테르 수호자 {i}",
            "category": "dream_essence",
            "subcategory": "guardian",
            "type": card_type,
            "rarity": rarity,
            "cost": cost,
            "costType": "mana",
            "description": f"An ethereal guardian aids you - Guardian {i}",
            "descriptionKo": f"신비한 수호자가 당신을 돕습니다 - 수호자 {i}",
            "flavor": f"Protective spirits watch over you",
            "stats": {
                "attack": random.randint(1, 4),
                "defense": random.randint(3, 8),
                "speed": random.randint(1, 4)
            },
            "effects": [
                {
                    "id": f"effect_{card_id:03d}_1",
                    "type": "buff",
                    "value": random.randint(2, 4),
                    "target": "ally",
                    "duration": 2
                }
            ],
            "availability": "gacha",
            "monetization": "free",
            "synergy": [],
            "releaseDate": "2026-03-15",
            "rotationEndDate": None
        })
        card_id += 1
    
    # Lost Stories - 5 cards
    for i in range(1, 6):
        rarity = "legendary" if i <= 2 else "epic"
        cost = 5
        
        cards.append({
            "id": f"card_{str(card_id).zfill(3)}",
            "name": f"Ultimate_Memory_{i}",
            "nameKo": f"궁극의 기억 {i}",
            "category": "dream_essence",
            "subcategory": "lost_stories",
            "type": "utility",
            "rarity": rarity,
            "cost": cost,
            "costType": "dream",
            "description": f"The ultimate memory emerges - Story {i}",
            "descriptionKo": f"궁극의 기억이 나타남 - 이야기 {i}",
            "flavor": f"The greatest truth lies within",
            "stats": {
                "attack": random.randint(5, 10),
                "defense": random.randint(5, 10),
                "speed": random.randint(3, 8)
            },
            "effects": [
                {
                    "id": f"effect_{card_id:03d}_1",
                    "type": "buff",
                    "value": random.randint(5, 10),
                    "target": "ally",
                    "duration": 3
                }
            ],
            "availability": "limited",
            "monetization": "premium",
            "synergy": [],
            "releaseDate": "2026-03-15",
            "rotationEndDate": "2026-06-15"
        })
        card_id += 1
    
    return cards, card_id

def generate_elemental_cards(start_id):
    """Generate 42 Elemental Force cards"""
    cards = []
    card_id = start_id
    
    elements = [
        ("Fire", "불", ["attack", "attack", "buff", "buff", "attack", "buff", "attack", "attack", "debuff", "debuff", "utility"]),
        ("Water", "물", ["defense", "defense", "heal", "heal", "defense", "heal", "defense", "defense", "debuff", "debuff", "utility"]),
        ("Wind", "바람", ["attack", "utility", "attack", "utility", "attack", "utility", "attack", "attack", "debuff", "debuff"]),
        ("Earth", "흙", ["defense", "buff", "defense", "buff", "defense", "buff", "defense", "defense", "debuff", "debuff"]),
    ]
    
    for element, element_ko, types in elements:
        for i, card_type in enumerate(types, 1):
            rarity_choices = ["common", "uncommon", "rare", "rare", "epic"]
            rarity = rarity_choices[random.randint(0, 4)]
            cost = random.randint(2, 4) if rarity != "epic" else 5
            
            cards.append({
                "id": f"card_{str(card_id).zfill(3)}",
                "name": f"{element}_Force_{i}",
                "nameKo": f"{element_ko} 세력 {i}",
                "category": "elemental",
                "subcategory": element.lower(),
                "type": card_type,
                "rarity": rarity,
                "cost": cost,
                "costType": "mana",
                "description": f"{element} elemental force unleashed - {card_type}",
                "descriptionKo": f"{element_ko} 원소의 힘 해방 - {card_type}",
                "flavor": f"The power of {element_ko} flows through you",
                "stats": {
                    "attack": random.randint(2, 8) if card_type == "attack" else random.randint(1, 4),
                    "defense": random.randint(2, 8) if card_type == "defense" else random.randint(1, 4),
                    "speed": random.randint(1, 6)
                },
                "effects": [
                    {
                        "id": f"effect_{card_id:03d}_1",
                        "type": card_type.replace("buff", "buff").replace("attack", "damage"),
                        "value": random.randint(3, 7),
                        "target": "single" if card_type == "attack" else "ally",
                        "duration": 1
                    }
                ],
                "availability": "gacha",
                "monetization": "free",
                "synergy": [],
                "releaseDate": "2026-03-15",
                "rotationEndDate": None
            })
            card_id += 1
    
    return cards, card_id

def generate_celestial_cards(start_id):
    """Generate 30 Celestial Artifacts cards"""
    cards = []
    card_id = start_id
    
    # Zodiac Collection - 12 cards
    zodiacs = [
        ("Aries", "양자리", 1), ("Taurus", "황소자리", 2), ("Gemini", "쌍둥이자리", 3),
        ("Cancer", "게자리", 4), ("Leo", "사자자리", 5), ("Virgo", "처녀자리", 6),
        ("Libra", "천칭자리", 7), ("Scorpio", "전갈자리", 8), ("Sagittarius", "궁수자리", 9),
        ("Capricorn", "염소자리", 10), ("Aquarius", "물병자리", 11), ("Pisces", "물고기자리", 12),
    ]
    
    for zodiac, zodiac_ko, month in zodiacs:
        rarity = random.choice(["rare", "epic", "epic"])
        cost = random.randint(3, 5)
        
        cards.append({
            "id": f"card_{str(card_id).zfill(3)}",
            "name": f"Zodiac_{zodiac}",
            "nameKo": f"황도대 {zodiac_ko}",
            "category": "celestial",
            "subcategory": "zodiac",
            "type": random.choice(["attack", "defense", "buff", "utility"]),
            "rarity": rarity,
            "cost": cost,
            "costType": "dream",
            "description": f"The power of {zodiac} awakens",
            "descriptionKo": f"{zodiac_ko}의 힘이 깨어남",
            "flavor": f"Celestial destiny aligns with the stars",
            "stats": {
                "attack": random.randint(3, 8),
                "defense": random.randint(2, 7),
                "speed": random.randint(2, 6)
            },
            "effects": [
                {
                    "id": f"effect_{card_id:03d}_1",
                    "type": "buff",
                    "value": random.randint(4, 8),
                    "target": "ally",
                    "duration": 2
                }
            ],
            "availability": "limited",
            "monetization": "premium",
            "synergy": [],
            "releaseDate": f"2026-{str(month).zfill(2)}-15",
            "rotationEndDate": f"2026-{str(month+3).zfill(2)}-15"
        })
        card_id += 1
    
    # Lunar Phases - 8 cards
    lunar_phases = [
        ("New_Moon", "신월", 1),
        ("Waxing_Crescent", "초승달", 1),
        ("First_Quarter", "상현달", 2),
        ("Waxing_Gibbous", "증광달", 2),
        ("Full_Moon", "보름달", 3),
        ("Waning_Gibbous", "감광달", 2),
        ("Last_Quarter", "하현달", 2),
        ("Waning_Crescent", "그믐달", 1),
    ]
    
    for phase, phase_ko, power in lunar_phases:
        rarity = random.choice(["uncommon", "rare", "rare"])
        cost = random.randint(2, 4)
        
        cards.append({
            "id": f"card_{str(card_id).zfill(3)}",
            "name": f"Lunar_{phase}",
            "nameKo": f"달의 {phase_ko}",
            "category": "celestial",
            "subcategory": "lunar",
            "type": random.choice(["attack", "defense", "utility"]),
            "rarity": rarity,
            "cost": cost,
            "costType": "dream",
            "description": f"The {phase_ko} grants power level {power}",
            "descriptionKo": f"{phase_ko}가 힘 {power}를 부여함",
            "flavor": f"Lunar cycles govern all mysteries",
            "stats": {
                "attack": random.randint(2, 6),
                "defense": random.randint(2, 6),
                "speed": random.randint(1, 5)
            },
            "effects": [
                {
                    "id": f"effect_{card_id:03d}_1",
                    "type": "buff",
                    "value": power * 2,
                    "target": "ally",
                    "duration": 1
                }
            ],
            "availability": "gacha",
            "monetization": "free",
            "synergy": [],
            "releaseDate": "2026-03-15",
            "rotationEndDate": None
        })
        card_id += 1
    
    # Mythical Creatures - 10 cards
    mythical = [
        ("Phoenix_Reborn", "피닉스", "attack"),
        ("Dragon_Eternal", "용", "attack"),
        ("Basilisk_Petrify", "바실리스크", "debuff"),
        ("Hydra_Regenerate", "하이드라", "heal"),
        ("Kraken_Abyss", "크라켄", "attack"),
        ("Sphinx_Riddle", "스핑크스", "utility"),
        ("Gryphon_Guardian", "그리핀", "defense"),
        ("Minotaur_Labyrinth", "미노타우로스", "attack"),
        ("Pegasus_Flight", "페가수스", "utility"),
        ("Chimera_Chaos", "키메라", "debuff"),
    ]
    
    for mythical_name, mythical_ko, card_type in mythical:
        rarity = random.choice(["epic", "legendary", "epic"])
        cost = 5
        
        cards.append({
            "id": f"card_{str(card_id).zfill(3)}",
            "name": f"Mythical_{mythical_name}",
            "nameKo": f"신화 {mythical_ko}",
            "category": "celestial",
            "subcategory": "mythical",
            "type": card_type,
            "rarity": rarity,
            "cost": cost,
            "costType": "dream",
            "description": f"The legendary {mythical_ko} awakens",
            "descriptionKo": f"전설의 {mythical_ko}가 깨어남",
            "flavor": f"Ancient power beyond mortal comprehension",
            "stats": {
                "attack": random.randint(7, 10),
                "defense": random.randint(5, 10),
                "speed": random.randint(4, 8)
            },
            "effects": [
                {
                    "id": f"effect_{card_id:03d}_1",
                    "type": "damage",
                    "value": random.randint(8, 12),
                    "target": "single",
                    "duration": 1
                }
            ],
            "availability": "limited",
            "monetization": "premium",
            "synergy": [],
            "releaseDate": "2026-03-15",
            "rotationEndDate": "2026-06-15"
        })
        card_id += 1
    
    return cards, card_id

def main():
    print("Generating 200 Dream Collector cards...")
    
    all_cards = []
    
    # Generate cards by category
    tarot_cards, next_id = generate_tarot_cards()
    all_cards.extend(tarot_cards)
    print(f"✓ Generated {len(tarot_cards)} Tarot cards (IDs: 001-078)")
    
    dream_cards, next_id = generate_dream_essence_cards(next_id)
    all_cards.extend(dream_cards)
    print(f"✓ Generated {len(dream_cards)} Dream Essence cards (IDs: 079-128)")
    
    elemental_cards, next_id = generate_elemental_cards(next_id)
    all_cards.extend(elemental_cards)
    print(f"✓ Generated {len(elemental_cards)} Elemental Force cards (IDs: 129-170)")
    
    celestial_cards, next_id = generate_celestial_cards(next_id)
    all_cards.extend(celestial_cards)
    print(f"✓ Generated {len(celestial_cards)} Celestial Artifact cards (IDs: 171-200)")
    
    # Save to JSON
    output_file = "~/Projects/geekbrox/teams/game/workspace/design/dream-collector/data/cards_initial_200.json".replace("~", "/Users/stevemacbook")
    
    import os
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(all_cards, f, ensure_ascii=False, indent=2)
    
    print(f"\n✅ Successfully generated {len(all_cards)} cards")
    print(f"📁 Saved to: {output_file}")
    
    # Print statistics
    rarity_counts = {}
    type_counts = {}
    category_counts = {}
    
    for card in all_cards:
        rarity = card.get('rarity', 'unknown')
        card_type = card.get('type', 'unknown')
        category = card.get('category', 'unknown')
        
        rarity_counts[rarity] = rarity_counts.get(rarity, 0) + 1
        type_counts[card_type] = type_counts.get(card_type, 0) + 1
        category_counts[category] = category_counts.get(category, 0) + 1
    
    print("\n📊 Distribution Statistics:")
    print("\n🎴 By Rarity:")
    for rarity in ["legendary", "epic", "rare", "uncommon", "common"]:
        count = rarity_counts.get(rarity, 0)
        pct = (count / len(all_cards)) * 100
        print(f"  {rarity.capitalize()}: {count} ({pct:.1f}%)")
    
    print("\n⚔️ By Type:")
    for card_type in sorted(type_counts.keys()):
        count = type_counts[card_type]
        pct = (count / len(all_cards)) * 100
        print(f"  {card_type.capitalize()}: {count} ({pct:.1f}%)")
    
    print("\n📂 By Category:")
    for category in ["tarot", "dream_essence", "elemental", "celestial"]:
        count = category_counts.get(category, 0)
        print(f"  {category.capitalize()}: {count}")

if __name__ == "__main__":
    main()
