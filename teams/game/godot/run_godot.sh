#!/bin/bash
# run_godot.sh — Atlas 게임팀장이 bash로 호출하는 Godot 제어 스크립트
# 사용법: ./run_godot.sh [command]
#
# 텔레그램 → Atlas → 게임팀장 → 이 스크립트

PROJECT_DIR="$(dirname "$0")/dream-collector"
GODOT="godot"
TIMEOUT=30

case "$1" in

  # 테스트 실행
  test)
    echo "🧪 테스트 실행 중..."
    $GODOT --headless --script "$PROJECT_DIR/tests/run_tests.gd" --quit-after $TIMEOUT 2>&1
    ;;

  # 게임 현황 보고
  status)
    echo "📊 Dream Collector 현황"
    echo "프로젝트 경로: $PROJECT_DIR"
    echo ""
    echo "[파일 목록]"
    find "$PROJECT_DIR" -name "*.gd" | sort
    echo ""
    echo "[최근 수정 파일]"
    find "$PROJECT_DIR" -name "*.gd" -newer "$PROJECT_DIR/project.godot" 2>/dev/null | head -5
    ;;

  # export (빌드)
  build)
    echo "🏗️ 빌드 중..."
    mkdir -p "$PROJECT_DIR/../exports"
    $GODOT --headless --path "$PROJECT_DIR" --export-debug "Mac" "$PROJECT_DIR/../exports/dream-collector.app" 2>&1
    ;;

  # GDScript 파일 검증
  validate)
    echo "✅ GDScript 검증 중..."
    $GODOT --headless --path "$PROJECT_DIR" --check-only 2>&1
    echo "검증 완료"
    ;;

  # Git 커밋
  commit)
    MESSAGE="${2:-feat: Godot 게임 업데이트}"
    cd /Users/stevemacbook/Projects/geekbrox
    git add teams/game/godot/
    git commit -m "$MESSAGE"
    echo "✅ Git 커밋 완료: $MESSAGE"
    ;;

  # 도움말
  *)
    echo "사용법: run_godot.sh [command]"
    echo ""
    echo "  test      — 자동 테스트 실행 (headless)"
    echo "  status    — 프로젝트 현황 보고"
    echo "  build     — 게임 빌드"
    echo "  validate  — GDScript 오류 검증"
    echo "  commit    — Git 커밋"
    ;;
esac
