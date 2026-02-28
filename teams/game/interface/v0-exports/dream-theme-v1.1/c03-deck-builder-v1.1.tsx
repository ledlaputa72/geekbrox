'use client'

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { ChevronLeft, Save, Search, Filter, ChevronDown, Plus } from 'lucide-react'

interface Card {
  id: number
  name: string
  cost: number
  rarity: 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary'
  type: 'attack' | 'defense' | 'collection' | 'synergy'
  owned: boolean
  inDeck: boolean
  count: number
}

const rarityGradients = {
  common: 'from-[#AAAAAA] to-[#CCCCCC]',
  uncommon: 'from-[#4CAF50] to-[#81C784]',
  rare: 'from-[#2196F3] to-[#64B5F6]',
  epic: 'from-[#9C27B0] to-[#BA68C8]',
  legendary: 'from-[#FFC107] to-[#FFD54F]'
}

const typeIcons = {
  attack: '⚔️',
  defense: '🛡',
  collection: '💎',
  synergy: '✨'
}

export default function DeckBuilder() {
  const maxDeckSize = 12
  
  // Mock card data
  const generateCards = (): Card[] => {
    const cards: Card[] = []
    const rarities: Array<'common' | 'uncommon' | 'rare' | 'epic' | 'legendary'> = 
      ['common', 'uncommon', 'rare', 'epic', 'legendary']
    const types: Array<'attack' | 'defense' | 'collection' | 'synergy'> = 
      ['attack', 'defense', 'collection', 'synergy']
    
    for (let i = 0; i < 50; i++) {
      cards.push({
        id: i + 1,
        name: `Card ${i + 1}`,
        cost: Math.floor(Math.random() * 5) + 1,
        rarity: rarities[Math.floor(Math.random() * 5)],
        type: types[i % 4],
        owned: true,
        inDeck: i < 8,
        count: i < 8 ? 1 : 0
      })
    }
    return cards
  }

  const [cards, setCards] = useState(generateCards())
  const [filterType, setFilterType] = useState('all')
  const [filterRarity, setFilterRarity] = useState('all')
  const [hasChanges, setHasChanges] = useState(false)

  const deckCards = cards.filter(c => c.inDeck)
  const deckSize = deckCards.reduce((sum, c) => sum + c.count, 0)
  const avgCost = deckSize > 0 
    ? (deckCards.reduce((sum, c) => sum + (c.cost * c.count), 0) / deckSize).toFixed(1)
    : '0.0'
  const dps = deckSize * 5 // Mock DPS calculation

  const addToDeck = (cardId: number) => {
    if (deckSize >= maxDeckSize) return
    
    setCards(cards.map(c => 
      c.id === cardId 
        ? { ...c, inDeck: true, count: c.count + 1 }
        : c
    ))
    setHasChanges(true)
  }

  const removeFromDeck = (cardId: number) => {
    setCards(cards.map(c => 
      c.id === cardId 
        ? { ...c, inDeck: c.count > 1, count: Math.max(0, c.count - 1) }
        : c
    ))
    setHasChanges(true)
  }

  const filteredCards = cards.filter(card => {
    if (filterType !== 'all' && card.type !== filterType) return false
    if (filterRarity !== 'all' && card.rarity !== filterRarity) return false
    return true
  })

  return (
    <div className="relative w-[390px] h-[844px] bg-[#1A1A2E] text-white font-['Nunito',sans-serif] overflow-hidden">
      {/* Header */}
      <div className="h-[60px] flex items-center justify-between px-5 border-b border-white/10">
        <motion.button
          className="w-10 h-10 flex items-center justify-center rounded-full hover:bg-white/10"
          whileTap={{ scale: 0.95 }}
        >
          <ChevronLeft className="w-6 h-6" />
        </motion.button>
        
        <h1 className="text-lg font-bold">Deck Builder</h1>
        
        <motion.button
          className={`w-10 h-10 flex items-center justify-center rounded-full ${
            hasChanges ? 'bg-[#7B9EF0] text-white' : 'bg-white/10 text-[#666666]'
          }`}
          whileTap={{ scale: 0.95 }}
          disabled={!hasChanges}
        >
          <Save className="w-5 h-5" />
        </motion.button>
      </div>

      {/* Deck Summary Bar */}
      <div className="h-[40px] flex items-center justify-center px-5 bg-[#2C2C3E] text-xs">
        <span className="text-[#AAAAAA]">
          Current deck (<span className="text-white font-bold">{deckSize}/{maxDeckSize}</span>): 
          DPS: <span className="text-white font-bold">{dps}</span> | 
          Avg cost: <span className="text-white font-bold">{avgCost}</span>
        </span>
      </div>

      {/* Current Deck Area */}
      <div className="h-[120px] bg-[#1A1A2E] border-b border-white/10 px-5 py-3">
        <div className="flex gap-2 overflow-x-auto">
          {deckCards.map((card) => (
            <motion.button
              key={card.id}
              className={`relative min-w-[64px] w-[64px] h-[90px] rounded-lg bg-gradient-to-br ${rarityGradients[card.rarity]} flex-shrink-0 shadow-lg`}
              whileTap={{ scale: 0.95 }}
              onClick={() => removeFromDeck(card.id)}
            >
              {/* Cost Badge */}
              <div className="absolute top-1 right-1 w-[16px] h-[16px] bg-[#1A1A2E] rounded-full flex items-center justify-center text-[10px] font-bold">
                {card.cost}
              </div>

              {/* Count Badge */}
              {card.count > 1 && (
                <div className="absolute top-1 left-1 w-[16px] h-[16px] bg-[#7B9EF0] rounded-full flex items-center justify-center text-[10px] font-bold">
                  {card.count}
                </div>
              )}

              {/* Type Icon */}
              <div className="absolute bottom-1 left-1 text-xs">
                {typeIcons[card.type]}
              </div>
            </motion.button>
          ))}

          {/* Empty Slots */}
          {[...Array(maxDeckSize - deckSize)].map((_, i) => (
            <div
              key={`empty-${i}`}
              className="min-w-[64px] w-[64px] h-[90px] rounded-lg border-2 border-dashed border-white/20 flex items-center justify-center flex-shrink-0"
            >
              <Plus className="w-6 h-6 text-white/30" />
            </div>
          ))}
        </div>
      </div>

      {/* Filter Bar */}
      <div className="h-[50px] flex items-center gap-2 px-5 bg-[#1A1A2E]">
        <select
          className="flex-1 h-[36px] px-3 bg-[#2C2C3E] rounded-lg text-sm border border-white/10 focus:outline-none focus:border-[#7B9EF0]"
          value={filterType}
          onChange={(e) => setFilterType(e.target.value)}
        >
          <option value="all">All Types</option>
          <option value="attack">Attack</option>
          <option value="defense">Defense</option>
          <option value="collection">Collection</option>
          <option value="synergy">Synergy</option>
        </select>

        <select
          className="flex-1 h-[36px] px-3 bg-[#2C2C3E] rounded-lg text-sm border border-white/10 focus:outline-none focus:border-[#7B9EF0]"
          value={filterRarity}
          onChange={(e) => setFilterRarity(e.target.value)}
        >
          <option value="all">All Rarities</option>
          <option value="common">Common</option>
          <option value="uncommon">Uncommon</option>
          <option value="rare">Rare</option>
          <option value="epic">Epic</option>
          <option value="legendary">Legendary</option>
        </select>

        <motion.button
          className="w-[36px] h-[36px] flex items-center justify-center bg-[#2C2C3E] rounded-lg border border-white/10"
          whileTap={{ scale: 0.95 }}
        >
          <Search className="w-4 h-4" />
        </motion.button>
      </div>

      {/* Available Cards Grid */}
      <div className="h-[534px] overflow-y-auto px-5 pt-3">
        <div className="grid grid-cols-3 gap-3 pb-5">
          {filteredCards.map((card) => (
            <motion.button
              key={card.id}
              className={`relative w-[100px] h-[140px] rounded-xl shadow-lg overflow-hidden ${
                card.inDeck ? 'opacity-50' : ''
              }`}
              style={{
                background: `linear-gradient(135deg, var(--tw-gradient-stops))`,
              }}
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              onClick={() => addToDeck(card.id)}
              disabled={deckSize >= maxDeckSize}
            >
              <div className={`absolute inset-0 bg-gradient-to-br ${rarityGradients[card.rarity]}`}>
                {/* Card Content */}
                <div className="h-full flex flex-col items-center justify-center p-2">
                  <div className="text-[10px] font-bold text-center">{card.name}</div>
                  
                  {/* Cost Badge */}
                  <div className="absolute top-2 right-2 w-[20px] h-[20px] bg-[#1A1A2E] rounded-full flex items-center justify-center text-xs font-bold">
                    {card.cost}
                  </div>
                  
                  {/* Type Icon */}
                  <div className="absolute bottom-2 left-2 text-base">
                    {typeIcons[card.type]}
                  </div>

                  {/* In Deck Label */}
                  {card.inDeck && (
                    <div className="absolute bottom-0 left-0 right-0 bg-[#7B9EF0] py-1 text-[8px] font-bold text-center">
                      IN DECK
                    </div>
                  )}
                </div>
              </div>
            </motion.button>
          ))}
        </div>
      </div>
    </div>
  )
}
