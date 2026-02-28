'use client'

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { ChevronLeft, Filter, Search, X, Lock, Check } from 'lucide-react'

interface Card {
  id: number
  name: string
  cost: number
  rarity: 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary'
  type: 'attack' | 'defense' | 'collection' | 'synergy'
  owned: boolean
  description: string
  effect: string
  upgrade?: string
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

export default function CardLibrary() {
  const [selectedCard, setSelectedCard] = useState<Card | null>(null)
  const [filterType, setFilterType] = useState('all')
  const [filterRarity, setFilterRarity] = useState('all')
  const [searchTerm, setSearchTerm] = useState('')
  const [showSearch, setShowSearch] = useState(false)

  // Mock card data (85 cards total)
  const generateCards = (): Card[] => {
    const cards: Card[] = []
    const rarities: Array<'common' | 'uncommon' | 'rare' | 'epic' | 'legendary'> = 
      ['common', 'uncommon', 'rare', 'epic', 'legendary']
    const types: Array<'attack' | 'defense' | 'collection' | 'synergy'> = 
      ['attack', 'defense', 'collection', 'synergy']
    
    for (let i = 0; i < 85; i++) {
      cards.push({
        id: i + 1,
        name: i < 42 ? `Card ${i + 1}` : '???',
        cost: Math.floor(Math.random() * 5) + 1,
        rarity: rarities[Math.floor(i / 17) % 5],
        type: types[i % 4],
        owned: i < 42,
        description: `Card ${i + 1} description`,
        effect: `This card deals damage based on your current energy.`,
        upgrade: i < 42 ? '+2 damage when upgraded' : undefined
      })
    }
    return cards
  }

  const [cards] = useState(generateCards())

  const stats = {
    collected: 42,
    total: 85,
    common: 18,
    rare: 12,
    epic: 8,
    legendary: 4
  }

  const filteredCards = cards.filter(card => {
    if (filterType !== 'all' && card.type !== filterType) return false
    if (filterRarity !== 'all' && card.rarity !== filterRarity) return false
    if (searchTerm && !card.name.toLowerCase().includes(searchTerm.toLowerCase())) return false
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
        
        <h1 className="text-lg font-bold">Card Library</h1>
        
        <motion.button
          className="w-10 h-10 flex items-center justify-center rounded-full hover:bg-white/10"
          whileTap={{ scale: 0.95 }}
          onClick={() => setShowSearch(!showSearch)}
        >
          <Search className="w-6 h-6" />
        </motion.button>
      </div>

      {/* Stats Bar */}
      <div className="h-[40px] flex items-center justify-center px-5 bg-[#2C2C3E] text-xs">
        <span className="text-[#AAAAAA]">
          Collected: <span className="text-white font-bold">{stats.collected}/{stats.total}</span> | 
          Common: {stats.common} | Rare: {stats.rare} | Epic: {stats.epic} | Legendary: {stats.legendary}
        </span>
      </div>

      {/* Filter Bar */}
      <div className="h-[50px] flex items-center gap-2 px-5">
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
          <Filter className="w-4 h-4" />
        </motion.button>
      </div>

      {/* Card Grid */}
      <div className="h-[654px] overflow-y-auto px-5 pt-3">
        <div className="grid grid-cols-3 gap-3 pb-5">
          {filteredCards.map((card) => (
            <motion.button
              key={card.id}
              className={`relative w-[100px] h-[140px] rounded-xl shadow-lg overflow-hidden ${
                card.owned ? '' : 'grayscale opacity-60'
              }`}
              style={{
                background: `linear-gradient(135deg, var(--tw-gradient-stops))`,
              }}
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              onClick={() => card.owned && setSelectedCard(card)}
            >
              <div className={`absolute inset-0 bg-gradient-to-br ${rarityGradients[card.rarity]}`}>
                {/* Card Content */}
                <div className="h-full flex flex-col items-center justify-center p-2">
                  <div className="text-xs font-bold text-center mb-2">{card.name}</div>
                  
                  {/* Cost Badge */}
                  <div className="absolute top-2 right-2 w-[20px] h-[20px] bg-[#1A1A2E] rounded-full flex items-center justify-center text-xs font-bold">
                    {card.cost}
                  </div>
                  
                  {/* Type Icon */}
                  <div className="absolute bottom-2 left-2 text-base">
                    {typeIcons[card.type]}
                  </div>
                  
                  {/* Ownership Status */}
                  <div className="absolute bottom-2 right-2">
                    {card.owned ? (
                      <div className="w-[16px] h-[16px] bg-[#4CAF50] rounded-full flex items-center justify-center">
                        <Check className="w-3 h-3 text-white" />
                      </div>
                    ) : (
                      <div className="w-[16px] h-[16px] bg-[#666666] rounded-full flex items-center justify-center">
                        <Lock className="w-3 h-3 text-white" />
                      </div>
                    )}
                  </div>
                </div>
              </div>
            </motion.button>
          ))}
        </div>
      </div>

      {/* Card Detail Modal */}
      <AnimatePresence>
        {selectedCard && (
          <motion.div
            className="absolute inset-0 bg-black/80 flex items-center justify-center z-50"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setSelectedCard(null)}
          >
            <motion.div
              className="w-[350px] h-[600px] bg-[#2C2C3E] rounded-2xl shadow-2xl p-6 relative"
              initial={{ scale: 0.8, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.8, opacity: 0 }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Close Button */}
              <motion.button
                className="absolute top-4 right-4 w-8 h-8 flex items-center justify-center rounded-full bg-white/10 hover:bg-white/20"
                whileTap={{ scale: 0.95 }}
                onClick={() => setSelectedCard(null)}
              >
                <X className="w-5 h-5" />
              </motion.button>

              {/* Large Card Image */}
              <div className={`w-[200px] h-[280px] mx-auto mb-4 rounded-xl bg-gradient-to-br ${rarityGradients[selectedCard.rarity]} flex items-center justify-center`}>
                <div className="text-6xl">{typeIcons[selectedCard.type]}</div>
                
                {/* Cost Badge */}
                <div className="absolute top-2 right-2 w-[40px] h-[40px] bg-[#1A1A2E] rounded-full flex items-center justify-center text-xl font-bold">
                  {selectedCard.cost}
                </div>
              </div>

              {/* Card Details */}
              <div className="space-y-3">
                <h2 className="text-xl font-bold text-center">{selectedCard.name}</h2>
                
                <div className="text-center">
                  <span className="inline-block px-3 py-1 bg-[#7B9EF0] rounded-full text-sm font-bold">
                    {selectedCard.cost} Energy
                  </span>
                </div>

                <div className="flex items-center justify-center gap-2 text-sm">
                  <span>{typeIcons[selectedCard.type]}</span>
                  <span className="capitalize">{selectedCard.type}</span>
                </div>

                <div className="text-center">
                  <span className={`inline-block px-3 py-1 bg-gradient-to-r ${rarityGradients[selectedCard.rarity]} rounded-full text-xs font-bold uppercase`}>
                    {selectedCard.rarity}
                  </span>
                </div>

                <div className="bg-[#1A1A2E] rounded-lg p-3 text-sm">
                  <p className="text-[#AAAAAA]">{selectedCard.effect}</p>
                </div>

                {selectedCard.upgrade && (
                  <div className="bg-[#7B9EF0]/20 border border-[#7B9EF0] rounded-lg p-3 text-sm">
                    <p className="text-[#7B9EF0] font-bold">Upgrade:</p>
                    <p className="text-sm">{selectedCard.upgrade}</p>
                  </div>
                )}
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Search Modal */}
      <AnimatePresence>
        {showSearch && (
          <motion.div
            className="absolute top-0 left-0 right-0 h-[150px] bg-[#1A1A2E] border-b border-white/10 p-5 z-40"
            initial={{ y: -150 }}
            animate={{ y: 0 }}
            exit={{ y: -150 }}
          >
            <div className="flex items-center gap-3">
              <input
                type="text"
                placeholder="Search cards..."
                className="flex-1 h-[44px] px-4 bg-[#2C2C3E] rounded-lg text-sm border border-white/10 focus:outline-none focus:border-[#7B9EF0]"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                autoFocus
              />
              <motion.button
                className="w-[44px] h-[44px] flex items-center justify-center bg-[#2C2C3E] rounded-lg"
                whileTap={{ scale: 0.95 }}
                onClick={() => {
                  setShowSearch(false)
                  setSearchTerm('')
                }}
              >
                <X className="w-5 h-5" />
              </motion.button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
