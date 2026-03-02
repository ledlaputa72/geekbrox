extends Control
class_name CharacterNode

"""
CharacterNode - 공용 캐릭터 컴포넌트
Hero, Monster, NPC 모두 이 컴포넌트 사용

Hero:    PlayerSpriteAnimator (player_ani.png, 100x150)
Monster: PlayerSpriteAnimator (monster1_ani.png, flip_h, 80x120)
NPC:     PlayerSpriteAnimator (NPC1_ani.png / NPC2_ani.png, flip_h, 80x120)
         또는 ColorRect + Emoji (sprite 없을 때, 60x120)

setup data에 "sprite" 키가 있으면 스프라이트 애니메이션 사용
없으면 기존 emoji 방식 유지
"""

signal character_clicked(character_node: CharacterNode)

# ─── Character data ───────────────────────────────────
var character_type: String = "monster"  # "hero", "monster", "npc"
var character_id: String = ""
var character_name: String = ""
var max_hp: int = 100
var current_hp: int = 100
var emoji_icon: String = ""
var base_color: Color = Color(0.8, 0.3, 0.3, 1)
var sprite_path: String = ""           # 스프라이트 경로 (비어있으면 emoji)
var sprite_flip: bool = false          # 좌우 반전 (몬스터)

# ─── UI nodes — emoji 기반 (NPC / 스프라이트 없는 캐릭터) ─
var sprite: ColorRect       # emoji 배경
var emoji_label: Label      # emoji 텍스트

# ─── UI nodes — 공통 ─────────────────────────────────
var hp_bar: ProgressBar
var hp_label: Label
var block_label: Label = null  # Hero 전용 아머 수치
var click_button: Button

# ─── 스프라이트 애니메이터 (Hero + Monster) ───────────
var sprite_animator: PlayerSpriteAnimator = null

# ─── 크기 설정 ────────────────────────────────────────
const HERO_SIZE = Vector2(100, 150)
const MONSTER_SIZE = Vector2(80, 120)
const NPC_SIZE = Vector2(80, 120)
const DEFAULT_SIZE = Vector2(60, 120)

# ─── 내부 추적 ────────────────────────────────────────
var _visual_built_for: String = ""  # 비주얼 재생성 방지용


func _ready():
	var node_size = _get_size_for_type()
	custom_minimum_size = node_size
	size = node_size
	_create_ui()
	_visual_built_for = character_type + "|" + sprite_path


func _get_size_for_type() -> Vector2:
	match character_type:
		"hero":
			return HERO_SIZE
		"monster":
			if sprite_path != "":
				return MONSTER_SIZE
			return DEFAULT_SIZE
		"npc":
			if sprite_path != "":
				return NPC_SIZE
			return DEFAULT_SIZE
		_:
			return DEFAULT_SIZE


# ─── UI 생성 ─────────────────────────────────────────

func _create_ui():
	"""UI 구성 — 스프라이트가 있으면 스프라이트, 없으면 emoji"""
	if sprite_path != "" or character_type == "hero":
		_create_sprite_ui()
	else:
		_create_emoji_ui()

	_create_hp_bar()
	_create_click_button()


func _create_sprite_ui():
	"""스프라이트 기반 UI (Hero + Monster)"""
	sprite_animator = PlayerSpriteAnimator.new()
	sprite_animator.name = "SpriteAnimator"

	# Hero: player_ani.png (기본), Monster: setup에서 받은 경로
	if character_type == "hero":
		# 기본 player 경로 사용 (override 없음)
		pass
	else:
		sprite_animator.sprite_path_override = sprite_path
		sprite_animator.flip_horizontal = sprite_flip

	var node_size = _get_size_for_type()
	sprite_animator.custom_minimum_size = Vector2(node_size.x, node_size.y - 24)
	sprite_animator.position = Vector2(0, 0)
	sprite_animator.size = Vector2(node_size.x, node_size.y - 24)
	add_child(sprite_animator)
	sprite_animator.play(PlayerSpriteAnimator.AnimState.IDLE)


func _create_emoji_ui():
	"""Emoji 기반 UI (NPC / 스프라이트 없는 캐릭터)"""
	sprite = ColorRect.new()
	sprite.name = "Sprite"
	sprite.set_anchors_preset(Control.PRESET_FULL_RECT)
	sprite.color = base_color
	add_child(sprite)

	emoji_label = Label.new()
	emoji_label.name = "EmojiLabel"
	emoji_label.text = emoji_icon
	emoji_label.set_anchors_preset(Control.PRESET_CENTER)
	emoji_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	emoji_label.add_theme_font_size_override("font_size", 32)
	sprite.add_child(emoji_label)


func _create_hp_bar():
	"""HP 바 + 라벨. Hero: 플레이어 위 10px, Monster: 하단"""
	var is_hero = (character_type == "hero")
	if is_hero:
		# 플레이어: 캐릭터 위 10px에 HP 게이지
		hp_bar = ProgressBar.new()
		hp_bar.name = "HPBar"
		hp_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
		hp_bar.offset_top = -24
		hp_bar.offset_bottom = -14
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp
		hp_bar.show_percentage = false
		add_child(hp_bar)
		hp_label = Label.new()
		hp_label.name = "HPLabel"
		hp_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
		hp_label.offset_top = -24
		hp_label.offset_bottom = -14
		hp_label.text = "%d/%d" % [current_hp, max_hp]
		hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hp_label.add_theme_font_size_override("font_size", 10)
		add_child(hp_label)
		# 아머 게이지 (수치)
		block_label = Label.new()
		block_label.name = "BlockLabel"
		block_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
		block_label.offset_top = -14
		block_label.offset_bottom = -2
		block_label.text = "🛡0"
		block_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		block_label.add_theme_font_size_override("font_size", 10)
		add_child(block_label)
	else:
		# 몬스터: 기존 하단 배치
		hp_bar = ProgressBar.new()
		hp_bar.name = "HPBar"
		hp_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		hp_bar.offset_top = 4
		hp_bar.offset_bottom = 14
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp
		hp_bar.show_percentage = false
		add_child(hp_bar)
		hp_label = Label.new()
		hp_label.name = "HPLabel"
		hp_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		hp_label.offset_top = 4
		hp_label.offset_bottom = 14
		hp_label.text = "%d/%d" % [current_hp, max_hp]
		hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hp_label.add_theme_font_size_override("font_size", 10)
		add_child(hp_label)


func _create_click_button():
	"""투명 클릭 버튼"""
	click_button = Button.new()
	click_button.name = "ClickButton"
	click_button.set_anchors_preset(Control.PRESET_FULL_RECT)
	click_button.flat = true
	click_button.pressed.connect(_on_clicked)
	add_child(click_button)


# ─── 비주얼 재생성 (타입/스프라이트 변경 시) ─────────

func _rebuild_visuals():
	"""스프라이트/emoji 노드만 교체 (HP바, 버튼 유지)"""
	# 기존 비주얼 제거
	if sprite_animator:
		sprite_animator.queue_free()
		sprite_animator = null
	if sprite:
		sprite.queue_free()
		sprite = null
		emoji_label = null

	# 크기 재조정
	var node_size = _get_size_for_type()
	custom_minimum_size = node_size
	size = node_size

	# 새 비주얼 생성
	if sprite_path != "" or character_type == "hero":
		_create_sprite_ui()
	else:
		_create_emoji_ui()

	_visual_built_for = character_type + "|" + sprite_path


# ─── Setup & Update ──────────────────────────────────

func setup(data: Dictionary):
	"""캐릭터 데이터 설정 (_ready 전 또는 후 모두 호출 가능)"""
	character_type = data.get("type", "monster")
	character_id = data.get("id", "")
	character_name = data.get("name", "Character")
	max_hp = data.get("max_hp", 100)
	current_hp = data.get("hp", max_hp)
	emoji_icon = data.get("emoji", "")
	base_color = data.get("color", Color(0.8, 0.3, 0.3, 1))
	sprite_path = data.get("sprite", "")
	sprite_flip = data.get("sprite_flip", false)

	# UI가 이미 생성된 경우: 타입/스프라이트 변경 감지 → 비주얼 재생성
	var new_visual_key = character_type + "|" + sprite_path
	if _visual_built_for != "" and _visual_built_for != new_visual_key:
		_rebuild_visuals()

	# 기존 UI 데이터 업데이트
	if sprite:
		sprite.color = base_color
	if emoji_label:
		emoji_label.text = emoji_icon
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp
	if hp_label:
		hp_label.text = "%d/%d" % [current_hp, max_hp]


func update_hp(new_hp: int, damage_dealt: int = 0, is_healing: bool = false):
	"""HP 업데이트 + 데미지 숫자 표시"""
	var old_hp = current_hp
	current_hp = clamp(new_hp, 0, max_hp)

	if hp_bar:
		hp_bar.value = current_hp
	if hp_label:
		hp_label.text = "%d/%d" % [current_hp, max_hp]

	# 데미지 숫자 표시
	if damage_dealt != 0:
		show_damage_number(damage_dealt, is_healing)

	# 사망 처리
	if current_hp <= 0:
		if sprite_animator:
			# 스프라이트 캐릭터: DIE 애니메이션 (숨기지 않음)
			sprite_animator.play(PlayerSpriteAnimator.AnimState.DIE)
		else:
			# Emoji 캐릭터: 숨김
			visible = false


# ─── 스프라이트 애니메이션 API ────────────────────────

func play_animation(state: PlayerSpriteAnimator.AnimState) -> void:
	"""스프라이트 애니메이션 재생 (Hero/Monster 공용)"""
	if sprite_animator:
		sprite_animator.play(state)


func get_sprite_animator() -> PlayerSpriteAnimator:
	"""스프라이트 애니메이터 참조 반환 (시그널 연결용)"""
	return sprite_animator


# ─── 데미지 & 이펙트 ─────────────────────────────────

func show_damage_number(damage: int, is_healing: bool = false):
	"""플로팅 데미지 숫자 표시"""
	var DamageNumberScene = preload("res://ui/components/DamageNumber.tscn")
	var dmg_num = DamageNumberScene.instantiate()
	dmg_num.position = Vector2(size.x / 2.0, 20)
	add_child(dmg_num)

	var type = DamageNumber.Type.DAMAGE
	if is_healing:
		type = DamageNumber.Type.HEALING
	elif character_type == "hero":
		type = DamageNumber.Type.SELF_DAMAGE

	dmg_num.show_damage(damage, type)

	if not is_healing:
		shake()


func shake(intensity: float = 8.0, duration: float = 0.4):
	"""흔들림 효과 (position 기반)"""
	var original_position = position
	var original_rotation = rotation
	var shake_count = 8
	var shake_duration = duration / float(shake_count)

	var tween = create_tween()
	tween.set_parallel(false)

	for i in range(shake_count):
		var shake_offset = Vector2(intensity if i % 2 == 0 else -intensity, 0)
		tween.tween_property(self, "position", original_position + shake_offset, shake_duration / 2.0)
		tween.tween_property(self, "position", original_position, shake_duration / 2.0)
		intensity *= 0.7

	tween.tween_property(self, "position", original_position, 0.05)

	var rotation_tween = create_tween()
	rotation_tween.set_parallel(false)
	var rotation_intensity = 0.1

	for i in range(4):
		rotation_tween.tween_property(self, "rotation", original_rotation + rotation_intensity, 0.05)
		rotation_tween.tween_property(self, "rotation", original_rotation - rotation_intensity, 0.05)
		rotation_intensity *= 0.6

	rotation_tween.tween_property(self, "rotation", original_rotation, 0.05)

	flash_red()


func flash_red():
	"""데미지 시 빨간색 번쩍임"""
	if sprite_animator:
		# 스프라이트: modulate 번쩍임
		var tween = create_tween()
		tween.set_parallel(false)
		tween.tween_property(sprite_animator, "modulate", Color(2.0, 0.5, 0.5, 1.0), 0.1)
		tween.tween_property(sprite_animator, "modulate", Color.WHITE, 0.2)
	elif sprite:
		# Emoji: ColorRect 색상 번쩍임
		var original_color = sprite.color
		var flash_color = Color(1.0, 0.3, 0.3, 1.0)
		var tween = create_tween()
		tween.set_parallel(false)
		tween.tween_property(sprite, "color", flash_color, 0.1)
		tween.tween_property(sprite, "color", original_color, 0.2)


# ─── HP 바 / 이동 애니메이션 ─────────────────────────

func set_hp_bar_visible(visible_flag: bool):
	"""HP 바 표시/숨김"""
	if hp_bar:
		hp_bar.visible = visible_flag
	if hp_label:
		hp_label.visible = visible_flag
	if block_label:
		block_label.visible = visible_flag

func update_block(block_val: int):
	"""아머(블록) 수치 갱신 (Hero 전용)"""
	if block_label:
		block_label.text = "🛡%d" % block_val


func fly_in_from_right(target_pos: Vector2, duration: float = 0.5):
	"""오른쪽에서 등장 + 스프라이트 WALK → 도착 후 IDLE"""
	position = Vector2(500, target_pos.y)
	visible = true

	# 등장 중 WALK 애니메이션
	if sprite_animator:
		sprite_animator.play(PlayerSpriteAnimator.AnimState.WALK)

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", target_pos, duration)
	# 도착 후 IDLE 전환
	tween.tween_callback(func():
		if sprite_animator:
			sprite_animator.play(PlayerSpriteAnimator.AnimState.IDLE)
	)


func fly_out_to_right(duration: float = 0.3):
	"""오른쪽으로 퇴장"""
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position:x", 500, duration)
	tween.tween_callback(func(): visible = false)


func set_target_highlighted(highlighted: bool):
	"""공격 대상 선택 표시 (보라색 테두리)"""
	if sprite_animator:
		if highlighted:
			sprite_animator.modulate = Color(1.2, 0.9, 1.3, 1.0)
		else:
			sprite_animator.modulate = Color.WHITE
	elif sprite:
		if highlighted:
			sprite.modulate = Color(1.2, 0.9, 1.3, 1.0)
		else:
			sprite.modulate = Color.WHITE


func _on_clicked():
	"""클릭 처리"""
	character_clicked.emit(self)
