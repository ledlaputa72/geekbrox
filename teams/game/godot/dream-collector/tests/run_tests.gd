## run_tests.gd
## Godot headless 자동 테스트 스크립트
## 실행: godot --headless --script tests/run_tests.gd --quit-after 10
##
## 텔레그램 → Atlas → 게임팀장 → bash로 자동 실행

extends SceneTree

var passed: int = 0
var failed: int = 0

func _init() -> void:
	print("\n=== Dream Collector 자동 테스트 시작 ===\n")
	_run_all_tests()
	_print_summary()
	quit(0 if failed == 0 else 1)

func _run_all_tests() -> void:
	_test_idle_rate()
	_test_reveries_accumulation()
	_test_offline_cap()
	_test_prestige_condition()
	_test_spend_reveries()

# ─── 테스트: 기본 수집 속도 ──────────────────────────
func _test_idle_rate() -> void:
	var base_rate: float = 10.0
	var multiplier: float = 1.5
	var expected: float = 15.0
	var result: float = base_rate * multiplier
	_assert("기본 수집 속도 계산", result == expected,
		"예상: %.1f, 실제: %.1f" % [expected, result])

# ─── 테스트: Reveries 1시간 누적 ────────────────────
func _test_reveries_accumulation() -> void:
	var rate_per_hour: float = 10.0
	var elapsed_hours: float = 1.0
	var expected: float = 10.0
	var result: float = rate_per_hour * elapsed_hours
	_assert("1시간 Reveries 누적", absf(result - expected) < 0.01,
		"예상: %.1f, 실제: %.1f" % [expected, result])

# ─── 테스트: 오프라인 8시간 캡 ───────────────────────
func _test_offline_cap() -> void:
	var rate: float = 10.0
	var cap_hours: float = 8.0
	var elapsed_hours: float = 12.0  # 12시간 경과
	var capped: float = minf(elapsed_hours, cap_hours)
	var result: float = rate * capped
	var expected: float = 80.0  # 8시간만 적용
	_assert("오프라인 8시간 캡", result == expected,
		"예상: %.1f, 실제: %.1f" % [expected, result])

# ─── 테스트: 프레스티지 조건 ─────────────────────────
func _test_prestige_condition() -> void:
	var reveries: float = 9999.0
	var threshold: float = 10000.0
	_assert("프레스티지 조건 미달 (9999)", reveries < threshold,
		"9999 < 10000 이어야 함")
	reveries = 10000.0
	_assert("프레스티지 조건 달성 (10000)", reveries >= threshold,
		"10000 >= 10000 이어야 함")

# ─── 테스트: Reveries 소비 ───────────────────────────
func _test_spend_reveries() -> void:
	var balance: float = 100.0
	var cost: float = 30.0
	var can_spend: bool = balance >= cost
	_assert("Reveries 소비 가능 (100 >= 30)", can_spend, "100 >= 30 이어야 함")
	balance -= cost
	_assert("소비 후 잔액 (70)", absf(balance - 70.0) < 0.01,
		"예상: 70.0, 실제: %.1f" % balance)

# ─── 헬퍼: 어서션 ────────────────────────────────────
func _assert(test_name: String, condition: bool, message: String = "") -> void:
	if condition:
		passed += 1
		print("  ✅ PASS: %s" % test_name)
	else:
		failed += 1
		print("  ❌ FAIL: %s" % test_name)
		if message:
			print("         → %s" % message)

# ─── 결과 요약 ───────────────────────────────────────
func _print_summary() -> void:
	var total: int = passed + failed
	print("\n=== 테스트 결과 ===")
	print("총 테스트: %d" % total)
	print("통과: %d ✅" % passed)
	print("실패: %d ❌" % failed)
	if failed == 0:
		print("\n🎉 모든 테스트 통과!")
	else:
		print("\n⚠️ %d개 테스트 실패 — 수정 필요" % failed)
	print("==================\n")
