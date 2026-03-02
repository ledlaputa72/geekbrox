# UITheme.gd
# Dream Theme Design System - 전역 디자인 토큰
# HTML/Figma 프로토타입에서 추출한 디자인 시스템

extends Node

# ============================================
# COLORS (Dream Theme)
# ============================================

const COLORS = {
	# Primary Colors
	"primary": Color("#7B9EF0"),           # 메인 액센트 (파란색)
	"primary_dark": Color("#5A7DC8"),      # Primary 어두운 버전
	"primary_light": Color("#9CB6F5"),     # Primary 밝은 버전
	"secondary": Color("#4A5070"),         # 보조/비활성 버튼
	
	# Background Colors
	"bg": Color("#1A1A2E"),                # 메인 배경 (매우 어두운 남색)
	"bg_light": Color("#252540"),          # 밝은 배경
	
	# Panel Colors
	"panel": Color("#2C2C3E"),             # 패널/카드 배경
	"panel_light": Color("#3A3A52"),       # 호버/선택된 패널
	"panel_border": Color("#404060"),      # 패널 테두리
	
	# Text Colors
	"text": Color("#FFFFFF"),              # 메인 텍스트 (흰색)
	"text_dim": Color("#B0B0C8"),          # 흐린 텍스트 (회색)
	"text_dark": Color("#808098"),         # 어두운 텍스트
	
	# Semantic Colors
	"success": Color("#51CF66"),           # 성공/긍정 (초록)
	"danger": Color("#FF6B6B"),            # 위험/부정 (빨강)
	"warning": Color("#FFD93D"),           # 경고 (노랑)
	"info": Color("#4DABF7"),              # 정보 (파랑)
	
	# Card Type Colors (카드 라이브러리용)
	"attack": Color("#FF6B6B"),            # 공격 카드 (빨강)
	"defense": Color("#51CF66"),           # 방어 카드 (초록)
	"skill": Color("#9775FA"),             # 스킬 카드 (보라)
	"power": Color("#FFD93D"),             # 파워 카드 (노랑)
	
	# Rarity Colors
	"common": Color("#B0B0C8"),            # 일반 (회색)
	"uncommon": Color("#51CF66"),          # 고급 (초록)
	"rare": Color("#4DABF7"),              # 희귀 (파랑)
	"epic": Color("#9775FA"),              # 영웅 (보라)
	"legendary": Color("#FFD93D"),         # 전설 (금색)
}

# ============================================
# SPACING (8px 기준 그리드)
# ============================================

const SPACING = {
	"xs": 4,      # Extra Small - 아주 작은 간격
	"sm": 8,      # Small - 작은 간격
	"md": 16,     # Medium - 중간 간격
	"lg": 24,     # Large - 큰 간격
	"xl": 32,     # Extra Large - 매우 큰 간격
	"xxl": 48,    # Extra Extra Large - 섹션 간격
}

# ============================================
# FONT SIZES
# ============================================

const FONT_SIZES = {
	"tiny": 10,       # 매우 작은 텍스트 (레이블)
	"small": 12,      # 작은 텍스트 (캡션)
	"body": 14,       # 본문 텍스트
	"subtitle": 16,   # 부제목
	"title": 20,      # 제목
	"header": 24,     # 헤더
	"large": 32,      # 큰 제목
}

# ============================================
# LAYOUT CONSTANTS
# ============================================

# 모바일 화면 크기 (iPhone 14 기준)
const SCREEN_SIZE = Vector2(390, 844)
const SCREEN_WIDTH = 390
const SCREEN_HEIGHT = 844

# UI 영역 높이
const TOP_BAR_HEIGHT = 60
const BOTTOM_TAB_BAR_HEIGHT = 60
const CONTENT_HEIGHT = SCREEN_HEIGHT - TOP_BAR_HEIGHT - BOTTOM_TAB_BAR_HEIGHT  # 724px

# Safe Area (노치/홈 버튼 고려)
const SAFE_AREA_TOP = 44      # 노치 영역
const SAFE_AREA_BOTTOM = 34   # 홈 인디케이터 영역

# ============================================
# BORDER & RADIUS
# ============================================

const BORDER = {
	"thin": 1,
	"medium": 2,
	"thick": 3,
}

const RADIUS = {
	"small": 4,
	"medium": 8,
	"large": 12,
	"xlarge": 16,
	"round": 999,  # 완전한 원형
}

# ============================================
# ANIMATION DURATIONS (초 단위)
# ============================================

const ANIMATION = {
	"fast": 0.15,      # 빠른 전환 (호버, 클릭)
	"normal": 0.3,     # 일반 전환 (화면 전환)
	"slow": 0.5,       # 느린 전환 (모달, 페이드)
	"extra_slow": 1.0, # 매우 느린 (플로팅 애니메이션)
}

# ============================================
# EASING CURVES
# ============================================

const EASING = {
	"ease_in": Tween.EASE_IN,
	"ease_out": Tween.EASE_OUT,
	"ease_in_out": Tween.EASE_IN_OUT,
	"linear": Tween.TRANS_LINEAR,
	"quad": Tween.TRANS_QUAD,
	"cubic": Tween.TRANS_CUBIC,
	"sine": Tween.TRANS_SINE,
}

# ============================================
# Z-INDEX (레이어 순서)
# ============================================

const Z_INDEX = {
	"background": -100,
	"content": 0,
	"ui": 100,
	"top_bar": 200,
	"bottom_tab_bar": 200,
	"modal": 300,
	"overlay": 400,
	"tooltip": 500,
}

# ============================================
# CARD DIMENSIONS
# ============================================

const CARD = {
	"width": 106,
	"height": 148,
	"spacing": 12,
	"grid_columns": 3,  # Card Library 그리드
}

# ============================================
# HELPER FUNCTIONS
# ============================================

# 색상 가져오기 (기본값 포함)
static func get_color(key: String, default: Color = Color.WHITE) -> Color:
	return COLORS.get(key, default)

# 간격 가져오기
static func get_spacing(key: String) -> int:
	return SPACING.get(key, SPACING.md)

# 폰트 크기 가져오기
static func get_font_size(key: String) -> int:
	return FONT_SIZES.get(key, FONT_SIZES.body)

# 8px 그리드에 스냅
static func snap_to_grid(value: float) -> float:
	return floor(value / 8.0) * 8.0

# Vector2를 그리드에 스냅
static func snap_position_to_grid(pos: Vector2) -> Vector2:
	return Vector2(
		snap_to_grid(pos.x),
		snap_to_grid(pos.y)
	)

# 색상에 알파 적용 (투명도)
static func with_alpha(color: Color, alpha: float) -> Color:
	var result = color
	result.a = alpha
	return result

# 색상 밝게/어둡게
static func lighten(color: Color, amount: float = 0.2) -> Color:
	return color.lightened(amount)

static func darken(color: Color, amount: float = 0.2) -> Color:
	return color.darkened(amount)

# ============================================
# THEME APPLICATION HELPERS
# ============================================

# Panel/Control에 기본 스타일 적용 (autoload 인스턴스에서 호출되므로 static 제거)
func apply_panel_style(panel: Panel) -> void:
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = get_color("panel")
	stylebox.border_width_left = BORDER.thin
	stylebox.border_width_top = BORDER.thin
	stylebox.border_width_right = BORDER.thin
	stylebox.border_width_bottom = BORDER.thin
	stylebox.border_color = get_color("panel_border")
	stylebox.corner_radius_top_left = RADIUS.medium
	stylebox.corner_radius_top_right = RADIUS.medium
	stylebox.corner_radius_bottom_left = RADIUS.medium
	stylebox.corner_radius_bottom_right = RADIUS.medium
	panel.add_theme_stylebox_override("panel", stylebox)

# Button에 기본 스타일 적용 (autoload 인스턴스에서 호출되므로 static 제거)
func apply_button_style(button: Button, color_key: String = "primary") -> void:
	# Normal
	var stylebox_normal = StyleBoxFlat.new()
	stylebox_normal.bg_color = get_color(color_key)
	stylebox_normal.corner_radius_top_left = RADIUS.medium
	stylebox_normal.corner_radius_top_right = RADIUS.medium
	stylebox_normal.corner_radius_bottom_left = RADIUS.medium
	stylebox_normal.corner_radius_bottom_right = RADIUS.medium
	button.add_theme_stylebox_override("normal", stylebox_normal)
	
	# Hover
	var stylebox_hover = StyleBoxFlat.new()
	stylebox_hover.bg_color = lighten(get_color(color_key), 0.1)
	stylebox_hover.corner_radius_top_left = RADIUS.medium
	stylebox_hover.corner_radius_top_right = RADIUS.medium
	stylebox_hover.corner_radius_bottom_left = RADIUS.medium
	stylebox_hover.corner_radius_bottom_right = RADIUS.medium
	button.add_theme_stylebox_override("hover", stylebox_hover)
	
	# Pressed
	var stylebox_pressed = StyleBoxFlat.new()
	stylebox_pressed.bg_color = darken(get_color(color_key), 0.1)
	stylebox_pressed.corner_radius_top_left = RADIUS.medium
	stylebox_pressed.corner_radius_top_right = RADIUS.medium
	stylebox_pressed.corner_radius_bottom_left = RADIUS.medium
	stylebox_pressed.corner_radius_bottom_right = RADIUS.medium
	button.add_theme_stylebox_override("pressed", stylebox_pressed)
	
	# Font Color
	button.add_theme_color_override("font_color", get_color("text"))

# Label에 폰트 색상 적용 (autoload 인스턴스에서 호출되므로 static 제거)
func apply_label_style(label: Label, color_key: String = "text", size_key: String = "body") -> void:
	label.add_theme_color_override("font_color", get_color(color_key))
	# Note: Godot 4에서는 Theme Resource로 폰트 크기 관리 권장

# ============================================
# READY (Autoload 초기화)
# ============================================

func _ready():
	print("✅ UITheme loaded - Dream Theme Design System initialized")
	print("   Screen: %dx%d" % [SCREEN_WIDTH, SCREEN_HEIGHT])
	print("   Colors: ", COLORS.keys().size(), " defined")
	print("   Spacing: 8px grid system")
