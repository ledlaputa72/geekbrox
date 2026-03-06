#!/bin/bash

# 🚀 Notion API 업로드 스크립트
# Dream Collector 개발 일지를 Notion에 업로드합니다.

# ──────────────────────────────────────────────────────
# 환경 변수 로드
# ──────────────────────────────────────────────────────
export $(cat .env | grep -v '#' | xargs)

# ──────────────────────────────────────────────────────
# 설정
# ──────────────────────────────────────────────────────
NOTION_API_KEY="$NOTION_API_KEY"
NOTION_VERSION="2022-06-28"
WORKSPACE_ID="$Notion_Workspace"

# Parent Page ID (Dream Collector 프로젝트 페이지)
# 참고: 이 값은 기존 Notion 페이지의 ID입니다
# https://www.notion.so/[PAGE_ID] 형식에서 추출 가능
PARENT_PAGE_ID="${1:-f85ea427-4fb6-813a-8aac-000351bacda1}"

# ──────────────────────────────────────────────────────
# 함수: Notion에 페이지 생성
# ──────────────────────────────────────────────────────
create_notion_page() {
  local title="$1"
  local content="$2"
  
  echo "🔄 Notion에 페이지 생성 중: $title"
  
  curl -X POST "https://api.notion.com/v1/pages" \
    -H "Authorization: Bearer $NOTION_API_KEY" \
    -H "Content-Type: application/json" \
    -H "Notion-Version: $NOTION_VERSION" \
    -d "{
      \"parent\": {
        \"type\": \"page_id\",
        \"page_id\": \"${PARENT_PAGE_ID//-/}\"
      },
      \"properties\": {
        \"title\": {
          \"title\": [
            {
              \"text\": {
                \"content\": \"$title\"
              }
            }
          ]
        }
      },
      \"children\": [
        {
          \"object\": \"block\",
          \"type\": \"paragraph\",
          \"paragraph\": {
            \"rich_text\": [
              {
                \"type\": \"text\",
                \"text\": {
                  \"content\": \"$content\"
                }
              }
            ]
          }
        }
      ]
    }"
  
  echo "✅ 페이지 생성 완료!"
}

# ──────────────────────────────────────────────────────
# 함수: Notion 계정 확인
# ──────────────────────────────────────────────────────
verify_notion_connection() {
  echo "🔍 Notion API 연결 확인 중..."
  
  response=$(curl -s -X GET "https://api.notion.com/v1/users/me" \
    -H "Authorization: Bearer $NOTION_API_KEY" \
    -H "Notion-Version: $NOTION_VERSION")
  
  if echo "$response" | grep -q "\"object\":\"user\""; then
    echo "✅ Notion API 연결 성공!"
    return 0
  else
    echo "❌ Notion API 연결 실패!"
    echo "응답: $response"
    return 1
  fi
}

# ──────────────────────────────────────────────────────
# 메인 실행
# ──────────────────────────────────────────────────────
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Dream Collector 개발 일지 → Notion 업로드"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Notion 연결 확인
verify_notion_connection || exit 1

echo ""
echo "🎯 업로드 방식:"
echo "  A) 수동 업로드: Notion에서 직접 복사 붙여넣기"
echo "  B) API 자동화: 이 스크립트 실행"
echo ""
echo "현재 설정:"
echo "  • API Key: ${NOTION_API_KEY:0:20}..."
echo "  • Workspace: ${WORKSPACE_ID:0:20}..."
echo "  • Parent Page: ${PARENT_PAGE_ID:0:20}..."
echo ""

read -p "계속하시겠습니까? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "✅ 페이지 생성을 진행합니다."
else
  echo "❌ 취소되었습니다."
  exit 0
fi
