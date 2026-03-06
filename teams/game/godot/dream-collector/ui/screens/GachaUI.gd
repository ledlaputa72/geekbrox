# ui/screens/GachaUI.gd
# 가챭 UI — CURSOR_COMPLETE_DEV_GUIDE
# 1회/10회 뽑기, 비용 50D, 결과 표시. GachaSystem과 연동.
extends Control

signal pull_requested(gacha_type: String, count: int)

var _gacha_system: Node = null
var _result_items: Array[Control] = []

func _ready():
	# Autoload로 등록된 GachaSystem 사용
	_gacha_system = get_node_or_null("/root/GachaSystem")
	if _gacha_system:
		_gacha_system.equipment_pulled.connect(_on_equipment_pulled)
		_gacha_system.card_pulled.connect(_on_card_pulled)

func set_gacha_system(system: Node) -> void:
	_gacha_system = system
	if _gacha_system:
		if not _gacha_system.equipment_pulled.is_connected(_on_equipment_pulled):
			_gacha_system.equipment_pulled.connect(_on_equipment_pulled)
		if not _gacha_system.card_pulled.is_connected(_on_card_pulled):
			_gacha_system.card_pulled.connect(_on_card_pulled)

func pull_equipment_once() -> void:
	pull_requested.emit("equipment", 1)
	if _gacha_system and _gacha_system.has_method("pull_equipment"):
		_gacha_system.pull_equipment(1)

func pull_equipment_10() -> void:
	pull_requested.emit("equipment", 10)
	if _gacha_system and _gacha_system.has_method("pull_equipment"):
		_gacha_system.pull_equipment(10)

func pull_card_once() -> void:
	pull_requested.emit("card", 1)
	if _gacha_system and _gacha_system.has_method("pull_card"):
		_gacha_system.pull_card(1)

func pull_card_10() -> void:
	pull_requested.emit("card", 10)
	if _gacha_system and _gacha_system.has_method("pull_card"):
		_gacha_system.pull_card(10)

func _on_equipment_pulled(results: Array) -> void:
	_display_results(results, "장비")

func _on_card_pulled(results: Array) -> void:
	_display_results(results, "카드")

func _display_results(results: Array, type_label: String) -> void:
	# 결과 표시 (자식 노드가 있으면 활용, 없으면 로그)
	for r in results:
		var name_str = ""
		if r is Resource:
			if r.get("name_ko"):
				name_str = r.name_ko
			elif r.get("name"):
				name_str = r.name
		elif r is Dictionary:
			name_str = r.get("name", r.get("name_ko", "?"))
		print("[GachaUI] %s 획득: %s" % [type_label, name_str])
	# 시그널로 외부 UI가 처리할 수 있음
	results_displayed.emit(results, type_label)

signal results_displayed(results: Array, type_label: String)

func get_cost_per_pull() -> int:
	if _gacha_system and "COST_PER_PULL_DIAMOND" in _gacha_system:
		return _gacha_system.COST_PER_PULL_DIAMOND
	return 50
