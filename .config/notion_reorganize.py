#!/usr/bin/env python3
"""
🎮 Notion 워크스페이스 재정렬 스크립트
GeekBrox 프로젝트 구조에 맞게 Notion 페이지를 정렬합니다.

사용법:
  python3 notion_reorganize.py
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

# Parent Page ID (GeekBrox)
PARENT_PAGE_ID = '30dea427-4fb6-80ca-8df3-ce41f3bd7bf3'

# 헤더 설정
HEADERS = {
    'Authorization': f'Bearer {NOTION_API_KEY}',
    'Content-Type': 'application/json',
    'Notion-Version': NOTION_VERSION
}


def create_page(title, parent_page_id, properties=None, children=None):
    """Notion에 새 페이지 생성"""
    payload = {
        'parent': {
            'type': 'page_id',
            'page_id': parent_page_id
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
    
    if properties:
        payload['properties'].update(properties)
    
    if children:
        payload['children'] = children
    
    response = requests.post(
        f'{NOTION_BASE_URL}/pages',
        headers=HEADERS,
        json=payload
    )
    
    return response.json()


def create_heading(content, level=2):
    """제목 블록"""
    return {
        'object': 'block',
        'type': f'heading_{level}',
        f'heading_{level}': {
            'rich_text': [{
                'type': 'text',
                'text': {'content': content}
            }],
            'color': 'default'
        }
    }


def create_paragraph(content, bold=False, italic=False, code=False):
    """단락 블록"""
    return {
        'object': 'block',
        'type': 'paragraph',
        'paragraph': {
            'rich_text': [{
                'type': 'text',
                'text': {'content': content},
                'annotations': {
                    'bold': bold,
                    'italic': italic,
                    'code': code
                }
            }]
        }
    }


def create_bulleted_list(content):
    """불릿 리스트"""
    return {
        'object': 'block',
        'type': 'bulleted_list_item',
        'bulleted_list_item': {
            'rich_text': [{
                'type': 'text',
                'text': {'content': content}
            }]
        }
    }


def create_divider():
    """구분선"""
    return {
        'object': 'block',
        'type': 'divider',
        'divider': {}
    }


def create_main_dashboard():
    """메인 대시보드 페이지"""
    
    print('📊 메인 대시보드 페이지 생성...')
    
    title = '🎮 Dream Collector — 프로젝트 대시보드'
    
    children = []
    
    # 헤더
    children.append(create_paragraph('프로젝트 명: Dream Collector (꿈 수집가)', bold=True))
    children.append(create_paragraph('장르: Roguelike + Deckbuilding + Idle'))
    children.append(create_paragraph('플랫폼: Godot 4.x (모바일 포트레이트)'))
    children.append(create_paragraph(f'마지막 업데이트: {datetime.now().strftime("%Y-%m-%d %H:%M")}'))
    
    children.append(create_divider())
    
    # 프로젝트 진행도
    children.append(create_heading('📈 프로젝트 진행도', level=2))
    children.append(create_paragraph('전체: 70% ████████░░', bold=True))
    children.append(create_bulleted_list('기획(기획팀): 100% ██████████ ✅'))
    children.append(create_bulleted_list('개발(Game팀): 65% ██████░░░░ 🟨'))
    children.append(create_bulleted_list('운영(OPS팀): 0% ░░░░░░░░░░ 🔴 (3/9 시작)'))
    
    children.append(create_divider())
    
    # 마일스톤
    children.append(create_heading('🗓️ 주요 마일스톤', level=2))
    children.append(create_bulleted_list('3/6 (오늘): Game팀 Step 1 완료'))
    children.append(create_bulleted_list('3/8: Game팀 Step 2 완료'))
    children.append(create_bulleted_list('3/9: Game팀 Step 3~4 + OPS팀 시뮬레이션 시작'))
    children.append(create_bulleted_list('3/10: Game팀 Step 5 완료 + 기획 정리서'))
    children.append(create_bulleted_list('3/12: OPS팀 최종 보고서'))
    children.append(create_bulleted_list('3/13: 프로젝트 최종 완료'))
    
    children.append(create_divider())
    
    # 주요 시스템
    children.append(create_heading('⚙️ 주요 시스템', level=2))
    children.append(create_bulleted_list('🎭 캐릭터: 6가지 스탯 + 20가지 특성'))
    children.append(create_bulleted_list('🎴 카드: 200개 (ATTACK/SKILL/POWER/CURSE)'))
    children.append(create_bulleted_list('⚔️ 아이템: 90개 (무기/방어구/반지/목걸이)'))
    children.append(create_bulleted_list('⚡ 전투: ATB(Active Time Battle) 시스템'))
    children.append(create_bulleted_list('💰 경제: 골드/보석 + 월간 2M 골드 + 400 보석'))
    
    children.append(create_divider())
    
    # 최근 개발 일지
    children.append(create_heading('📝 최근 개발 일지', level=2))
    children.append(create_paragraph('아래 "개발 일지" 섹션에서 상세 내용 확인'))
    
    response = create_page(title, PARENT_PAGE_ID, children=children)
    return response.get('id'), title


def create_development_log_page():
    """개발 일지 페이지"""
    
    print('📋 개발 일지 페이지 생성...')
    
    title = '📋 개발 일지 (2026-03)'
    
    children = []
    
    children.append(create_heading('2026년 3월 개발 진행도', level=2))
    
    # 3월 6일 일지
    children.append(create_heading('3월 6일 (금) - Cowork 온보딩 완료', level=3))
    children.append(create_paragraph('상태: 🟨 진행 중 (70% 완료)', bold=True))
    
    children.append(create_paragraph('주요 성과:', bold=True))
    children.append(create_bulleted_list('✅ Dream Collector 폴더 최종 정리 (103개 문서 정렬)'))
    children.append(create_bulleted_list('✅ Cowork 온보딩 패키지 완성 (6개 학습 문서)'))
    children.append(create_bulleted_list('✅ Notion 워크스페이스 재정렬'))
    children.append(create_bulleted_list('✅ Git 커밋 (6번째: 4cae4ad)'))
    
    children.append(create_paragraph('Git 활동:', bold=True))
    children.append(create_bulleted_list('4cae4ad: Cowork 온보딩 학습 자료 생성'))
    children.append(create_bulleted_list('2c3f695: 폴더 재정렬 + README.md 작성'))
    children.append(create_bulleted_list('60dc573: Notion API 업로드 스크립트'))
    
    children.append(create_paragraph('생성된 문서:', bold=True))
    children.append(create_bulleted_list('COWORK_ONBOARDING_GUIDE.md'))
    children.append(create_bulleted_list('CHARACTER_SYSTEM_DETAILED.md'))
    children.append(create_bulleted_list('CARD_SYSTEM_SUMMARY.md'))
    children.append(create_bulleted_list('ITEM_SYSTEM_SUMMARY.md'))
    children.append(create_bulleted_list('COMBAT_INTEGRATION_GUIDE.md'))
    children.append(create_bulleted_list('SYSTEM_VALIDATION_CHECKLIST.md'))
    
    children.append(create_paragraph('Next Steps:', bold=True))
    children.append(create_bulleted_list('⏳ 오후 3시: Game팀 Step 1 마일스톤 검증'))
    children.append(create_bulleted_list('⏳ 오후 4시: OPS팀 진행 상황 확인'))
    children.append(create_bulleted_list('⏳ 오후 5시: Steve 종합 일일 리포트'))
    
    response = create_page(title, PARENT_PAGE_ID, children=children)
    return response.get('id'), title


def create_game_structure():
    """게임 구조별 섹션 생성"""
    
    print('🎮 게임 구조 섹션 생성...')
    
    structure = {
        '🎭 캐릭터 & 특성': {
            'desc': '캐릭터 스탯, 특성, 성장 시스템',
            'docs': [
                'CHARACTER_SYSTEM_DETAILED.md',
                'CHARACTER_DESIGN_SYSTEM.md',
                'CHARACTER_TRAITS_ENHANCED.md'
            ]
        },
        '🎴 카드 시스템': {
            'desc': '200개 카드, 덱 빌딩, 콤보 시스템',
            'docs': [
                'CARD_SYSTEM_SUMMARY.md',
                'CARD_200_FINAL_DATA.md',
                'TAROT_SYSTEM_GUIDE.md'
            ]
        },
        '⚔️ 아이템 & 장비': {
            'desc': '90개 아이템, 장비 강화, 보너스 시스템',
            'docs': [
                'ITEM_SYSTEM_SUMMARY.md',
                'EQUIPMENT_SYSTEM_GDD_FINAL.md',
                'EQUIPMENT_BALANCE_SIMULATION.md'
            ]
        },
        '⚡ 전투 시스템': {
            'desc': 'ATB 시스템, 카드 연동, 밸런싱',
            'docs': [
                'COMBAT_INTEGRATION_GUIDE.md',
                'COMBAT_SYSTEM_MASTER_SPEC.md',
                'ATB_DETAILED_GUIDE.md'
            ]
        },
        '💰 게임 경제': {
            'desc': '골드/보석, 보상 시스템, 밸런싱',
            'docs': [
                'GAME_ECONOMY_MANAGEMENT.md',
                'ITEM_ACQUISITION_SYSTEM.md',
                'GACHA_ENHANCEMENT_FINAL.md'
            ]
        }
    }
    
    results = {}
    
    for section_name, section_data in structure.items():
        print(f'  → {section_name} 페이지 생성...')
        
        children = []
        children.append(create_paragraph(section_data['desc'], italic=True))
        children.append(create_divider())
        
        children.append(create_heading('관련 문서', level=2))
        for doc in section_data['docs']:
            children.append(create_bulleted_list(doc))
        
        response = create_page(section_name, PARENT_PAGE_ID, children=children)
        results[section_name] = response.get('id')
    
    return results


def organize_notion():
    """전체 Notion 워크스페이스 정렬"""
    
    print('=' * 70)
    print('🎮 GeekBrox Notion 워크스페이스 재정렬')
    print('=' * 70)
    print()
    
    if not NOTION_API_KEY:
        print('❌ 오류: NOTION_API_KEY가 설정되지 않았습니다.')
        print('📝 .config/.env 파일에서 NOTION_API_KEY를 확인하세요.')
        return False
    
    try:
        # 1. 메인 대시보드
        print('📊 Step 1: 메인 대시보드 생성')
        dashboard_id, dashboard_title = create_main_dashboard()
        if dashboard_id:
            print(f'  ✅ {dashboard_title}')
            print(f'     ID: {dashboard_id}')
        else:
            print(f'  ❌ 생성 실패')
        
        print()
        
        # 2. 개발 일지
        print('📋 Step 2: 개발 일지 페이지 생성')
        log_id, log_title = create_development_log_page()
        if log_id:
            print(f'  ✅ {log_title}')
            print(f'     ID: {log_id}')
        else:
            print(f'  ❌ 생성 실패')
        
        print()
        
        # 3. 게임 구조별 섹션
        print('🎮 Step 3: 게임 시스템 섹션 생성')
        game_sections = create_game_structure()
        for section, section_id in game_sections.items():
            print(f'  ✅ {section}')
            print(f'     ID: {section_id}')
        
        print()
        print('=' * 70)
        print('✅ Notion 워크스페이스 재정렬 완료!')
        print('=' * 70)
        print()
        print('📊 생성된 페이지:')
        print(f'  1. 메인 대시보드')
        print(f'  2. 개발 일지')
        print(f'  3. 5가지 게임 시스템 섹션')
        print()
        print('🔗 GeekBrox 워크스페이스:')
        print(f'   https://www.notion.so/GeekBrox-{PARENT_PAGE_ID}')
        print()
        
        return True
        
    except Exception as e:
        print(f'❌ 오류 발생: {e}')
        return False


if __name__ == '__main__':
    success = organize_notion()
    exit(0 if success else 1)
