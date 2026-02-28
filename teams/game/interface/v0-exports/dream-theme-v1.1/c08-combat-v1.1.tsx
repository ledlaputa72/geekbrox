'use client'

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Menu } from 'lucide-react'

interface Card {
  id: number
  name: string
  cost: number
  rarity: 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary'
  type: 'attack' | 'defense' | 'collection' | 'synergy'
  playable: boolean
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

export default function Combat() {
  const [turn, setTurn] = useState(3)
  const [playerHp, setPlayerHp] = useState(7)
  const [playerMaxHp] = useState(10)
  const [energy, setEnergy] = useState(2)
  const [maxEnergy] = useState(3)
  const [enemyHp, setEnemyHp] = useState(15)
  const [enemyMaxHp] = useState(18)
  
  const [deckCount] = useState(8)
  const [discardCount] = useState(3)
  const [banishCount] = useState(1)

  const [combatLog, setCombatLog] = useState([
    'You dealt 10 damage',
    'Enemy attacks for 3 damage',
    'You blocked 8 damage',
  ])

  const [hand, setHand] = useState<Card[]>([
    { id: 1, name: 'Strike', cost: 1, rarity: 'common', type: 'attack', playable: true },
    { id: 2, name: 'Defend', cost: 1, rarity: 'common', type: 'defense', playable: true },
    { id: 3, name: 'Oblivion', cost: 5, rarity: 'rare', type: 'attack', playable: false },
    { id: 4, name: 'Memory', cost: 2, rarity: 'uncommon', type: 'collection', playable: true },
    { id: 5, name: 'Reverie', cost: 4, rarity: 'epic', type: 'synergy', playable: false },
  ])

  const handlePlayCard = (cardId: number) => {
    const card = hand.find(c => c.id === cardId)
    if (!card || !card.playable || energy < card.cost) return

    setHand(hand.filter(c => c.id !== cardId))
    setEnergy(prev => prev - card.cost)
    
    // Mock damage
    if (card.type === 'attack') {
      setEnemyHp(prev => Math.max(0, prev - 10))
      setCombatLog(prev => [...prev.slice(-2), `You dealt 10 damage`])
    }
  }

  const handleEndTurn = () => {
    setTurn(prev => prev + 1)
    // Mock enemy attack
    setPlayerHp(prev => Math.max(0, prev - 3))
    setCombatLog(prev => [...prev.slice(-2), 'Enemy attacks for 3 damage'])
    // Reset energy
    setEnergy(maxEnergy)
  }

  const getHpColor = (hp: number, maxHp: number) => {
    const percentage = (hp / maxHp) * 100
    if (percentage > 60) return '#4CAF50'
    if (percentage > 30) return '#FFC107'
    return '#F44336'
  }

  return (
    <div className="relative w-[390px] h-[844px] bg-[#1A1A2E] text-white font-['Nunito',sans-serif] overflow-hidden">
      {/* Top Bar */}
      <div className="h-[50px] flex items-center justify-between px-5 bg-[#2C2C3E]/90 border-b border-white/10">
        <motion.button
          className="w-10 h-10 flex items-center justify-center rounded-full hover:bg-white/10"
          whileTap={{ scale: 0.95 }}
        >
          <Menu className="w-5 h-5" />
        </motion.button>

        <div className="text-lg font-bold">Turn: {turn}</div>

        <motion.button
          className="px-4 h-[40px] bg-[#5A7FC0] rounded-lg font-bold text-sm"
          whileTap={{ scale: 0.95 }}
          onClick={handleEndTurn}
        >
          End Turn
        </motion.button>
      </div>

      {/* Enemy Area */}
      <div className="h-[180px] px-5 pt-4">
        <motion.div
          className="w-full h-[160px] bg-gradient-to-br from-[#434343] to-[#000000] rounded-2xl shadow-lg p-4 relative overflow-hidden"
          animate={enemyHp < enemyMaxHp ? {
            x: [-5, 5, -5, 5, 0],
          } : {}}
          transition={{ duration: 0.3 }}
        >
          {/* Enemy Name */}
          <h2 className="text-xl font-bold mb-2">Shadow Fiend</h2>

          {/* Enemy HP Bar */}
          <div className="mb-3">
            <div className="h-[12px] bg-[#333333] rounded-full overflow-hidden mb-1">
              <motion.div
                className="h-full rounded-full"
                style={{ 
                  backgroundColor: getHpColor(enemyHp, enemyMaxHp),
                  width: `${(enemyHp / enemyMaxHp) * 100}%`
                }}
                animate={{ width: `${(enemyHp / enemyMaxHp) * 100}%` }}
                transition={{ duration: 0.3 }}
              />
            </div>
            <div className="text-sm font-bold text-center">{enemyHp}/{enemyMaxHp}</div>
          </div>

          {/* Enemy Intent */}
          <div className="absolute top-4 right-4 w-[48px] h-[48px] bg-[#F44336] rounded-full flex items-center justify-center shadow-lg">
            <div className="text-center">
              <div className="text-lg">⚔️</div>
              <div className="text-xs font-bold">3</div>
            </div>
          </div>

          {/* Status Icons */}
          <div className="absolute bottom-4 left-4 flex gap-2">
            <div className="w-[24px] h-[24px] bg-[#F44336]/80 rounded-full flex items-center justify-center text-sm">
              🔥
            </div>
          </div>
        </motion.div>
      </div>

      {/* Combat Log */}
      <div className="h-[100px] px-5 pt-2">
        <div className="bg-[#1A1A2E]/80 rounded-lg p-3 h-full overflow-y-auto">
          <div className="space-y-1">
            {combatLog.slice(-3).map((log, i) => {
              const color = log.includes('You') 
                ? (log.includes('dealt') ? '#4CAF50' : '#2196F3')
                : '#F44336'
              
              return (
                <motion.div
                  key={i}
                  className="text-sm"
                  style={{ color }}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                >
                  • {log}
                </motion.div>
              )
            })}
          </div>
        </div>
      </div>

      {/* Player Area */}
      <div className="h-[60px] px-5 pt-2">
        <div className="flex items-center gap-3">
          {/* Player HP */}
          <div className="flex-1">
            <div className="flex items-center gap-2 mb-1">
              <span className="text-xs font-bold">HP:</span>
              <div className="flex-1 h-[16px] bg-[#333333] rounded-full overflow-hidden">
                <motion.div
                  className="h-full rounded-full"
                  style={{ 
                    backgroundColor: getHpColor(playerHp, playerMaxHp),
                    width: `${(playerHp / playerMaxHp) * 100}%`
                  }}
                  animate={{ width: `${(playerHp / playerMaxHp) * 100}%` }}
                  transition={{ duration: 0.3 }}
                />
              </div>
              <span className="text-xs font-bold">{playerHp}/{playerMaxHp}</span>
            </div>

            {/* Player Energy */}
            <div className="flex items-center gap-2">
              <span className="text-xs font-bold">EN:</span>
              <div className="flex-1 h-[16px] bg-[#333333] rounded-full overflow-hidden">
                <motion.div
                  className="h-full bg-[#2196F3] rounded-full"
                  style={{ width: `${(energy / maxEnergy) * 100}%` }}
                />
              </div>
              <span className="text-xs font-bold">{energy}/{maxEnergy}</span>
            </div>
          </div>

          {/* Status Icons */}
          <div className="flex gap-2">
            <div className="w-[24px] h-[24px] bg-[#7B9EF0]/80 rounded-full flex items-center justify-center text-sm">
              🛡
            </div>
          </div>
        </div>
      </div>

      {/* Hand */}
      <div className="h-[150px] px-3 pt-3">
        <div className="flex gap-2 justify-center">
          {hand.map((card, index) => {
            const canPlay = card.playable && energy >= card.cost

            return (
              <motion.button
                key={card.id}
                className={`relative w-[72px] h-[101px] rounded-lg bg-gradient-to-br ${rarityGradients[card.rarity]} shadow-lg overflow-hidden ${
                  !canPlay ? 'opacity-50 grayscale' : ''
                }`}
                whileHover={canPlay ? { scale: 1.1, y: -10 } : {}}
                whileTap={canPlay ? { scale: 0.95 } : {}}
                onClick={() => handlePlayCard(card.id)}
                animate={canPlay ? {
                  boxShadow: [
                    '0 4px 8px rgba(123, 158, 240, 0.3)',
                    '0 4px 16px rgba(123, 158, 240, 0.6)',
                    '0 4px 8px rgba(123, 158, 240, 0.3)',
                  ]
                } : {}}
                transition={{
                  duration: 2,
                  repeat: Infinity,
                }}
                style={{
                  transform: `rotate(${(index - 2) * 3}deg)`
                }}
              >
                {/* Cost Badge */}
                <div className="absolute top-1 right-1 w-[20px] h-[20px] bg-[#1A1A2E] rounded-full flex items-center justify-center text-xs font-bold">
                  {card.cost}
                </div>

                {/* Card Name */}
                <div className="absolute top-[30%] left-0 right-0 text-center text-[10px] font-bold px-1">
                  {card.name}
                </div>

                {/* Type Icon */}
                <div className="absolute bottom-2 left-2 text-base">
                  {typeIcons[card.type]}
                </div>

                {/* Unplayable Mark */}
                {!canPlay && (
                  <div className="absolute top-0 right-0 w-full h-full flex items-center justify-center bg-black/40">
                    <span className="text-2xl text-red-500">✕</span>
                  </div>
                )}
              </motion.button>
            )
          })}
        </div>
      </div>

      {/* Pile Counters */}
      <div className="h-[44px] flex items-center justify-center gap-8 px-5 bg-[#2C2C3E]/50">
        <motion.button
          className="text-sm font-bold"
          whileTap={{ scale: 0.95 }}
        >
          Deck: {deckCount}
        </motion.button>
        
        <motion.button
          className="text-sm font-bold"
          whileTap={{ scale: 0.95 }}
        >
          Discard: {discardCount}
        </motion.button>
        
        <motion.button
          className="text-sm font-bold text-[#F44336]"
          whileTap={{ scale: 0.95 }}
        >
          Banish: {banishCount}
        </motion.button>
      </div>

      {/* Floating Damage Numbers (example) */}
      <AnimatePresence>
        {enemyHp < enemyMaxHp && enemyHp > 0 && (
          <motion.div
            className="absolute top-[120px] left-1/2 text-4xl font-bold text-red-500"
            initial={{ opacity: 1, y: 0, x: -20 }}
            animate={{ opacity: 0, y: -50 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.8 }}
          >
            -10
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
