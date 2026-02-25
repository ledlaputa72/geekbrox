extends Control
class_name BaseBottomUI

"""
BaseBottomUI - 모든 BottomUI의 공통 부모 클래스

각 BottomUI는 이 클래스를 상속받아 구현:
- ExplorationBottomUI: 이동 중 이벤트 로그
- CombatBottomUI: 전투 중 카드 + 로그
- ShopBottomUI: 상점 아이템 그리드
- NPCDialogBottomUI: NPC 대화 + 선택지
- StoryBottomUI: 스토리 텍스트 + 선택지

시그널 인터페이스:
- ui_action_requested: UI에서 액션 요청 (카드 사용, 구매, 선택지 등)
- ui_ready: UI 초기화 완료
- ui_closed: UI 닫기 요청
"""

# 공통 시그널
signal ui_action_requested(action_type: String, data: Dictionary)
signal ui_ready()
signal ui_closed()

# 오버라이드 가능한 가상 함수들
func _on_enter():
	"""BottomUI가 활성화될 때 호출됨 (씬 전환 후)"""
	pass

func _on_exit():
	"""BottomUI가 비활성화될 때 호출됨 (씬 전환 전)"""
	pass

func update_data(data: Dictionary):
	"""외부에서 데이터 업데이트 시 호출됨"""
	pass

# 유틸리티 함수들
func request_action(action_type: String, data: Dictionary = {}):
	"""액션 요청 헬퍼 함수"""
	ui_action_requested.emit(action_type, data)

func close_ui():
	"""UI 닫기 헬퍼 함수"""
	ui_closed.emit()
