'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { Menu, FastForward, Bot } from 'lucide-react'

interface Node {
  id: number
  type: 'memory' | 'combat' | 'event' | 'upgrade' | 'shop' | 'boss'
  status: 'completed' | 'current' | 'uncompleted'
  icon: string
}

const nodeIcons = {
  memory: '💎',
  combat: '⚔️',
  event: '❓',
  upgrade: '⬆️',
  shop: '🛒',
  boss: '👹'
}

export default function InRunProgress() {
  const [hp, setHp] = useState(6)
  const [maxHp] = useState(10)
  const [energy] = useState(2)
  const [maxEnergy] = useState(3)
  const [reveries] = useState(125)
  const [autoPlay, setAutoPlay] = useState(false)

  const nodes: Node[] = [
    { id: 1, type: 'combat', status: 'completed', icon: nodeIcons.combat },
    { id: 2, type: 'memory', status: 'completed', icon: nodeIcons.memory },
    { id: 3, type: 'event', status: 'completed', icon: nodeIcons.event },
    { id: 4, type: 'combat', status: 'current', icon: nodeIcons.combat },
    { id: 5, type: 'shop', status: 'uncompleted', icon: nodeIcons.shop },
    { id: 6, type: 'upgrade', status: 'uncompleted', icon: nodeIcons.upgrade },
    { id: 7, type: 'combat', status: 'uncompleted', icon: nodeIcons.combat },
    { id: 8, type: 'memory', status: 'uncompleted', icon: nodeIcons.memory },
    { id: 9, type: 'event', status: 'uncompleted', icon: nodeIcons.event },
    { id: 10, type: 'boss', status: 'uncompleted', icon: nodeIcons.boss },
  ]

  const currentNode = nodes.find(n => n.status === 'current')

  const getHpColor = () => {
    const percentage = (hp / maxHp) * 100
    if (percentage > 60) return '#4CAF50'
    if (percentage > 30) return '#FFC107'
    return '#F44336'
  }

  return (
    <div className="relative w-[390px] h-[844px] bg-[#1A1A2E] text-white font-['Nunito',sans-serif] overflow-hidden">
      {/* Status Bar */}
      <div className="h-[50px] flex items-center justify-between px-5 bg-[#2C2C3E]/90 border-b border-white/10">
        {/* HP Bar */}
        <div className="flex-1">
          <div className="flex items-center gap-2">
            <span className="text-xs font-bold">HP:</span>
            <div className="flex-1 h-[20px] bg-[#333333] rounded-full overflow-hidden">
              <motion.div
                className="h-full rounded-full"
                style={{ 
                  backgroundColor: getHpColor(),
                  width: `${(hp / maxHp) * 100}%`
                }}
                animate={{ width: `${(hp / maxHp) * 100}%` }}
                transition={{ duration: 0.3 }}
              />
            </div>
            <span className="text-xs font-bold">{hp}/{maxHp}</span>
          </div>
        </div>

        {/* Energy Display */}
        <div className="flex-1 mx-4">
          <div className="flex items-center gap-2">
            <span className="text-xs font-bold">EN:</span>
            <div className="flex-1 h-[20px] bg-[#333333] rounded-full overflow-hidden">
              <motion.div
                className="h-full bg-[#2196F3] rounded-full"
                style={{ width: `${(energy / maxEnergy) * 100}%` }}
              />
            </div>
            <span className="text-xs font-bold">{energy}/{maxEnergy}</span>
          </div>
        </div>

        {/* Reveries Counter */}
        <div className="text-sm font-bold text-[#FFD700]">
          R: {reveries}
        </div>
      </div>

      {/* Node Map */}
      <div className="h-[80px] flex items-center justify-center px-5 bg-[#1A1A2E]/90">
        <div className="flex items-center gap-1">
          {nodes.map((node, index) => (
            <div key={node.id} className="flex items-center">
              {/* Node Circle */}
              <motion.button
                className={`w-[20px] h-[20px] rounded-full flex items-center justify-center text-[10px] border-2 ${
                  node.status === 'completed'
                    ? 'bg-[#4CAF50] border-[#4CAF50]'
                    : node.status === 'current'
                    ? 'bg-[#7B9EF0] border-[#7B9EF0]'
                    : 'bg-[#666666] border-[#666666]'
                }`}
                animate={node.status === 'current' ? {
                  scale: [1, 1.2, 1],
                } : {}}
                transition={{
                  duration: 1.5,
                  repeat: Infinity,
                }}
                whileTap={{ scale: 0.9 }}
              >
                {node.icon}
              </motion.button>

              {/* Connection Line */}
              {index < nodes.length - 1 && (
                <div className={`w-[16px] h-[2px] ${
                  node.status === 'completed' ? 'bg-[#4CAF50]' : 'bg-[#666666]'
                }`} />
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Main View - Dreamscape Background */}
      <div className="h-[400px] relative overflow-hidden">
        {/* Parallax Layers */}
        <motion.div
          className="absolute inset-0 bg-gradient-to-b from-[#1A1A2E] via-[#2C3E50] to-[#34495E]"
          animate={{ y: [0, -20, 0] }}
          transition={{ duration: 20, repeat: Infinity, ease: 'linear' }}
        />

        {/* Particles */}
        <div className="absolute inset-0">
          {[...Array(15)].map((_, i) => (
            <motion.div
              key={i}
              className="absolute w-1 h-1 bg-white/40 rounded-full"
              initial={{
                x: Math.random() * 390,
                y: Math.random() * 400,
              }}
              animate={{
                x: Math.random() * 390,
                y: Math.random() * 400,
                opacity: [0.2, 0.6, 0.2],
              }}
              transition={{
                duration: Math.random() * 5 + 5,
                repeat: Infinity,
                ease: 'linear'
              }}
            />
          ))}
        </div>

        {/* Node Entrance Animation */}
        {currentNode && (
          <motion.div
            className="absolute inset-0 flex items-center justify-center"
            initial={{ scale: 0, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            transition={{ duration: 0.5 }}
          >
            <div className="text-8xl">{currentNode.icon}</div>
          </motion.div>
        )}
      </div>

      {/* Node Info Panel */}
      <div className="absolute bottom-[60px] left-0 right-0 h-[140px] bg-[#2C2C3E]/90 backdrop-blur-sm rounded-t-2xl border-t border-white/10 p-5 shadow-lg">
        {currentNode?.type === 'memory' && (
          <div className="space-y-3">
            <h3 className="text-lg font-bold">Current Node: Memory 💎</h3>
            <p className="text-sm text-[#AAAAAA]">10 Reveries collected</p>
            
            <div className="flex gap-3">
              <motion.button
                className="flex-1 h-[44px] bg-[#5A7FC0] rounded-lg font-bold text-sm"
                whileTap={{ scale: 0.95 }}
              >
                Collect
              </motion.button>
              <motion.button
                className="flex-1 h-[44px] bg-[#4CAF50] rounded-lg font-bold text-sm"
                whileTap={{ scale: 0.95 }}
              >
                Heal 5 HP (30 R)
              </motion.button>
            </div>
          </div>
        )}

        {currentNode?.type === 'combat' && (
          <div className="space-y-3">
            <h3 className="text-lg font-bold">Combat: Shadow Fiend</h3>
            <div className="flex items-center gap-2">
              <span className="text-sm text-[#AAAAAA]">HP:</span>
              <div className="flex-1 h-[12px] bg-[#333333] rounded-full overflow-hidden">
                <div className="h-full bg-[#F44336]" style={{ width: '83%' }} />
              </div>
              <span className="text-sm font-bold">15/18</span>
            </div>
            <p className="text-sm text-[#AAAAAA]">Attack: 3</p>
            
            <motion.button
              className="w-full h-[44px] bg-gradient-to-r from-[#F44336] to-[#E57373] rounded-lg font-bold text-base"
              whileTap={{ scale: 0.95 }}
            >
              Start Combat →
            </motion.button>
          </div>
        )}

        {currentNode?.type === 'event' && (
          <div className="space-y-3">
            <h3 className="text-lg font-bold">Event: Crossroads</h3>
            <p className="text-sm text-[#AAAAAA]">"Two paths diverge..."</p>
            
            <div className="flex gap-3">
              <motion.button
                className="flex-1 h-[44px] bg-[#5A7FC0] rounded-lg font-bold text-sm"
                whileTap={{ scale: 0.95 }}
              >
                [A] Safe (20 R)
              </motion.button>
              <motion.button
                className="flex-1 h-[44px] bg-[#9C27B0] rounded-lg font-bold text-sm"
                whileTap={{ scale: 0.95 }}
              >
                [B] Risky (50% 50R)
              </motion.button>
            </div>
          </div>
        )}
      </div>

      {/* Bottom Action Bar */}
      <div className="absolute bottom-0 left-0 right-0 h-[60px] bg-[#1A1A2E]/90 backdrop-blur-sm border-t border-white/10 flex items-center justify-around px-5">
        <motion.button
          className="flex flex-col items-center gap-1"
          whileTap={{ scale: 0.95 }}
        >
          <FastForward className="w-5 h-5" />
          <span className="text-[10px]">Skip</span>
        </motion.button>

        <motion.button
          className={`flex flex-col items-center gap-1 ${autoPlay ? 'text-[#7B9EF0]' : 'text-white'}`}
          whileTap={{ scale: 0.95 }}
          onClick={() => setAutoPlay(!autoPlay)}
        >
          <Bot className="w-5 h-5" />
          <span className="text-[10px]">Auto</span>
        </motion.button>

        <motion.button
          className="flex flex-col items-center gap-1"
          whileTap={{ scale: 0.95 }}
        >
          <Menu className="w-5 h-5" />
          <span className="text-[10px]">Menu</span>
        </motion.button>
      </div>
    </div>
  )
}
