# PlayerSpriteAnimator.gd
# 캐릭터 스프라이트 애니메이션 공용 컴포넌트
# 스프라이트시트: 2048x2048, 4x4 그리드, 512x512/프레임
# 마젠타(1,0,1) 배경 → chroma_key 셰이더로 투명 처리
#
# 프레임 배치 (1-indexed row x col):
#   Walk:   1x1~2x4 (8프레임)
#   Attack: 3x1~3x4 (4프레임)
#   Hit:    4x1     (1프레임)
#   Die:    4x2     (1프레임)
#   Idle:   4x3~4x4 (2프레임)
#
# 사용법:
#   플레이어: 기본값 (player_ani.png, flip 없음)
#   몬스터:   sprite_path_override, flip_horizontal = true
extends TextureRect
class_name PlayerSpriteAnimator


# ─── 애니메이션 상태 ──────────────────────────────────
enum AnimState { IDLE, WALK, ATTACK, HIT, DIE }

signal animation_finished(state: int)


# ─── 설정 (인스턴스 생성 후, _ready 전에 설정 가능) ───
var sprite_path_override: String = ""    # 빈 문자열이면 기본 player 경로 사용
var flip_horizontal: bool = false        # 몬스터용: 좌우 반전

# ─── 스프라이트시트 설정 ──────────────────────────────
const SPRITE_PATH_PRIMARY = "res://assets/sprite/player_ani.png"
const SPRITE_PATH_FALLBACK = "res://assets/sprite/player_walk.png"
const CHROMA_SHADER_PATH = "res://shaders/chroma_key.gdshader"

const CELL_SIZE = Vector2(512, 512)
const GRID_COLS = 4
const GRID_ROWS = 4

# 애니메이션 정의
# 프레임 인덱스 = row * GRID_COLS + col (0-indexed)
#   Walk:   [0,1,2,3, 4,5,6,7]   (row0 col0~3, row1 col0~3)
#   Attack: [8,9,10,11]           (row2 col0~3)
#   Hit:    [12]                  (row3 col0)
#   Die:    [13]                  (row3 col1)
#   Idle:   [14,15]               (row3 col2~3)
var ANIM_DATA: Dictionary = {
	AnimState.IDLE:    {"frames": [14, 15],          "fps": 2.0,  "loop": true},
	AnimState.WALK:    {"frames": [0,1,2,3,4,5,6,7], "fps": 10.0, "loop": true},
	AnimState.ATTACK:  {"frames": [8,9,10,11],       "fps": 12.0, "loop": false},
	AnimState.HIT:     {"frames": [12],              "fps": 1.0,  "loop": false},
	AnimState.DIE:     {"frames": [13],              "fps": 1.0,  "loop": false},
}


# ─── 내부 상태 ────────────────────────────────────────
var sprite_texture: Texture2D = null
var atlas_frames: Array[AtlasTexture] = []
var current_state: AnimState = AnimState.IDLE
var current_frame_index: int = 0
var frame_timer: float = 0.0
var is_playing: bool = false
var hold_timer: float = 0.0
const HIT_HOLD_TIME: float = 0.4   # HIT 프레임 유지 시간
const DIE_HOLD_TIME: float = 0.0   # DIE는 즉시 표시 후 유지


func _ready() -> void:
	# TextureRect 기본 설정
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# 좌우 반전 (몬스터: 플레이어 반대 방향)
	if flip_horizontal:
		flip_h = true

	# 스프라이트 텍스처 로드
	_load_sprite_texture()

	# Atlas 프레임 빌드
	if sprite_texture:
		_build_atlas_frames()

	# chroma key 셰이더 적용
	_apply_chroma_shader()

	# 기본 상태: IDLE
	play(AnimState.IDLE)


func _load_sprite_texture() -> void:
	# 1순위: 외부에서 지정한 경로
	if sprite_path_override != "":
		sprite_texture = load(sprite_path_override)
		if sprite_texture:
			return
		push_warning("[PlayerSpriteAnimator] Override path not found: %s" % sprite_path_override)

	# 2순위: 기본 player_ani.png
	sprite_texture = load(SPRITE_PATH_PRIMARY)
	if sprite_texture:
		return

	# 3순위: fallback player_walk.png
	sprite_texture = load(SPRITE_PATH_FALLBACK)
	if sprite_texture:
		push_warning("[PlayerSpriteAnimator] Using player_walk.png fallback")
	else:
		push_error("[PlayerSpriteAnimator] No sprite file found!")


func _build_atlas_frames() -> void:
	atlas_frames.clear()
	for row in range(GRID_ROWS):
		for col in range(GRID_COLS):
			var atlas = AtlasTexture.new()
			atlas.atlas = sprite_texture
			atlas.region = Rect2(
				col * CELL_SIZE.x, row * CELL_SIZE.y,
				CELL_SIZE.x, CELL_SIZE.y
			)
			atlas_frames.append(atlas)


func _apply_chroma_shader() -> void:
	var shader = load(CHROMA_SHADER_PATH)
	if not shader:
		push_warning("[PlayerSpriteAnimator] chroma_key shader not found")
		return
	var mat = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("chroma_color", Vector3(1.0, 0.0, 1.0))
	mat.set_shader_parameter("threshold", 0.3)
	material = mat


# ─── 공개 API ─────────────────────────────────────────

func play(state: AnimState) -> void:
	"""애니메이션 상태 전환 및 재생"""
	current_state = state
	current_frame_index = 0
	frame_timer = 0.0
	hold_timer = 0.0
	is_playing = true
	_show_current_frame()


func stop() -> void:
	"""애니메이션 정지 (현재 프레임 유지)"""
	is_playing = false


func get_current_state() -> AnimState:
	return current_state


func is_animation_playing() -> bool:
	return is_playing


# ─── 프레임 업데이트 ──────────────────────────────────

func _process(delta: float) -> void:
	if not is_playing or atlas_frames.is_empty():
		return

	var anim: Dictionary = ANIM_DATA[current_state]
	var frames: Array = anim.frames

	# DIE: 프레임 표시 후 영구 유지
	if current_state == AnimState.DIE:
		is_playing = false
		animation_finished.emit(current_state)
		return

	# HIT: 프레임 표시 후 hold_time 동안 유지
	if current_state == AnimState.HIT:
		hold_timer += delta
		if hold_timer >= HIT_HOLD_TIME:
			is_playing = false
			animation_finished.emit(current_state)
		return

	# 단일 프레임 루프 애니메이션 (예방적 처리)
	if frames.size() <= 1:
		return

	# 일반 프레임 순환
	frame_timer += delta
	var frame_duration: float = 1.0 / anim.fps

	if frame_timer >= frame_duration:
		frame_timer -= frame_duration
		current_frame_index += 1

		if current_frame_index >= frames.size():
			if anim.loop:
				current_frame_index = 0
			else:
				# 원샷 애니메이션 종료
				current_frame_index = frames.size() - 1
				is_playing = false
				animation_finished.emit(current_state)
				return

		_show_current_frame()


func _show_current_frame() -> void:
	var anim: Dictionary = ANIM_DATA[current_state]
	var frames: Array = anim.frames
	if current_frame_index >= 0 and current_frame_index < frames.size():
		var atlas_index: int = frames[current_frame_index]
		if atlas_index >= 0 and atlas_index < atlas_frames.size():
			texture = atlas_frames[atlas_index]
