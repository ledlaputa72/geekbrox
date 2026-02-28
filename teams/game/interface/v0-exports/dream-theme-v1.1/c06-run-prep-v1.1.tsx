'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { ChevronLeft } from 'lucide-react'

interface Dreamer {
  id: string
  name: string
  icon: string
  difficulty: 'easy' | 'normal' | 'hard'
  hp: number
  reward: string
  gradient: string
}

interface Card {
  id: number
  name: string
  cost: number
  rarity: 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary'
}

const rarityGradients = {
  common: 'from-[#AAAAAA] to-[#CCCCCC]',
  uncommon: 'from-[#4CAF50] to-[#81C784]',
  rare: 'from-[#2196F3] to-[#64B5F6]',
  epic: 'from-[#9C27B0] to-[#BA68C8]',
  legendary: 'from-[#FFC107] to-[#FFD54F]'
}

const dreamers: Dreamer[] = [
  {
    id: 'serenity',
    name: 'Serenity',
    icon: '😌',
    difficulty: 'easy',
    hp: 10,
    reward: '+20% Reveries',
    gradient: 'from-[#4CAF50] to-[#81C784]'
  },
  {
    id: 'anxiety',
    name: 'Anxiety',
    icon: '😰',
    difficulty: 'normal',
    hp: 8,
    reward: '+0% Reveries',
    gradient: 'from-[#FFC107] to-[#FFD54F]'
  },
  {
    id: 'fear',
    name: 'Fear',
    icon: '😱',
    difficulty: 'hard',
    hp: 6,
    reward: '-20% R, +50% Cards',
    gradient: 'from-[#F44336] to-[#E57373]'
  }
]

const difficultyIcons = {
  easy: '🟢',
  normal: '🟡',
  hard: '🔴'
}

export default function RunPreparation() {
  const [selectedDreamer, setSelectedDreamer] = useState<string>('serenity')
  const [energy] = useState(100)

  // Mock deck data
  const deck: Card[] = [
    { id: 1, name: 'Strike', cost: 1, rarity: 'common' },
    { id: 2, name: 'Defend', cost: 1, rarity: 'common' },
    { id: 3, name: 'Power Strike', cost: 2, rarity: 'uncommon' },
    { id: 4, name: 'Shield Wall', cost: 2, rarity: 'uncommon' },
    { id: 5, name: 'Oblivion', cost: 5, rarity: 'rare' },
    { id: 6, name: 'Memory Lock', cost: 3, rarity: 'rare' },
    { id: 7, name: 'Dream Burst', cost: 4, rarity: 'epic' },
    { id: 8, name: 'Reverie', cost: 1, rarity: 'common' },
    { id: 9, name: 'Focus', cost: 1, rarity: 'common' },
    { id: 10, name: 'Nightmare', cost: 6, rarity: 'legendary' },
    { id: 11, name: 'Guard', cost: 1, rarity: 'common' },
    { id: 12, name: 'Lucid Strike', cost: 3, rarity: 'rare' },
  ]

  const deckDPS = 45
  const avgCost = 2.8

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
        
        <h1 className="text-lg font-bold">Run Preparation</h1>
        
        <div className="w-10" /> {/* Spacer */}
      </div>

      {/* Section: Select Dreamer */}
      <div className="px-5 pt-5">
        <h2 className="text-base font-bold mb-3 text-[#AAAAAA]">
          Select Dreamer (Difficulty):
        </h2>
      </div>

      {/* Dreamer Selection */}
      <div className="h-[200px] px-5 mb-5">
        <div className="flex gap-3 overflow-x-auto pb-3">
          {dreamers.map((dreamer) => {
            const isSelected = selectedDreamer === dreamer.id

            return (
              <motion.button
                key={dreamer.id}
                className={`relative min-w-[140px] w-[140px] h-[180px] rounded-2xl bg-gradient-to-br ${dreamer.gradient} shadow-lg flex-shrink-0 overflow-hidden ${
                  !isSelected ? 'opacity-70' : ''
                }`}
                whileTap={{ scale: 0.95 }}
                onClick={() => setSelectedDreamer(dreamer.id)}
                animate={isSelected ? {
                  boxShadow: [
                    '0 0 0 rgba(123, 158, 240, 0.4)',
                    '0 0 20px rgba(123, 158, 240, 0.8)',
                    '0 0 0 rgba(123, 158, 240, 0.4)',
                  ]
                } : {}}
                transition={{
                  duration: 2,
                  repeat: Infinity,
                }}
              >
                {/* Border for selected */}
                {isSelected && (
                  <div className="absolute inset-0 border-4 border-[#7B9EF0] rounded-2xl pointer-events-none" />
                )}

                <div className="p-4 flex flex-col items-center h-full justify-between">
                  {/* Name */}
                  <div className="text-base font-bold">{dreamer.name}</div>

                  {/* Icon */}
                  <div className="text-5xl">{dreamer.icon}</div>

                  {/* Stats */}
                  <div className="w-full space-y-1 text-center">
                    <div className="flex items-center justify-center gap-1 text-sm">
                      <span>{difficultyIcons[dreamer.difficulty]}</span>
                      <span className="capitalize">{dreamer.difficulty}</span>
                    </div>
                    <div className="text-lg font-bold">{dreamer.hp} HP</div>
                    <div className="text-xs text-[#FFD700]">{dreamer.reward}</div>
                  </div>
                </div>

                {/* Selected Label */}
                {isSelected && (
                  <div className="absolute bottom-0 left-0 right-0 bg-[#7B9EF0] py-1 text-xs font-bold text-center">
                    SELECTED
                  </div>
                )}
              </motion.button>
            )
          })}
        </div>
      </div>

      {/* Section: Your Deck */}
      <div className="px-5">
        <h2 className="text-base font-bold mb-3 text-[#AAAAAA]">
          Your Deck ({deck.length} cards): DPS: {deckDPS} | Avg cost: {avgCost}
        </h2>
      </div>

      {/* Deck Preview */}
      <div className="h-[140px] px-5 mb-5">
        <div className="flex gap-2 overflow-x-auto pb-3">
          {deck.map((card) => (
            <motion.button
              key={card.id}
              className={`relative min-w-[64px] w-[64px] h-[90px] rounded-lg bg-gradient-to-br ${rarityGradients[card.rarity]} shadow-lg flex-shrink-0 overflow-hidden`}
              whileTap={{ scale: 0.95 }}
            >
              {/* Cost Badge */}
              <div className="absolute top-1 right-1 w-[16px] h-[16px] bg-[#1A1A2E] rounded-full flex items-center justify-center text-[10px] font-bold">
                {card.cost}
              </div>

              {/* Card Name */}
              <div className="absolute bottom-2 left-0 right-0 text-center text-[8px] font-bold px-1">
                {card.name}
              </div>
            </motion.button>
          ))}
        </div>
      </div>

      {/* Edit Deck Button */}
      <div className="px-5 mb-5">
        <motion.button
          className="w-full h-[44px] bg-[#5A7FC0] rounded-lg font-bold text-base"
          whileTap={{ scale: 0.95 }}
        >
          Edit Deck
        </motion.button>
      </div>

      {/* Run Start CTA */}
      <div className="px-5 mb-3">
        <motion.button
          className="w-full h-[60px] bg-gradient-to-r from-[#667eea] to-[#764ba2] rounded-2xl shadow-lg shadow-purple-500/50 flex flex-col items-center justify-center"
          whileTap={{ scale: 0.98 }}
          animate={{
            boxShadow: [
              '0 8px 16px rgba(102, 126, 234, 0.3)',
              '0 8px 24px rgba(102, 126, 234, 0.6)',
              '0 8px 16px rgba(102, 126, 234, 0.3)',
            ]
          }}
          transition={{
            duration: 2,
            repeat: Infinity,
          }}
        >
          <div className="text-xl font-bold">🚀 Start Run</div>
          <div className="text-sm opacity-90">(Energy: {energy}%)</div>
        </motion.button>
      </div>

      {/* Info Text */}
      <div className="text-center text-sm text-[#AAAAAA]">
        Estimated: 15-25 min
      </div>
    </div>
  )
}
