'use client'

import { useState } from 'react'
import { ScrollArea } from '@/components/ui/scroll-area'
import { Badge } from '@/components/ui/badge'
import { ChevronDown } from 'lucide-react'

interface Card {
  id: string
  name: string
  description: string
  energyCost: number
  rarity: 'common' | 'uncommon' | 'rare' | 'legendary'
  category: 'collection' | 'action' | 'synergy' | 'event'
  image: string
  collected: boolean
}

const mockCards: Card[] = [
  {
    id: '1',
    name: '화염구',
    description: '적에게 3 데미지를 입힙니다',
    energyCost: 2,
    rarity: 'common',
    category: 'action',
    image: '🔥',
    collected: true
  },
  {
    id: '2',
    name: '마나 크리스탈',
    description: '마나를 2 회복합니다',
    energyCost: 1,
    rarity: 'uncommon',
    category: 'collection',
    image: '💎',
    collected: true
  },
  {
    id: '3',
    name: '드래곤 소환',
    description: '강력한 드래곤을 소환합니다',
    energyCost: 8,
    rarity: 'legendary',
    category: 'action',
    image: '🐉',
    collected: false
  },
  {
    id: '4',
    name: '시너지 부스트',
    description: '모든 카드 효과 +50%',
    energyCost: 4,
    rarity: 'rare',
    category: 'synergy',
    image: '⚡',
    collected: true
  },
  {
    id: '5',
    name: '행운의 동전',
    description: '골드 획득량 2배',
    energyCost: 3,
    rarity: 'rare',
    category: 'event',
    image: '🪙',
    collected: false
  },
  {
    id: '6',
    name: '치유 물약',
    description: 'HP를 5 회복합니다',
    energyCost: 1,
    rarity: 'common',
    category: 'collection',
    image: '🧪',
    collected: true
  }
]

const categories = [
  { id: 'all', label: '전체' },
  { id: 'collection', label: '수집' },
  { id: 'action', label: '액션' },
  { id: 'synergy', label: '시너지' },
  { id: 'event', label: '이벤트' }
]

const rarityColors = {
  common: '#888888',
  uncommon: '#4CAF50',
  rare: '#7B68EE',
  legendary: '#FFD700'
}

export default function CardLibrary() {
  const [selectedCategory, setSelectedCategory] = useState('all')
  const [sortBy, setSortBy] = useState('name')
  const [rarityFilter, setRarityFilter] = useState('all')

  const filteredCards = mockCards.filter(card => {
    if (selectedCategory !== 'all' && card.category !== selectedCategory) return false
    if (rarityFilter !== 'all' && card.rarity !== rarityFilter) return false
    return true
  })

  const collectedCount = mockCards.filter(card => card.collected).length
  const totalCount = mockCards.length

  return (
    <div 
      className="w-[390px] h-[844px] mx-auto relative overflow-hidden"
      style={{ backgroundColor: 'var(--color-bg-main)' }}
    >
      {/* Header */}
      <div className="h-16 flex items-center justify-between px-4 pt-11">
        <div className="flex items-center gap-2">
          <span className="text-2xl">🃏</span>
          <h1 className="text-lg font-bold text-white">카드 라이브러리</h1>
        </div>
        <div className="text-sm font-medium" style={{ color: 'var(--color-primary)' }}>
          {collectedCount}/{totalCount}
        </div>
      </div>

      {/* Filter Bar */}
      <div className="h-11 px-4 mb-4">
        <div className="flex items-center gap-2 h-full">
          <ScrollArea className="flex-1">
            <div className="flex gap-2 pb-2">
              {categories.map((category) => (
                <button
                  key={category.id}
                  onClick={() => setSelectedCategory(category.id)}
                  className={`px-3 py-1.5 rounded-full text-xs font-medium whitespace-nowrap transition-all ${
                    selectedCategory === category.id
                      ? 'text-white shadow-lg'
                      : 'text-gray-300'
                  }`}
                  style={{
                    backgroundColor: selectedCategory === category.id 
                      ? 'var(--color-primary)' 
                      : 'var(--color-bg-panel)',
                    backdropFilter: 'blur(10px)'
                  }}
                >
                  {category.label}
                </button>
              ))}
            </div>
          </ScrollArea>
          
          <div className="flex gap-2">
            <button 
              className="flex items-center gap-1 px-3 py-1.5 rounded-full text-xs font-medium text-gray-300"
              style={{ 
                backgroundColor: 'var(--color-bg-panel)',
                backdropFilter: 'blur(10px)'
              }}
            >
              희귀도 <ChevronDown className="w-3 h-3" />
            </button>
            <button 
              className="flex items-center gap-1 px-3 py-1.5 rounded-full text-xs font-medium text-gray-300"
              style={{ 
                backgroundColor: 'var(--color-bg-panel)',
                backdropFilter: 'blur(10px)'
              }}
            >
              정렬 <ChevronDown className="w-3 h-3" />
            </button>
          </div>
        </div>
      </div>

      {/* Card Grid */}
      <ScrollArea className="flex-1 px-4">
        <div className="grid grid-cols-3 gap-3 pb-40">
          {filteredCards.map((card) => (
            <div
              key={card.id}
              className="relative w-[100px] h-[140px] rounded-2xl overflow-hidden transition-all duration-200 hover:scale-105"
              style={{
                backgroundColor: 'var(--color-bg-panel)',
                backdropFilter: 'blur(10px)',
                border: `2px solid ${rarityColors[card.rarity]}`,
                boxShadow: card.rarity === 'legendary' 
                  ? `0 0 20px ${rarityColors[card.rarity]}40`
                  : card.rarity === 'rare'
                  ? `0 0 15px ${rarityColors[card.rarity]}30`
                  : 'none',
                opacity: card.collected ? 1 : 0.6
              }}
            >
              {/* Energy Cost Badge */}
              <div 
                className="absolute top-2 left-2 w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold text-white z-10"
                style={{ backgroundColor: 'var(--color-primary)' }}
              >
                {card.energyCost}
              </div>

              {/* Card Image Area (60%) */}
              <div className="h-[84px] flex items-center justify-center text-3xl bg-gradient-to-b from-transparent to-black/20">
                {card.image}
              </div>

              {/* Card Info Area (40%) */}
              <div className="h-[56px] p-2 flex flex-col justify-between">
                <h3 className="text-xs font-bold text-white leading-tight line-clamp-1">
                  {card.name}
                </h3>
                <p className="text-[10px] text-gray-300 leading-tight line-clamp-2">
                  {card.description}
                </p>
              </div>

              {/* Not Collected Overlay */}
              {!card.collected && (
                <div className="absolute inset-0 bg-black/50 flex items-center justify-center">
                  <div className="text-xs font-medium text-gray-400">미수집</div>
                </div>
              )}
            </div>
          ))}
        </div>
      </ScrollArea>

      {/* Bottom Navigation */}
      <div 
        className="absolute bottom-0 left-0 right-0 h-20 flex items-center justify-around"
        style={{ 
          backgroundColor: 'var(--color-bg-panel)',
          backdropFilter: 'blur(20px)',
          borderTop: '1px solid rgba(255,255,255,0.1)'
        }}
      >
        {['🏠', '🃏', '⚔️', '🏪', '⚙️'].map((icon, index) => (
          <button
            key={index}
            className={`w-12 h-12 rounded-xl flex items-center justify-center text-xl transition-all ${
              index === 1 ? 'scale-110' : 'opacity-60'
            }`}
            style={{
              backgroundColor: index === 1 ? 'var(--color-primary)' : 'transparent'
            }}
          >
            {icon}
          </button>
        ))}
      </div>
    </div>
  )
}