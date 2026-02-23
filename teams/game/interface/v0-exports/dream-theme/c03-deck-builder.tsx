'use client'

import { useState } from 'react'
import { Star, StarIcon, Check, Filter, Save, Play } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'

interface Card {
  id: string
  name: string
  cost: number
  attack: number
  health: number
  rarity: 'common' | 'rare' | 'epic' | 'legendary'
  inDeck: boolean
}

const mockCards: Card[] = [
  { id: '1', name: 'Fire Bolt', cost: 1, attack: 2, health: 0, rarity: 'common', inDeck: true },
  { id: '2', name: 'Ice Shield', cost: 2, attack: 0, health: 3, rarity: 'common', inDeck: true },
  { id: '3', name: 'Lightning', cost: 3, attack: 4, health: 0, rarity: 'rare', inDeck: true },
  { id: '4', name: 'Heal', cost: 1, attack: 0, health: 2, rarity: 'common', inDeck: true },
  { id: '5', name: 'Dragon', cost: 5, attack: 6, health: 6, rarity: 'legendary', inDeck: true },
  { id: '6', name: 'Goblin', cost: 1, attack: 1, health: 1, rarity: 'common', inDeck: true },
  { id: '7', name: 'Wizard', cost: 3, attack: 2, health: 4, rarity: 'rare', inDeck: true },
  { id: '8', name: 'Sword', cost: 2, attack: 3, health: 0, rarity: 'common', inDeck: true },
  { id: '9', name: 'Potion', cost: 1, attack: 0, health: 3, rarity: 'common', inDeck: false },
  { id: '10', name: 'Fireball', cost: 4, attack: 5, health: 0, rarity: 'epic', inDeck: false },
  { id: '11', name: 'Knight', cost: 3, attack: 3, health: 5, rarity: 'rare', inDeck: false },
  { id: '12', name: 'Archer', cost: 2, attack: 2, health: 2, rarity: 'common', inDeck: false },
]

const getRarityColor = (rarity: string) => {
  switch (rarity) {
    case 'common': return 'bg-gray-500'
    case 'rare': return 'bg-blue-500'
    case 'epic': return 'bg-purple-500'
    case 'legendary': return 'bg-yellow-500'
    default: return 'bg-gray-500'
  }
}

const DeckCard = ({ card, isSlot = false }: { card?: Card; isSlot?: boolean }) => {
  if (!card) {
    return (
      <div className="w-16 h-[90px] border-2 border-dashed border-white/30 rounded-[var(--radius-card)] flex items-center justify-center">
        <div className="w-6 h-6 rounded-full border-2 border-dashed border-white/30" />
      </div>
    )
  }

  return (
    <div className="relative w-16 h-[90px] rounded-[var(--radius-card)] overflow-hidden bg-gradient-to-b from-white/20 to-white/10 backdrop-blur-sm border border-white/20">
      <div className={`absolute top-1 right-1 w-2 h-2 rounded-full ${getRarityColor(card.rarity)}`} />
      <div className="p-2 h-full flex flex-col justify-between">
        <div className="text-[10px] font-bold text-white leading-tight">{card.name}</div>
        <div className="flex justify-between items-end">
          <div className="text-[8px] text-white/80">
            {card.attack > 0 && <div>⚔{card.attack}</div>}
            {card.health > 0 && <div>❤{card.health}</div>}
          </div>
          <div className="text-[10px] font-bold text-[var(--color-currency-1)] bg-black/30 rounded px-1">
            {card.cost}
          </div>
        </div>
      </div>
    </div>
  )
}

const CardGrid = ({ card }: { card: Card }) => {
  return (
    <div className="relative">
      <div className="w-full aspect-[64/90] rounded-[var(--radius-card)] overflow-hidden bg-gradient-to-b from-white/20 to-white/10 backdrop-blur-sm border border-white/20">
        <div className={`absolute top-1 right-1 w-3 h-3 rounded-full ${getRarityColor(card.rarity)}`} />
        {card.inDeck && (
          <div className="absolute top-1 left-1 w-5 h-5 bg-green-500 rounded-full flex items-center justify-center">
            <Check className="w-3 h-3 text-white" />
          </div>
        )}
        <div className="p-3 h-full flex flex-col justify-between">
          <div className="text-xs font-bold text-white leading-tight">{card.name}</div>
          <div className="flex justify-between items-end">
            <div className="text-[10px] text-white/80">
              {card.attack > 0 && <div>⚔{card.attack}</div>}
              {card.health > 0 && <div>❤{card.health}</div>}
            </div>
            <div className="text-xs font-bold text-[var(--color-currency-1)] bg-black/30 rounded px-1">
              {card.cost}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default function DeckBuilderPage() {
  const [selectedFilter, setSelectedFilter] = useState<string>('all')
  const deckCards = mockCards.filter(card => card.inDeck)
  const deckPower = 3 // Mock deck power rating

  return (
    <div className="w-[390px] h-[844px] mx-auto bg-[var(--color-bg-main)] relative overflow-hidden">
      {/* Background gradient */}
      <div className="absolute inset-0 bg-gradient-to-b from-[var(--color-primary)]/20 via-transparent to-[var(--color-secondary)]/20" />
      
      {/* Currency Bar */}
      <div className="relative z-10 h-[108px] pt-11 px-4">
        <div className="h-16 bg-[var(--color-bg-panel)] backdrop-blur-md rounded-[var(--radius-button)] border border-white/10 flex items-center justify-between px-4">
          <div className="flex items-center gap-3">
            <div className="flex items-center gap-1">
              <div className="w-6 h-6 bg-[var(--color-currency-1)] rounded-full flex items-center justify-center text-xs font-bold text-black">G</div>
              <span className="text-white font-bold">1,234</span>
            </div>
            <div className="flex items-center gap-1">
              <div className="w-6 h-6 bg-[var(--color-currency-2)] rounded-full flex items-center justify-center text-xs font-bold text-black">D</div>
              <span className="text-white font-bold">567</span>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="relative z-10 flex-1 px-4 pb-[152px]">
        {/* Header */}
        <div className="mb-4">
          <div className="flex items-center justify-between mb-2">
            <h1 className="text-xl font-bold text-white">덱 빌더</h1>
            <div className="flex items-center gap-2">
              <span className="text-sm text-white/80">{deckCards.length}/12장</span>
              <div className="flex">
                {[1, 2, 3, 4, 5].map((star) => (
                  <Star
                    key={star}
                    className={`w-4 h-4 ${
                      star <= deckPower ? 'text-[var(--color-currency-1)] fill-current' : 'text-white/30'
                    }`}
                  />
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* Current Deck Slots */}
        <div className="mb-6">
          <div className="overflow-x-auto pb-2">
            <div className="flex gap-2 min-w-max px-1">
              {Array.from({ length: 12 }, (_, i) => (
                <DeckCard key={i} card={deckCards[i]} isSlot />
              ))}
            </div>
          </div>
        </div>

        {/* Divider */}
        <div className="h-px bg-white/20 mb-4" />

        {/* Card Selection Header */}
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-bold text-white">카드 선택</h2>
          <Button
            variant="ghost"
            size="sm"
            className="h-8 px-3 text-white/80 hover:text-white hover:bg-white/10"
          >
            <Filter className="w-4 h-4 mr-1" />
            필터
          </Button>
        </div>

        {/* Filter Bar */}
        <div className="flex gap-2 mb-4 overflow-x-auto pb-2">
          {['all', 'common', 'rare', 'epic', 'legendary'].map((filter) => (
            <Badge
              key={filter}
              variant={selectedFilter === filter ? 'default' : 'secondary'}
              className={`whitespace-nowrap cursor-pointer transition-colors ${
                selectedFilter === filter
                  ? 'bg-[var(--color-primary)] text-white'
                  : 'bg-white/10 text-white/80 hover:bg-white/20'
              }`}
              onClick={() => setSelectedFilter(filter)}
            >
              {filter === 'all' ? '전체' : filter}
            </Badge>
          ))}
        </div>

        {/* Card Grid */}
        <div className="grid grid-cols-3 gap-3 mb-6">
          {mockCards
            .filter(card => selectedFilter === 'all' || card.rarity === selectedFilter)
            .map((card) => (
              <CardGrid key={card.id} card={card} />
            ))}
        </div>
      </div>

      {/* Bottom Actions */}
      <div className="absolute bottom-20 left-0 right-0 px-4">
        <div className="flex gap-3">
          <Button
            className="flex-1 h-12 bg-white/10 hover:bg-white/20 text-white border border-white/20 rounded-[var(--radius-button)]"
            variant="ghost"
          >
            <Save className="w-5 h-5 mr-2" />
            덱 저장
          </Button>
          <Button
            className="flex-1 h-12 bg-[var(--color-primary)] hover:bg-[var(--color-primary)]/80 text-white rounded-[var(--radius-button)]"
          >
            <Play className="w-5 h-5 mr-2" />
            런 시작
          </Button>
        </div>
      </div>

      {/* Bottom Navigation */}
      <div className="absolute bottom-0 left-0 right-0 h-20 bg-[var(--color-bg-panel)] backdrop-blur-md border-t border-white/10">
        <div className="flex items-center justify-around h-full px-4">
          {['홈', '덱', '상점', '컬렉션', '설정'].map((tab, index) =>