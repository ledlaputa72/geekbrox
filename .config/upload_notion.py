#!/usr/bin/env python3
"""
🚀 Notion API 업로드 스크립트
Dream Collector 개발 일지를 Notion에 업로드합니다.
"""

import os
import json
import requests
from datetime import datetime
from dotenv import load_dotenv

# 환경 변수 로드
dotenv_path = os.path.join(os.path.dirname(__file__), '.env')
load_dotenv(dotenv_path)

# Notion API 설정
NOTION_API_KEY = os.getenv('NOTION_API_KEY')
NOTION_VERSION = '2022-06-28'
NOTION_BASE_URL = 'https://api.notion.com/v1'

# Parent Page ID (GeekBrox 페이지)
PARENT_PAGE_ID = '30dea427-4fb6-80ca-8df3-ce41f3bd7bf3'

# 헤더 설정
HEADERS = {
    'Authorization': f'Bearer {NOTION_API_KEY}',
    'Content-Type': 'application/json',
    'Notion-Version': NOTION_VERSION
}


def create_page(title, properties=None, children=None):
    """Notion에 페이지 생성"""
    payload = {
        'parent': {
            'type': 'page_id',
            'page_id': PARENT_PAGE_ID
        },
        'properties': {
            'title': {
                'title': [
                    {
                        'text': {
                            'content': title
                        }
                    }
                ]
            }
        }
    }
    
    # 추가 properties 병합
    if properties:
        payload['properties'].update(properties)
    
    # Children 추가
    if children:
        payload['children'] = children
    
    response = requests.post(
        f'{NOTION_BASE_URL}/pages',
        headers=HEADERS,
        json=payload
    )
    
    return response.json()


def create_heading(content, level=2):
    """제목 블록 생성"""
    return {
        'object': 'block',
        'type': f'heading_{level}',
        f'heading_{level}': {
            'rich_text': [
                {
                    'type': 'text',
                    'text': {
                        'content': content
                    }
                }
            ],
            'color': 'default'
        }
    }


def create_paragraph(content, bold=False, code=False):
    """단락 블록 생성"""
    return {
        'object': 'block',
        'type': 'paragraph',
        'paragraph': {
            'rich_text': [
                {
                    'type': 'text',
                    'text': {
                        'content': content
                    },
                    'annotations': {
                        'bold': bold,
                        'code': code
                    }
                }
            ]
        }
    }


def create_bulleted_list(content):
    """불릿 리스트 생성"""
    return {
        'object': 'block',
        'type': 'bulleted_list_item',
        'bulleted_list_item': {
            'rich_text': [
                {
                    'type': 'text',
                    'text': {
                        'content': content
                    }
                }
            ]
        }
    }


def create_table_of_contents():
    """목차 블록"""
    return {
        'object': 'block',
        'type': 'table_of_contents',
        'table_of_contents': {
            'color': 'gray'
        }
    }


def upload_development_log():
    """개발 일지 페이지 업로드"""
    
    print('📊 Dream Collector 개발 일지 → Notion 업로드')
    print('=' * 60)
    print()
    
    # 페이지 제목
    title = '🎮 Dream Collector 개발 일지 (2026-03-06)'
    
    # Children 블록 구성
    children = []
    
    # 1. 소개 섹션
    children.append(create_paragraph('프로젝트: Dream Collector (꿈 수집가)'))
    children.append(create_paragraph('날짜: 2026년 3월 6일 (금요일)'))
    children.append(create_paragraph('상태: 🟢 진행 중 (70% 완료)'))
    children.append({
        'object': 'block',
        'type': 'divider',
        'divider': {}
    })
    
    # 2. 오늘의 주요 성과
    children.append(create_heading('📊 오늘의 주요 성과', level=2))
    children.append(create_bulleted_list('✅ 게임 경제 시스템 완성 (10개 보상 파일)'))
    children.append(create_bulleted_list('✅ 설계 폴더 정리 (103개 문서)'))
    children.append(create_bulleted_list('✅ Git 커밋 (3개, 252+ 파일)'))
    children.append(create_bulleted_list('✅ .config 폴더 정리 (API 문서화)'))
    
    # 3. Git 커밋 요약
    children.append(create_heading('🔧 Git 커밋 요약', level=2))
    
    commits = [
        {
            'num': '1️⃣',
            'hash': '5148a98',
            'msg': '게임 경제 시스템 + 설계 폴더 정리',
            'files': '252 files',
            'lines': '37,595 additions'
        },
        {
            'num': '2️⃣',
            'hash': '2f37ce3',
            'msg': '개발 일지 추가',
            'files': '1 file',
            'lines': '492 insertions'
        },
        {
            'num': '3️⃣',
            'hash': 'c8bbc25',
            'msg': '.config 폴더 정리',
            'files': '3 files',
            'lines': '370 insertions'
        }
    ]
    
    for commit in commits:
        children.append(create_heading(f'{commit["num"]} {commit["msg"]}', level=3))
        children.append(create_paragraph(f'커밋: {commit["hash"]}'))
        children.append(create_paragraph(f'변경: {commit["files"]}, {commit["lines"]}'))
    
    # 4. 프로젝트 진행도
    children.append(create_heading('📈 프로젝트 진행도', level=2))
    children.append(create_paragraph('전체 진행율: 70% (목표: 3/13 완료)', bold=True))
    children.append(create_bulleted_list('UI 시스템: 100% ✅'))
    children.append(create_bulleted_list('카드 시스템: 100% ✅'))
    children.append(create_bulleted_list('장비 시스템: 95% 🟨'))
    children.append(create_bulleted_list('게임 경제: 100% ✅'))
    children.append(create_bulleted_list('설계 문서: 100% ✅'))
    children.append(create_bulleted_list('Godot 코드: 85% 🟨'))
    
    # 5. 다음 작업
    children.append(create_heading('🎯 다음 작업', level=2))
    children.append(create_heading('P0 (긴급)', level=3))
    children.append(create_bulleted_list('Game팀 Step 1 진행 상황 확인 (오후 1시)'))
    children.append(create_bulleted_list('Step 1 마일스톤 검증 (오후 3시)'))
    children.append(create_bulleted_list('Steve에게 일일 리포트 (오후 5시)'))
    
    children.append(create_heading('P1 (높음)', level=3))
    children.append(create_bulleted_list('Godot 코드 8개 파일 완성'))
    children.append(create_bulleted_list('게임 빌드 테스트'))
    children.append(create_bulleted_list('밸런싱 시뮬레이션'))
    
    # 페이지 생성
    print(f'🔄 Notion 페이지 생성 중: "{title}"')
    print()
    
    response = create_page(title, children=children)
    
    if 'id' in response:
        page_id = response['id']
        print(f'✅ 페이지 생성 성공!')
        print(f'📄 Page ID: {page_id}')
        print(f'🔗 URL: https://www.notion.so/{page_id}')
        print()
        print('=' * 60)
        print(f'📊 업로드 완료! Dream Collector 개발 일지가 생성되었습니다.')
        return True
    else:
        print(f'❌ 페이지 생성 실패!')
        print(f'응답: {json.dumps(response, indent=2, ensure_ascii=False)}')
        return False


if __name__ == '__main__':
    if not NOTION_API_KEY:
        print('❌ 오류: NOTION_API_KEY가 설정되지 않았습니다.')
        print('📝 .config/.env 파일에서 NOTION_API_KEY를 확인하세요.')
        exit(1)
    
    upload_development_log()
