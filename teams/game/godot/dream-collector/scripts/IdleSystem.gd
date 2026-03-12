## IdleSystem.gd
## Idle 자동 수집 시스템 - AutoLoad 싱글톤
## GDD 기준: 기본 10 Reveries/hour, 오프라인 최대 8시간

extends Node

# ─── 수집 상태 ───────────────────────────────────────
var is_running: bool = false
var last_save_timestamp: int = 0       # Unix timestamp
var accumulated_offline: float = 0.0   # 오프라인 누적량

# ─── 카드 보너스 적용 배율 ────────────────────────────
var card_multiplier: float = 1.0
var prestige_multiplier: float = 1.0

# ─── 내부 타이머 ─────────────────────────────────────
var _tick_timer: float = 0.0
const TICK_INTERVAL: float = 1.0  # 1초마다 수집 계산

# ─── 시작 ────────────────────────────────────────────
func start() -> void:
	is_running = true
	_process_offline_gain()
	print("[IdleSystem] Collection started. Rate: %.2f/h" % get_current_rate())

# ─── 실시간 수집 처리 ─────────────────────────────────
func _process(delta: float) -> void:
	if not is_running:
		return
	_tick_timer += delta
	if _tick_timer >= TICK_INTERVAL:
		_tick_timer = 0.0
		_collect_tick()

# ─── 1초 단위 수집 ────────────────────────────────────
func _collect_tick() -> void:
	# per_second = rate_per_hour / 3600
	var per_second: float = get_current_rate() / 3600.0
	GameManager.add_reveries(per_second)

# ─── 오프라인 수집 계산 ───────────────────────────────
func _process_offline_gain() -> void:
	if last_save_timestamp == 0:
		last_save_timestamp = Time.get_unix_time_from_system()
		return

	var now: int = Time.get_unix_time_from_system()
	var elapsed_seconds: float = float(now - last_save_timestamp)
	var elapsed_hours: float = elapsed_seconds / 3600.0

	# 오프라인 최대 8시간 캡
	var capped_hours: float = minf(elapsed_hours, GameManager.offline_cap_hours)

	accumulated_offline = get_current_rate() * capped_hours
	GameManager.add_reveries(accumulated_offline)

	print("[IdleSystem] Offline %.1fh -> %.1f Reveries" % [capped_hours, accumulated_offline])
	last_save_timestamp = now

# ─── 현재 수집 속도 반환 (Reveries/hour) ─────────────
func get_current_rate() -> float:
	return GameManager.base_collection_rate * card_multiplier * prestige_multiplier

# ─── 카드 보너스 적용 ─────────────────────────────────
func apply_card_bonus(multiplier: float) -> void:
	card_multiplier = multiplier
	print("[IdleSystem] Card multiplier: x%.2f (rate: %.1f/h)" % [multiplier, get_current_rate()])

# ─── 프레스티지 배율 적용 ────────────────────────────
func apply_prestige_bonus(multiplier: float) -> void:
	prestige_multiplier = multiplier
	print("[IdleSystem] Prestige multiplier: x%.2f" % multiplier)

# ─── 타임스탬프 저장 (세이브 시 호출) ────────────────
func mark_save_time() -> void:
	last_save_timestamp = Time.get_unix_time_from_system()
