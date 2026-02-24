## GameManager.gd
## 전역 게임 상태 관리 - AutoLoad 싱글톤
## 텔레그램 → Atlas → 게임팀장 파이프라인으로 수정 가능한 핵심 수치들

extends Node

# ─── 게임 버전 ───────────────────────────────────────
const VERSION = "0.1.0"

# ─── 핵심 자원 ───────────────────────────────────────
var reveries: float = 0.0          # 기본 화폐 (꿈 조각) → 골드로 변경 예정
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
	emit_signal("gems_changed", gems)
	print("[GameManager] Gems +%d (현재: %d)" % [amount, gems])

# ─── Gems 소비 ───────────────────────────────────────
func spend_gems(amount: int) -> bool:
	if gems >= amount:
		gems -= amount
		emit_signal("gems_changed", gems)
		return true
	return false

# ─── Energy 추가 ─────────────────────────────────────
func add_energy(amount: int) -> void:
	energy += amount
	emit_signal("energy_changed", energy)
	print("[GameManager] Energy +%d (현재: %d)" % [amount, energy])

# ─── Energy 소비 ─────────────────────────────────────
func spend_energy(amount: int) -> bool:
	if energy >= amount:
		energy -= amount
		emit_signal("energy_changed", energy)
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
