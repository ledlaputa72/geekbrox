## GameManager.gd
## 전역 게임 상태 관리 - AutoLoad 싱글톤
## 텔레그램 → Atlas → 게임팀장 파이프라인으로 수정 가능한 핵심 수치들

extends Node

# ─── 게임 버전 ───────────────────────────────────────
const VERSION = "0.1.0"

# ─── 핵심 자원 ───────────────────────────────────────
var reveries: float = 1000.0       # 기본 화폐 (꿈 조각) → 골드로 변경 예정 (초기값 1000)
var dream_shards: int = 0          # 프레스티지 화폐
var gems: int = 0                  # 💎 보석 (유료 화폐)
var energy: int = 100              # ⚡ 에너지 (게임 재화)

# ─── Idle 수집 설정 (GDD 기준) ────────────────────────
var base_collection_rate: float = 10.0   # 기본 10 Reveries/hour
var offline_cap_hours: float = 8.0       # 오프라인 최대 8시간

# ─── 진행 상태 ───────────────────────────────────────
var current_run_active: bool = false
var total_runs_completed: int = 0
var prestige_count: int = 0

# ─── 덱 데이터 ───────────────────────────────────────
var current_deck: Array = []  # 현재 장착된 덱 (최대 12장) - Array[Dictionary]는 JSON 로드 시 타입 충돌

# ─── 꿈 카드 데이터 (Dream Card Selection) ──────────
var dream_cards: Array = []  # 선택한 3장의 꿈 카드 [start, journey, end]
var dream_nodes: Array = []  # 생성된 전체 노드 목록 (dream_cards 기반)
var dream_time_logs: Array = []  # 시간별 로그 목록 (total_hours개)
var total_dream_hours: int = 0  # 총 여정 시간

# ─── 난이도 설정 ─────────────────────────────────────
var current_difficulty: String = "normal"  # easy, normal, hard
var difficulty_data: Dictionary = {}  # 난이도별 multiplier 데이터

# ─── 시그널 ─────────────────────────────────────────
signal reveries_changed(new_amount: float)
signal gems_changed(new_amount: int)
signal energy_changed(new_amount: int)
signal run_started()
signal run_completed(success: bool)
signal prestige_triggered()
signal deck_saved(deck_size: int)

# ─── 초기화 ─────────────────────────────────────────
func _ready() -> void:
	print("[GameManager] Dream Collector v%s 시작" % VERSION)
	SaveSystem.load_game()
	IdleSystem.start()

# ─── Reveries 추가 ───────────────────────────────────
func add_reveries(amount: float) -> void:
	reveries += amount
	emit_signal("reveries_changed", reveries)
	if reveries >= 10000.0 and prestige_count == 0:
		print("[GameManager] 프레스티지 조건 달성!")

# ─── Reveries 소비 ───────────────────────────────────
func spend_reveries(amount: float) -> bool:
	if reveries >= amount:
		reveries -= amount
		emit_signal("reveries_changed", reveries)
		return true
	return false

# ─── Gems 추가 ───────────────────────────────────────
func add_gems(amount: int) -> void:
	gems += amount
	gems_changed.emit(gems)
	SaveSystem.save_game()  # Auto-save on currency change
	print("[GameManager] Gems +%d (현재: %d)" % [amount, gems])

# ─── Gems 소비 ───────────────────────────────────────
func spend_gems(amount: int) -> bool:
	if gems >= amount:
		gems -= amount
		gems_changed.emit(gems)
		SaveSystem.save_game()  # Auto-save on currency change
		print("[GameManager] Gems -%d (Remaining: %d)" % [amount, gems])
		return true
	print("[GameManager] Not enough gems! Need: %d, Have: %d" % [amount, gems])
	return false

# ─── Energy 추가 ─────────────────────────────────────
func add_energy(amount: int) -> void:
	energy += amount
	energy_changed.emit(energy)
	SaveSystem.save_game()  # Auto-save on currency change
	print("[GameManager] Energy +%d (현재: %d)" % [amount, energy])

# ─── Energy 소비 ─────────────────────────────────────
func spend_energy(amount: int) -> bool:
	if energy >= amount:
		energy -= amount
		energy_changed.emit(energy)
		SaveSystem.save_game()  # Auto-save on currency change
		print("[GameManager] Energy -%d (Remaining: %d)" % [amount, energy])
		return true
	print("[GameManager] Not enough energy! Need: %d, Have: %d" % [amount, energy])
	return false

# ─── 꿈 카드 설정 (Dream Card Selection) ───────────
func set_dream_cards(cards: Array) -> void:
	"""Set selected dream cards and generate dream nodes + time logs"""
	dream_cards = cards.duplicate(true)
	dream_nodes.clear()
	dream_time_logs.clear()
	total_dream_hours = 0
	
	print("[GameManager] Dream cards set: %d cards" % dream_cards.size())
	
	# 노드만 유지, 시간(hours)은 사용하지 않음
	total_dream_hours = 0
	
	# Generate nodes from cards
	for i in range(dream_cards.size()):
		var card = dream_cards[i]
		var stage_name = ["시작", "여정", "종료"][i]
		
		print("  [%s] %s: %d nodes" % [stage_name, card.name, card.node_count])
		
		for node in card.nodes:
			var node_data = {
				"type": node.type,
				"icon": node.icon,
				"stage": stage_name,
				"card_name": card.name,
				"completed": false
			}
			dream_nodes.append(node_data)
	
	# Generate time-based logs
	_generate_time_logs()
	
	print("[GameManager] Total dream nodes: %d" % dream_nodes.size())
	print("[GameManager] Total time logs: %d (Event: %d, Travel: %d)" % [dream_time_logs.size(), dream_nodes.size(), dream_nodes.size()])

func _generate_time_logs() -> void:
	"""노드만 유지. 무조건 노드와 노드 사이에는 걷기 1개씩 배치.
	순서: 걷기 → 이벤트1 → 걷기 → 이벤트2 → ... 시간은 PM 10:00부터 1시간씩 증가."""
	var travel_log_templates = [
		"길을 따라 걷고 있다...",
		"주변을 살피며 천천히 이동한다.",
		"잠시 쉬어가며 숨을 고른다.",
		"어둠 속을 조심스럽게 나아간다.",
		"멀리서 무언가 빛나는 것이 보인다.",
		"발소리만이 고요함을 깬다.",
		"공기가 점점 무거워지는 느낌이다."
	]
	var start_hour = 22  # PM 10:00
	
	for i in range(dream_nodes.size()):
		var hour = start_hour + (dream_time_logs.size())
		# 노드 앞에 항상 걷기 1개
		dream_time_logs.append({
			"time": _format_hour(hour),
			"hour_index": dream_time_logs.size(),
			"type": "travel",
			"text": travel_log_templates[i % travel_log_templates.size()],
			"icon": "🚶"
		})
		
		hour = start_hour + dream_time_logs.size()
		var node = dream_nodes[i]
		var event_text = ""
		match node.type:
			"combat":
				event_text = "전투 - 적 발견!"
			"shop":
				event_text = "상점 발견"
			"npc":
				event_text = "누군가와 만남"
			"narration":
				event_text = "이야기가 펼쳐진다"
			"boss":
				event_text = "보스 등장!"
		
		dream_time_logs.append({
			"time": _format_hour(hour),
			"hour_index": dream_time_logs.size(),
			"type": "event",
			"event_type": node.type,
			"icon": node.icon,
			"text": event_text
		})


func _format_hour(hour: int) -> String:
	var hour_24 = hour % 24
	var is_pm = hour_24 >= 12
	var hour_12 = hour_24 % 12
	if hour_12 == 0:
		hour_12 = 12
	return "%s %d:00" % ["PM" if is_pm else "AM", hour_12]

func get_dream_cards() -> Array:
	"""Get selected dream cards"""
	return dream_cards.duplicate(true)

func get_dream_nodes() -> Array:
	"""Get generated dream nodes"""
	return dream_nodes.duplicate(true)

func get_dream_time_logs() -> Array:
	"""Get time-based logs"""
	return dream_time_logs.duplicate(true)

func get_total_dream_hours() -> int:
	"""Get total dream hours"""
	return total_dream_hours

func get_total_node_count() -> int:
	"""Get total node count"""
	return dream_nodes.size()

func has_boss_node() -> bool:
	"""Check if dream has boss node"""
	for node in dream_nodes:
		if node.type == "boss":
			return true
	return false

# ─── 런 시작 ─────────────────────────────────────────
func start_run() -> void:
	if current_run_active:
		print("[GameManager] 이미 런이 진행 중입니다.")
		return
	current_run_active = true
	emit_signal("run_started")
	print("[GameManager] 런 시작! (총 %d번째)" % (total_runs_completed + 1))

# ─── 런 완료 ─────────────────────────────────────────
func complete_run(success: bool) -> void:
	current_run_active = false
	if success:
		total_runs_completed += 1
	emit_signal("run_completed", success)
	SaveSystem.save_game()
	print("[GameManager] 런 %s (성공: %s)" % [total_runs_completed, success])

# ─── 프레스티지 ──────────────────────────────────────
func prestige() -> void:
	if reveries < 10000.0:
		print("[GameManager] 프레스티지 조건 미달 (필요: 10,000)")
		return
	prestige_count += 1
	dream_shards += 1
	reveries = 0.0
	base_collection_rate *= 1.25  # 프레스티지마다 25% 보너스
	emit_signal("prestige_triggered")
	SaveSystem.save_game()
	print("[GameManager] 프레스티지! (횟수: %d, 수집 속도: %.1f/h)" % [prestige_count, base_collection_rate])

# ─── 덱 저장 ─────────────────────────────────────────
func save_deck(deck: Array) -> void:
	current_deck = deck.duplicate(true)
	SaveSystem.save_game()
	emit_signal("deck_saved", current_deck.size())
	print("[GameManager] 덱 저장됨: %d장" % current_deck.size())

# ─── 덱 로드 ─────────────────────────────────────────
func get_current_deck() -> Array:
	return current_deck.duplicate(true)

# ─── 현재 상태 요약 (텔레그램 보고용) ────────────────
func get_status_report() -> String:
	return """[Dream Collector 현황]
버전: %s
Reveries: %.1f
드림 샤드: %d
완료한 런: %d
프레스티지: %d
수집 속도: %.1f/h
런 진행 중: %s
덱: %d/12장""" % [
		VERSION,
		reveries,
		dream_shards,
		total_runs_completed,
		prestige_count,
		IdleSystem.get_current_rate(),
		"예" if current_run_active else "아니오",
		current_deck.size()
	]

# ─── Gold/Currency Functions ────────────────────────
func get_gold() -> int:
	"""Get current gold (reveries)"""
	return int(reveries)

func add_gold(amount: int):
	"""Add gold (reveries)"""
	reveries += amount
	reveries_changed.emit(reveries)
	SaveSystem.save_game()  # Auto-save on currency change
	print("[GameManager] Gold +%d (Total: %d)" % [amount, int(reveries)])

func spend_gold(amount: int) -> bool:
	"""Spend gold if available"""
	if reveries >= amount:
		reveries -= amount
		reveries_changed.emit(reveries)
		SaveSystem.save_game()  # Auto-save on currency change
		print("[GameManager] Gold -%d (Remaining: %d)" % [amount, int(reveries)])
		return true
	else:
		print("[GameManager] Not enough gold! Need: %d, Have: %d" % [amount, int(reveries)])
		return false

func get_gems() -> int:
	"""Get current gems"""
	return gems

func get_energy() -> int:
	"""Get current energy"""
	return energy
