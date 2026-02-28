# HomeHeroSprite.gd
# 홈 화면 전용 걷기 스프라이트 — PlayerSpriteAnimator 상속
# 홈 화면에서는 항상 WALK 애니메이션 재생
extends PlayerSpriteAnimator


func _ready() -> void:
	# 디스플레이 크기 (씬에서 64x64로 설정됨, 여기서도 최소 크기 보장)
	custom_minimum_size = Vector2(64, 64)

	# 부모 초기화 (텍스처 로드, Atlas 빌드, 셰이더 적용)
	super._ready()

	# 홈 화면에서는 항상 WALK
	play(AnimState.WALK)

	print("[HomeHeroSprite] Walk sprite ready: %d atlas frames" % atlas_frames.size())
