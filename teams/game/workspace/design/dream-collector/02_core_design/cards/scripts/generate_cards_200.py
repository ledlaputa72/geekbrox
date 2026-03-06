#!/usr/bin/env python3
"""
Dream Collector - 200 Card Generator (v2.0)
Generates 200 cards based on CARD_TYPE_SYSTEM_v2.md

Card Composition:
- ATTACK (42): ATK-SGL(15), ATK-MLT(12), ATK-RCK(5), ATK-CMP(10)
- SKILL (60): SKL-GRD(20), SKL-PAR(20), SKL-DOD(20)
- POWER (50): PWR-DRW(12), PWR-ATK(15), PWR-DEF(12), PWR-SUS(11)
- CURSE (48): CRS-STA(12), CRS-SPD(12), CRS-PEN(12), CRS-RSK(12)
"""

import json
import random

random.seed(42)

# ============================================================================
# NAMES AND DESCRIPTIONS
# ============================================================================

ATTACK_SGL_NAMES = [
    ("검의 에이스", "Ace of Blades", "단일 적에게 직접 데미지"),
    ("번개", "Lightning Bolt", "번개로 단일 적을 타격"),
    ("칼날", "Sharp Blade", "날카로운 칼날 공격"),
    ("강타", "Mighty Strike", "강력한 타격"),
    ("태양", "The Sun", "태양의 빛으로 공격"),
    ("황제", "The Emperor", "황제의 명령으로 공격"),
    ("마검사", "Mystical Swordsman", "마법 검사의 공격"),
    ("심장 관통", "Heart Pierce", "심장을 관통하는 공격"),
    ("별의 검", "Starlight Blade", "별빛 검"),
    ("중력", "Gravity", "중력 공격"),
    ("신성 절단", "Holy Cut", "신성한 절단"),
    ("영혼 박탈", "Soul Drain", "영혼을 빨아들이는 공격"),
    ("최후의 일격", "Final Blow", "최후의 결정타"),
    ("무한 나선", "Infinite Spiral", "무한한 나선 공격"),
    ("궁극의 분노", "Ultimate Wrath", "궁극의 분노"),
]

ATTACK_MLT_NAMES = [
    ("이중 베기", "Double Slash", "두 번의 베기"),
    ("마법사", "Magician", "마법 공격"),
    ("악마", "Devil", "악마의 힘"),
    ("폭발", "Explosion", "폭발 공격"),
    ("쌍검술", "Dual Wield", "쌍검 공격"),
    ("광역 번개", "Chain Lightning", "연쇄 번개"),
    ("바람 가르기", "Wind Slash", "바람을 가르는 공격"),
    ("화염 폭주", "Inferno Rush", "화염 폭주"),
    ("다중 절단", "Multi Cut", "다중 절단"),
    ("메테오", "Meteor", "유성 공격"),
    ("전체 마법", "Mass Magic", "전체 마법"),
    ("멸망의 검", "Sword of Ruin", "멸망의 검"),
]

ATTACK_RCK_NAMES = [
    ("탑", "The Tower", "탑이 무너지는 공격"),
    ("심연의 손길", "Abyss Hand", "심연에서 솟아나는 손"),
    ("저주의 경로", "Cursed Path", "저주의 길"),
    ("최후의 모든것", "All or Nothing", "모든 것을 건 공격"),
    ("죽음의 춤", "Dance of Death", "죽음의 춤"),
]

ATTACK_CMP_NAMES = [
    ("세계", "The World", "세계를 아우르는 공격"),
    ("별", "The Star", "별의 가호"),
    ("지혜의 일격", "Wisdom Strike", "지혜로운 일격"),
    ("회복 참격", "Recovery Slash", "회복하며 공격"),
    ("사냥꾼의 표식", "Hunter's Mark", "사냥꾼의 표식"),
    ("거울 반사", "Mirror Reflection", "거울 반사"),
    ("축복의 검", "Blessed Sword", "축복받은 검"),
    ("영혼의 인도", "Soul Guide", "영혼의 인도"),
    ("차원의 베임", "Dimension Slash", "차원을 베는 공격"),
    ("신의 심판", "Divine Judgment", "신의 심판"),
]

SKILL_GRD_NAMES = [
    ("방패의 왕", "Shield King", "왕의 방패"),
    ("철벽", "Iron Wall", "철벽 방어"),
    ("여황제", "The Empress", "여황제의 보호"),
    ("교황", "The Hierophant", "교황의 축복"),
    ("달", "The Moon", "달빛 방어"),
    ("정의", "Justice", "정의의 방패"),
    ("은둔자", "The Hermit", "은둔자의 지혜"),
    ("절제", "Temperance", "절제하는 방어"),
    ("큰 방패", "Great Shield", "큰 방패"),
    ("돌 갑옷", "Stone Armor", "돌 갑옷"),
    ("수호자의 벽", "Guardian Wall", "수호자의 벽"),
    ("강철 가슴", "Steel Chest", "강철 가슴"),
    ("황금 보호", "Golden Protection", "황금 보호"),
    ("빛의 방패", "Light Shield", "빛의 방패"),
    ("마법 보호", "Magical Barrier", "마법 보호"),
    ("반사 방패", "Reflection Shield", "반사 방패"),
    ("완벽 수비", "Perfect Defense", "완벽한 수비"),
    ("흙의 벽", "Earth Wall", "흙의 벽"),
    ("얼음 갑옷", "Ice Armor", "얼음 갑옷"),
    ("나무 보호", "Wood Protection", "나무 보호"),
]

SKILL_PAR_NAMES = [
    ("꿈의 쳐내기", "Dream Parry", "꿈처럼 패링"),
    ("반사의 순간", "Moment of Reflection", "반사의 순간"),
    ("각성의 쳐내기", "Awakening Parry", "각성의 패링"),
    ("달빛 반격", "Moonlight Counter", "달빛 반격"),
    ("완벽한 방어", "Perfect Guard", "완벽한 방어"),
    ("검의 춤", "Blade Dance", "검의 춤"),
    ("반응의 기술", "Reaction Art", "반응의 기술"),
    ("신속한 패링", "Swift Parry", "신속한 패링"),
    ("정확한 방어", "Precise Guard", "정확한 방어"),
    ("강철의 의지", "Iron Will", "강철의 의지"),
    ("수호의 일격", "Guardian Strike", "수호의 일격"),
    ("반격의 기술", "Counter Art", "반격의 기술"),
    ("마법 반사", "Magic Reflection", "마법 반사"),
    ("별빛 패링", "Starlight Parry", "별빛 패링"),
    ("영혼의 방어", "Soul Defense", "영혼의 방어"),
    ("본능의 회피", "Instinct Dodge", "본능의 회피"),
    ("신속한 반응", "Quick Response", "신속한 반응"),
    ("절대 방어", "Absolute Defense", "절대 방어"),
    ("빛의 검", "Light Blade", "빛의 검"),
    ("운명의 회피", "Destiny Evade", "운명의 회피"),
]

SKILL_DOD_NAMES = [
    ("꿈의 스텝", "Dream Step", "꿈의 스텝"),
    ("잔상", "Afterimage", "잔상"),
    ("황혼의 도약", "Twilight Leap", "황혼의 도약"),
    ("연막", "Smoke Screen", "연막"),
    ("반보 앞으로", "Half Step Forward", "반보 앞으로"),
    ("빠른 발걸음", "Quick Step", "빠른 발걸음"),
    ("그림자 이동", "Shadow Movement", "그림자 이동"),
    ("갑작스러운 회피", "Sudden Dodge", "갑작스러운 회피"),
    ("신속한 몸놀림", "Agile Movement", "신속한 몸놀림"),
    ("바람 같은 움직임", "Wind-like Movement", "바람 같은 움직임"),
    ("물 같은 흐름", "Water Flow", "물 같은 흐름"),
    ("갈지자 이동", "Zigzag Movement", "갈지자 이동"),
    ("소용돌이", "Whirlwind", "소용돌이"),
    ("빛의 도약", "Light Leap", "빛의 도약"),
    ("차원 이동", "Dimensional Shift", "차원 이동"),
    ("시간 왜곡", "Time Distortion", "시간 왜곡"),
    ("공간 벗어나기", "Space Escape", "공간 벗어나기"),
    ("환상의 몸", "Illusory Body", "환상의 몸"),
    ("완벽한 회피", "Perfect Dodge", "완벽한 회피"),
    ("운명의 회피", "Destiny Evade", "운명의 회피"),
]

POWER_DRW_NAMES = [
    ("바보", "The Fool", "바보의 여행"),
    ("달의 환영", "Moon Mirage", "달의 환영"),
    ("지식의 원천", "Source of Knowledge", "지식의 원천"),
    ("행운의 별", "Lucky Star", "행운의 별"),
    ("카드의 무게", "Card Weight", "카드의 무게"),
    ("꿈의 흐름", "Dream Flow", "꿈의 흐름"),
    ("영감", "Inspiration", "영감"),
    ("새로운 시작", "New Beginning", "새로운 시작"),
    ("무한의 문", "Gate of Infinity", "무한의 문"),
    ("별들의 속삭임", "Stars' Whisper", "별들의 속삭임"),
    ("사고의 이동", "Thought Movement", "사고의 이동"),
    ("기억의 회복", "Memory Recovery", "기억의 회복"),
]

POWER_ATK_NAMES = [
    ("힘", "Strength", "힘의 증가"),
    ("민첩", "Agility", "민첩의 증가"),
    ("투지", "Fighting Spirit", "투지"),
    ("격정", "Fervor", "격정"),
    ("전투 본능", "Battle Instinct", "전투 본능"),
    ("전사의 외침", "Warrior's Cry", "전사의 외침"),
    ("신성한 빛", "Holy Light", "신성한 빛"),
    ("마력 상승", "Mana Surge", "마력 상승"),
    ("혈기", "Bloodlust", "혈기"),
    ("폭발의 선제", "Explosion Prelude", "폭발의 선제"),
    ("공격의 광채", "Attack Radiance", "공격의 광채"),
    ("무기의 깨어남", "Weapon Awakening", "무기의 깨어남"),
    ("승리의 가능성", "Possibility of Victory", "승리의 가능성"),
    ("무한의 힘", "Infinite Power", "무한의 힘"),
    ("궁극의 힘", "Ultimate Power", "궁극의 힘"),
]

POWER_DEF_NAMES = [
    ("회복의 마법", "Recovery Magic", "회복의 마법"),
    ("집중력", "Concentration", "집중력"),
    ("수호의 마법", "Protection Magic", "수호의 마법"),
    ("신성한 갑옷", "Holy Armor", "신성한 갑옷"),
    ("흙의 보호", "Earth Protection", "흙의 보호"),
    ("물의 치유", "Water Healing", "물의 치유"),
    ("생명력", "Vitality", "생명력"),
    ("회복력", "Recovery Power", "회복력"),
    ("방어력 강화", "Defense Enhancement", "방어력 강화"),
    ("체질 개선", "Body Improvement", "체질 개선"),
    ("재생", "Regeneration", "재생"),
    ("신체 강화", "Body Fortification", "신체 강화"),
]

POWER_SUS_NAMES = [
    ("축복", "Blessing", "축복"),
    ("재생", "Regeneration", "재생"),
    ("마법 강화", "Magic Enhancement", "마법 강화"),
    ("공격의 연계", "Attack Chain", "공격의 연계"),
    ("방어의 순환", "Defense Cycle", "방어의 순환"),
    ("완벽한 균형", "Perfect Balance", "완벽한 균형"),
    ("전투 흐름", "Battle Flow", "전투 흐름"),
    ("승리의 의지", "Will to Victory", "승리의 의지"),
    ("무한 순환", "Infinite Cycle", "무한 순환"),
    ("영혼의 공명", "Soul Resonance", "영혼의 공명"),
    ("운명의 실", "Thread of Destiny", "운명의 실"),
]

CURSE_STA_NAMES = [
    ("약화", "Weakness", "약화"),
    ("혼란", "Confusion", "혼란"),
    ("둔화", "Dullness", "둔화"),
    ("무기력", "Lethargy", "무기력"),
    ("두려움", "Fear", "두려움"),
    ("절망", "Despair", "절망"),
    ("중독", "Poison", "중독"),
    ("타격", "Blow", "타격"),
    ("마비", "Paralysis", "마비"),
    ("냉기", "Chill", "냉기"),
    ("화상", "Burn", "화상"),
    ("출혈", "Bleeding", "출혈"),
]

CURSE_SPD_NAMES = [
    ("속박", "Restraint", "속박"),
    ("연쇄", "Chain", "연쇄"),
    ("지연", "Delay", "지연"),
    ("정지", "Stop", "정지"),
    ("경화", "Petrification", "경화"),
    ("동결", "Freezing", "동결"),
    ("침묵", "Silence", "침묵"),
    ("봉인", "Seal", "봉인"),
    ("충격", "Shock", "충격"),
    ("기절", "Stun", "기절"),
    ("수면", "Sleep", "수면"),
    ("혼수", "Coma", "혼수"),
]

CURSE_PEN_NAMES = [
    ("방어 무시", "Defense Ignore", "방어 무시"),
    ("약화 강화", "Weakness Enhancement", "약화 강화"),
    ("저항 파괴", "Resistance Break", "저항 파괴"),
    ("약점 공략", "Weak Point Exploit", "약점 공략"),
    ("깊은 상처", "Deep Wound", "깊은 상처"),
    ("치명상", "Fatal Wound", "치명상"),
    ("심부 손상", "Internal Damage", "심부 손상"),
    ("마력 흡수", "Mana Drain", "마력 흡수"),
    ("생명 흡수", "Life Drain", "생명 흡수"),
    ("영혼 침식", "Soul Erosion", "영혼 침식"),
    ("절대 약화", "Absolute Weakness", "절대 약화"),
    ("완전 파괴", "Total Destruction", "완전 파괴"),
]

CURSE_RSK_NAMES = [
    ("취약", "Vulnerability", "취약"),
    ("분노 유발", "Provoke Anger", "분노 유발"),
    ("자해 유발", "Self Harm", "자해 유발"),
    ("위험 증폭", "Danger Amplification", "위험 증폭"),
    ("악의", "Malice", "악의"),
    ("저주", "Curse", "저주"),
    ("타락", "Corruption", "타락"),
    ("광기", "Madness", "광기"),
    ("절망감", "Despair", "절망감"),
    ("죽음의 예감", "Death Premonition", "죽음의 예감"),
    ("최후의 댓글", "Final Comment", "최후의 댓글"),
    ("무한 고통", "Infinite Pain", "무한 고통"),
]

# ============================================================================
# CARD GENERATION
# ============================================================================

def generate_all_cards():
    cards = []
    card_id = 1
    
    # ATTACK cards (42)
    cards.extend(generate_attack_cards(card_id, "SGL", ATTACK_SGL_NAMES, 15))
    card_id += 15
    
    cards.extend(generate_attack_cards(card_id, "MLT", ATTACK_MLT_NAMES, 12, is_aoe=True))
    card_id += 12
    
    cards.extend(generate_attack_cards(card_id, "RCK", ATTACK_RCK_NAMES, 5, is_risky=True))
    card_id += 5
    
    cards.extend(generate_attack_cards(card_id, "CMP", ATTACK_CMP_NAMES, 10, is_complex=True))
    card_id += 10
    
    # SKILL cards (60)
    cards.extend(generate_skill_cards(card_id, "GRD", SKILL_GRD_NAMES, 20, tag="GUARD"))
    card_id += 20
    
    cards.extend(generate_skill_cards(card_id, "PAR", SKILL_PAR_NAMES, 20, tag="PARRY"))
    card_id += 20
    
    cards.extend(generate_skill_cards(card_id, "DOD", SKILL_DOD_NAMES, 20, tag="DODGE"))
    card_id += 20
    
    # POWER cards (50)
    cards.extend(generate_power_cards(card_id, "DRW", POWER_DRW_NAMES, 12))
    card_id += 12
    
    cards.extend(generate_power_cards(card_id, "ATK", POWER_ATK_NAMES, 15))
    card_id += 15
    
    cards.extend(generate_power_cards(card_id, "DEF", POWER_DEF_NAMES, 12))
    card_id += 12
    
    cards.extend(generate_power_cards(card_id, "SUS", POWER_SUS_NAMES, 11))
    card_id += 11
    
    # CURSE cards (48)
    cards.extend(generate_curse_cards(card_id, "STA", CURSE_STA_NAMES, 12))
    card_id += 12
    
    cards.extend(generate_curse_cards(card_id, "SPD", CURSE_SPD_NAMES, 12))
    card_id += 12
    
    cards.extend(generate_curse_cards(card_id, "PEN", CURSE_PEN_NAMES, 12))
    card_id += 12
    
    cards.extend(generate_curse_cards(card_id, "RSK", CURSE_RSK_NAMES, 12))
    card_id += 12
    
    return cards

def generate_attack_cards(start_id, subtype, names, count, is_aoe=False, is_risky=False, is_complex=False):
    cards = []
    
    for i, (name_ko, name_en, desc) in enumerate(names, 1):
        card_id = start_id + i - 1
        
        # Determine cost and damage based on subtype
        if subtype == "SGL":
            if i <= 3:
                cost, damage = 1, 6 + i
            elif i <= 7:
                cost, damage = 2, 9 + (i-3)
            else:
                cost, damage = 3 + (i-7), 12 + (i-7)*2
        elif subtype == "MLT":
            if i <= 4:
                cost, damage = 2, 4 + i*2
            elif i <= 8:
                cost, damage = 3, 12 + (i-4)*2
            else:
                cost, damage = 4, 18 + (i-8)*2
        elif subtype == "RCK":
            cost, damage = 2 + (i-1)//2, 15 + i*2
        elif subtype == "CMP":
            if i <= 3:
                cost, damage = 2 + i//2, 7 + i*2
            elif i <= 6:
                cost, damage = 3, 12 + (i-3)
            else:
                cost, damage = 4 + (i-6), 16 + (i-6)*2
        
        # MAJOR_ARCANA tag distribution
        major_arcana_chance = 0.5 if subtype == "SGL" else (0.3 if subtype == "MLT" else (0.8 if subtype == "RCK" else 0.7))
        tags = ["MAJOR_ARCANA"] if random.random() < major_arcana_chance else []
        if is_aoe:
            tags.append("AOE")
        
        # Rarity
        if subtype == "RCK":
            rarity_rand = random.random()
            rarity = "RARE" if rarity_rand < 0.6 else ("SPECIAL" if rarity_rand < 0.9 else "LEGENDARY")
        elif subtype == "CMP":
            rarity_rand = random.random()
            rarity = "RARE" if rarity_rand < 0.5 else ("SPECIAL" if rarity_rand < 0.85 else "LEGENDARY")
        else:
            rarity_rand = random.random()
            rarity = "COMMON" if rarity_rand < 0.5 else ("RARE" if rarity_rand < 0.85 else "SPECIAL")
        
        card = {
            "id": f"ATK-{subtype}_{i:03d}",
            "name": name_en,
            "nameKo": name_ko,
            "type": "ATTACK",
            "subtype": subtype,
            "rarity": rarity,
            "cost": cost,
            "costType": "energy",
            "description": desc,
            "descriptionKo": desc,
            "flavor": f"A {subtype} attack card.",
            "tags": tags,
            "stats": {
                "damage": damage,
                "block": 0,
                "heal": 0
            },
            "effects": [],
            "availability": "base",
            "monetization": "free",
            "releaseDate": "2026-03-15",
            "rotationEndDate": None,
            "gameType": ["ATB", "TB"],
            "notes": f"{subtype} type attack"
        }
        cards.append(card)
    
    return cards

def generate_skill_cards(start_id, subtype, names, count, tag):
    cards = []
    
    for i, (name_ko, name_en, desc) in enumerate(names, 1):
        card_id = start_id + i - 1
        
        # Cost and block based on subtype
        if subtype == "GRD":
            if i <= 5:
                cost, block = 1, 5 + i
            elif i <= 12:
                cost, block = 2, 8 + (i-5)
            else:
                cost, block = 3, 15 + (i-12)
        else:  # PAR or DOD
            if i <= 8:
                cost, block = 0, 0
            else:
                cost, block = 1, 0
        
        # MAJOR_ARCANA
        major_arcana_chance = 0.4
        tags = [tag, "MAJOR_ARCANA"] if random.random() < major_arcana_chance else [tag]
        
        # Rarity
        if subtype == "GRD":
            rarity_rand = random.random()
            rarity = "COMMON" if rarity_rand < 0.55 else ("RARE" if rarity_rand < 0.9 else "SPECIAL")
        elif subtype == "PAR":
            rarity_rand = random.random()
            rarity = "COMMON" if rarity_rand < 0.4 else ("RARE" if rarity_rand < 0.8 else "SPECIAL")
        else:  # DOD
            rarity_rand = random.random()
            rarity = "COMMON" if rarity_rand < 0.45 else ("RARE" if rarity_rand < 0.85 else "SPECIAL")
        
        card = {
            "id": f"SKL-{subtype}_{i:03d}",
            "name": name_en,
            "nameKo": name_ko,
            "type": "SKILL",
            "subtype": subtype,
            "rarity": rarity,
            "cost": cost,
            "costType": "energy",
            "description": desc,
            "descriptionKo": desc,
            "flavor": f"A {tag} skill.",
            "tags": tags,
            "stats": {
                "damage": 0,
                "block": block,
                "heal": 0
            },
            "effects": [],
            "availability": "base",
            "monetization": "free",
            "releaseDate": "2026-03-15",
            "rotationEndDate": None,
            "gameType": ["ATB", "TB"],
            "notes": f"{subtype} type skill"
        }
        cards.append(card)
    
    return cards

def generate_power_cards(start_id, subtype, names, count):
    cards = []
    
    for i, (name_ko, name_en, desc) in enumerate(names, 1):
        card_id = start_id + i - 1
        
        # Cost based on subtype
        if subtype == "DRW":
            cost = i % 3  # 0, 1, 2, 0, 1, 2...
        elif subtype == "ATK":
            cost = 1 + (i % 3)  # 1, 2, 3, 1, 2, 3...
        elif subtype == "DEF":
            cost = 1 + (i % 3)  # 1, 2, 3...
        elif subtype == "SUS":
            cost = 2 + (i % 3)  # 2, 3, 4...
        
        # MAJOR_ARCANA
        major_chances = {"DRW": 0.8, "ATK": 0.5, "DEF": 0.4, "SUS": 0.6}
        major_arcana_chance = major_chances.get(subtype, 0.5)
        tags = ["MAJOR_ARCANA"] if random.random() < major_arcana_chance else []
        
        # Rarity
        rarity_distributions = {
            "DRW": (0.2, 0.5, 0.3, 0),
            "ATK": (0.35, 0.45, 0.2, 0),
            "DEF": (0.4, 0.45, 0.15, 0),
            "SUS": (0, 0.5, 0.35, 0.15)
        }
        common_p, rare_p, special_p, legend_p = rarity_distributions.get(subtype, (0.3, 0.5, 0.2, 0))
        rarity_rand = random.random()
        if rarity_rand < common_p:
            rarity = "COMMON"
        elif rarity_rand < common_p + rare_p:
            rarity = "RARE"
        elif rarity_rand < common_p + rare_p + special_p:
            rarity = "SPECIAL"
        else:
            rarity = "LEGENDARY"
        
        card = {
            "id": f"PWR-{subtype}_{i:03d}",
            "name": name_en,
            "nameKo": name_ko,
            "type": "POWER",
            "subtype": subtype,
            "rarity": rarity,
            "cost": cost,
            "costType": "energy",
            "description": desc,
            "descriptionKo": desc,
            "flavor": f"A {subtype} power card.",
            "tags": tags,
            "stats": {
                "damage": 0,
                "block": 0,
                "heal": 0
            },
            "effects": [],
            "availability": "base",
            "monetization": "free",
            "releaseDate": "2026-03-15",
            "rotationEndDate": None,
            "gameType": ["ATB", "TB"],
            "notes": f"{subtype} type power"
        }
        cards.append(card)
    
    return cards

def generate_curse_cards(start_id, subtype, names, count):
    cards = []
    
    for i, (name_ko, name_en, desc) in enumerate(names, 1):
        card_id = start_id + i - 1
        
        # Cost based on subtype
        if subtype == "STA":
            cost = 1 + (i % 3)  # 1, 2, 3...
        elif subtype == "SPD":
            cost = 1 + (i % 3)  # 1, 2, 3...
        elif subtype == "PEN":
            cost = 2 + (i % 3)  # 2, 3, 4...
        elif subtype == "RSK":
            cost = (i % 3)  # 0, 1, 2...
        
        # MAJOR_ARCANA
        major_chances = {"STA": 0.3, "SPD": 0.25, "PEN": 0.25, "RSK": 0.2}
        major_arcana_chance = major_chances.get(subtype, 0.25)
        tags = ["MAJOR_ARCANA"] if random.random() < major_arcana_chance else []
        
        # Rarity
        rarity_distributions = {
            "STA": (0.5, 0.4, 0.1, 0),
            "SPD": (0.45, 0.45, 0.1, 0),
            "PEN": (0, 0.6, 0.35, 0.05),
            "RSK": (0, 0.5, 0.35, 0.15)
        }
        common_p, rare_p, special_p, legend_p = rarity_distributions.get(subtype, (0.4, 0.4, 0.2, 0))
        rarity_rand = random.random()
        if rarity_rand < common_p:
            rarity = "COMMON"
        elif rarity_rand < common_p + rare_p:
            rarity = "RARE"
        elif rarity_rand < common_p + rare_p + special_p:
            rarity = "SPECIAL"
        else:
            rarity = "LEGENDARY"
        
        card = {
            "id": f"CRS-{subtype}_{i:03d}",
            "name": name_en,
            "nameKo": name_ko,
            "type": "CURSE",
            "subtype": subtype,
            "rarity": rarity,
            "cost": cost,
            "costType": "energy",
            "description": desc,
            "descriptionKo": desc,
            "flavor": f"A {subtype} curse card.",
            "tags": tags,
            "stats": {
                "damage": 0,
                "block": 0,
                "heal": 0
            },
            "effects": [],
            "availability": "base",
            "monetization": "free",
            "releaseDate": "2026-03-15",
            "rotationEndDate": None,
            "gameType": ["ATB", "TB"],
            "notes": f"{subtype} type curse"
        }
        cards.append(card)
    
    return cards

# ============================================================================
# MAIN
# ============================================================================

if __name__ == "__main__":
    cards = generate_all_cards()
    
    # Save JSON
    output_json = "/Users/stevemacbook/Projects/geekbrox/teams/game/workspace/design/dream-collector/data/cards_200_v2.json"
    with open(output_json, "w", encoding="utf-8") as f:
        json.dump(cards, f, ensure_ascii=False, indent=2)
    
    print(f"✅ Generated {len(cards)} cards")
    print(f"📁 Saved to: {output_json}")
    
    # Statistics
    print("\n📊 Statistics:")
    
    type_counts = {}
    rarity_counts = {}
    tag_counts = {}
    
    for card in cards:
        card_type = card["type"]
        rarity = card["rarity"]
        
        type_counts[card_type] = type_counts.get(card_type, 0) + 1
        rarity_counts[rarity] = rarity_counts.get(rarity, 0) + 1
        
        for tag in card["tags"]:
            tag_counts[tag] = tag_counts.get(tag, 0) + 1
    
    print("\nBy Type:")
    for card_type in sorted(type_counts.keys()):
        count = type_counts[card_type]
        pct = (count / len(cards)) * 100
        print(f"  {card_type}: {count} ({pct:.1f}%)")
    
    print("\nBy Rarity:")
    for rarity in ["COMMON", "RARE", "SPECIAL", "LEGENDARY"]:
        if rarity in rarity_counts:
            count = rarity_counts[rarity]
            pct = (count / len(cards)) * 100
            print(f"  {rarity}: {count} ({pct:.1f}%)")
    
    print("\nBy Tag:")
    for tag in sorted(tag_counts.keys()):
        count = tag_counts[tag]
        pct = (count / len(cards)) * 100
        print(f"  {tag}: {count} ({pct:.1f}%)")
