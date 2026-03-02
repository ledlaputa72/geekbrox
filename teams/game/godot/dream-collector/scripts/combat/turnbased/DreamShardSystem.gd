# scripts/combat/turnbased/DreamShardSystem.gd
# 꿈 조각: 전투 중 획득해서 즉발 소비하는 보조 자원 — DEV_SPEC_TURNBASED.md 기반
class_name DreamShardSystem
extends Node

const MAX_SHARDS = 5

var shards : int = 0

signal shards_changed(current: int, max_s: int)
signal shard_ability_used(ability_name: String)

# 에너지 시스템 참조 (ENERGY_BURST 사용 시)
var energy_system  : TurnBasedEnergySystem = null
var hand_system    : TurnBasedHandSystem   = null
var player_data    = null   # 딕셔너리 또는 플레이어 노드

func setup(es: TurnBasedEnergySystem, hs: TurnBasedHandSystem, p_data):
	energy_system = es
	hand_system = hs
	player_data = p_data

# ── 획득 조건 ──────────────────────────────────────────
func on_card_played(card: Card):
	# 패링 후 즉시 공격 등 특정 조건은 CombatManagerTB에서 gain_shard() 직접 호출
	pass

func gain_shard(n: int = 1):
	shards = min(MAX_SHARDS, shards + n)
	emit_signal("shards_changed", shards, MAX_SHARDS)
	print("[DreamShard] 꿈 조각 +%d → %d/%d" % [n, shards, MAX_SHARDS])

# ── 소비 ─────────────────────────────────────────────
enum ShardAbility {
	QUICK_DRAW,    # 1조각 — 카드 1장 드로우
	ENERGY_BURST,  # 2조각 — 에너지 +1
	DREAM_HEAL,    # 3조각 — HP 8 회복
	NIGHTMARE      # 5조각 — 전체 적 취약 2스택
}

const ABILITY_NAMES = {
	ShardAbility.QUICK_DRAW:   "즉시 드로우",
	ShardAbility.ENERGY_BURST: "에너지 폭발",
	ShardAbility.DREAM_HEAL:   "꿈의 치유",
	ShardAbility.NIGHTMARE:    "악몽"
}

func spend(ability: ShardAbility) -> bool:
	var cost = _get_cost(ability)
	if shards < cost:
		print("[DreamShard] 꿈 조각 부족! (%d 필요, %d 보유)" % [cost, shards])
		return false
	shards -= cost
	emit_signal("shards_changed", shards, MAX_SHARDS)
	_apply_effect(ability)
	var name = ABILITY_NAMES.get(ability, "?")
	emit_signal("shard_ability_used", name)
	print("[DreamShard] 사용: %s (-%d조각)" % [name, cost])
	return true

func _get_cost(ability: ShardAbility) -> int:
	match ability:
		ShardAbility.QUICK_DRAW:   return 1
		ShardAbility.ENERGY_BURST: return 2
		ShardAbility.DREAM_HEAL:   return 3
		ShardAbility.NIGHTMARE:    return 5
	return 99

func _apply_effect(ability: ShardAbility):
	match ability:
		ShardAbility.QUICK_DRAW:
			if hand_system:
				hand_system.draw_cards(1)

		ShardAbility.ENERGY_BURST:
			if energy_system:
				energy_system.spend(-1)  # 음수 spend = 에너지 추가

		ShardAbility.DREAM_HEAL:
			if player_data:
				if player_data is Dictionary:
					var hp = player_data.get("hp", 0)
					var max_hp = player_data.get("max_hp", 200)
					player_data["hp"] = min(max_hp, hp + 8)
				elif player_data.has_method("heal"):
					player_data.heal(8)
				# UI 업데이트를 위해 부모 CombatManager 시그널 발신
				var cm = get_parent()
				if cm and cm.has_signal("player_hp_changed"):
					var hp_val = player_data.get("hp", 0) if player_data is Dictionary else 0
					var max_val = player_data.get("max_hp", 200) if player_data is Dictionary else 200
					var blk_val = player_data.get("block", 0) if player_data is Dictionary else 0
					cm.emit_signal("player_hp_changed", hp_val, max_val, blk_val)
			print("[DreamShard] HP +8 회복")

		ShardAbility.NIGHTMARE:
			var parent = get_parent()
			if parent and "enemies" in parent:
				for enemy in parent.enemies:
					if enemy.is_alive():
						StatusEffectSystem.apply_to(enemy, "VULNERABLE", 2)
			print("[DreamShard] 전체 적 취약 2스택!")
			# 전투 종료 체크
			var cm = get_parent()
			if cm and cm.has_method("_check_battle_end"):
				cm._check_battle_end()

func can_afford(ability: ShardAbility) -> bool:
	return shards >= _get_cost(ability)

func reset():
	shards = 0
	emit_signal("shards_changed", shards, MAX_SHARDS)
