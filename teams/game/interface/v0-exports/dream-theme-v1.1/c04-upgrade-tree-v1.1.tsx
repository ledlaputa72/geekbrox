'use client'

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { ChevronLeft, Check, Lock } from 'lucide-react'

interface UpgradeNode {
  id: number
  name: string
  cost: number
  effect: string
  icon: string
  status: 'locked' | 'unlockable' | 'unlocked'
  requires?: number[]
  position: { x: number; y: number }
}

export default function UpgradeTree() {
  const [dreamShards, setDreamShards] = useState(12)
  const [selectedNode, setSelectedNode] = useState<UpgradeNode | null>(null)

  const [nodes, setNodes] = useState<UpgradeNode[]>([
    // Row 1
    { id: 1, name: 'Enhanced Starting Deck', cost: 3, effect: 'Start with 1 Rare card', icon: '📚', status: 'unlocked', position: { x: 50, y: 50 } },
    { id: 2, name: 'Energy Boost', cost: 5, effect: '+1 max energy', icon: '⚡', status: 'unlockable', requires: [1], position: { x: 150, y: 50 } },
    { id: 3, name: 'HP Recovery', cost: 4, effect: '+2 starting HP', icon: '❤️', status: 'locked', requires: [2], position: { x: 250, y: 50 } },
    { id: 4, name: 'Reveries Boost', cost: 6, effect: '+20% Reveries earned', icon: '💰', status: 'locked', requires: [3], position: { x: 350, y: 50 } },
    { id: 5, name: 'Card Draw', cost: 7, effect: 'Draw 1 extra card at turn start', icon: '🎴', status: 'locked', requires: [4], position: { x: 450, y: 50 } },
    
    // Row 2
    { id: 6, name: 'Deck Size', cost: 5, effect: '+3 max deck size', icon: '📦', status: 'locked', requires: [1], position: { x: 100, y: 150 } },
    { id: 7, name: 'Rarity Up', cost: 8, effect: 'Upgrade 1 card rarity', icon: '✨', status: 'locked', requires: [2, 6], position: { x: 200, y: 150 } },
    { id: 8, name: 'Shield Boost', cost: 6, effect: '+50% block effectiveness', icon: '🛡', status: 'locked', requires: [3, 7], position: { x: 300, y: 150 } },
    { id: 9, name: 'Critical Strike', cost: 9, effect: '10% chance for 2x damage', icon: '⚔️', status: 'locked', requires: [4, 8], position: { x: 400, y: 150 } },
    
    // Row 3
    { id: 10, name: 'Memory Lock', cost: 4, effect: 'Keep 1 card in hand', icon: '🔒', status: 'locked', requires: [6], position: { x: 50, y: 250 } },
    { id: 11, name: 'Dream Weaver', cost: 10, effect: 'Duplicate random card', icon: '🌀', status: 'locked', requires: [7], position: { x: 150, y: 250 } },
    { id: 12, name: 'Nightmare Ward', cost: 7, effect: 'Reduce damage by 20%', icon: '🌙', status: 'locked', requires: [8], position: { x: 250, y: 250 } },
    { id: 13, name: 'Lucid Master', cost: 12, effect: 'All cards cost 1 less', icon: '💫', status: 'locked', requires: [9], position: { x: 350, y: 250 } },
  ])

  const handleUnlock = (nodeId: number) => {
    const node = nodes.find(n => n.id === nodeId)
    if (!node || node.status !== 'unlockable' || dreamShards < node.cost) return

    setDreamShards(prev => prev - node.cost)
    setNodes(prev => prev.map(n => {
      if (n.id === nodeId) {
        return { ...n, status: 'unlocked' as const }
      }
      // Check if this node can now be unlocked
      if (n.requires && n.requires.every(reqId => 
        prev.find(pn => pn.id === reqId)?.status === 'unlocked'
      )) {
        return { ...n, status: 'unlockable' as const }
      }
      return n
    }))
  }

  const getNodeColor = (status: string) => {
    switch (status) {
      case 'locked': return '#333333'
      case 'unlockable': return '#7B9EF0'
      case 'unlocked': return '#4CAF50'
      default: return '#333333'
    }
  }

  const getNodeBorderColor = (status: string) => {
    switch (status) {
      case 'locked': return '#555555'
      case 'unlockable': return '#7B9EF0'
      case 'unlocked': return '#4CAF50'
      default: return '#555555'
    }
  }

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
        
        <h1 className="text-lg font-bold">Upgrade Tree</h1>
        
        <div className="text-sm font-bold text-[#00CED1]">
          Dream Shards: {dreamShards}
        </div>
      </div>

      {/* Tree Visual */}
      <div className="h-[600px] overflow-scroll relative bg-[#1A1A2E]">
        <div className="relative w-[550px] h-[350px] p-5">
          {/* Connection Lines */}
          <svg className="absolute inset-0 w-full h-full pointer-events-none">
            {nodes.map(node => 
              node.requires?.map(reqId => {
                const fromNode = nodes.find(n => n.id === reqId)
                if (!fromNode) return null
                
                const isActive = fromNode.status === 'unlocked' || fromNode.status === 'unlockable'
                
                return (
                  <line
                    key={`${reqId}-${node.id}`}
                    x1={fromNode.position.x + 20}
                    y1={fromNode.position.y + 20}
                    x2={node.position.x + 20}
                    y2={node.position.y + 20}
                    stroke={isActive ? '#7B9EF0' : '#555555'}
                    strokeWidth="2"
                    strokeDasharray={isActive ? '0' : '5,5'}
                  />
                )
              })
            )}
          </svg>

          {/* Upgrade Nodes */}
          {nodes.map((node) => (
            <motion.button
              key={node.id}
              className="absolute w-[40px] h-[40px] rounded-full flex items-center justify-center text-2xl border-2"
              style={{
                left: node.position.x,
                top: node.position.y,
                backgroundColor: getNodeColor(node.status),
                borderColor: getNodeBorderColor(node.status),
              }}
              animate={node.status === 'unlockable' ? {
                boxShadow: [
                  '0 0 0 rgba(123, 158, 240, 0.4)',
                  '0 0 20px rgba(123, 158, 240, 0.8)',
                  '0 0 0 rgba(123, 158, 240, 0.4)',
                ]
              } : {}}
              transition={{
                duration: 2,
                repeat: Infinity,
                ease: 'easeInOut'
              }}
              whileTap={{ scale: 0.95 }}
              onClick={() => setSelectedNode(node)}
            >
              {node.status === 'unlocked' ? (
                <Check className="w-5 h-5 text-white absolute" />
              ) : node.status === 'locked' ? (
                <Lock className="w-4 h-4 text-[#666666] absolute" />
              ) : null}
              <span className={node.status === 'unlocked' ? 'opacity-30' : ''}>{node.icon}</span>
            </motion.button>
          ))}
        </div>
      </div>

      {/* Info Panel */}
      <div className="absolute bottom-0 left-0 right-0 h-[140px] bg-[#2C2C3E] rounded-t-2xl p-5 border-t border-white/10">
        {selectedNode ? (
          <div className="space-y-2">
            <h3 className="text-lg font-bold">{selectedNode.name}</h3>
            <p className="text-sm text-[#00CED1] font-bold">
              Cost: {selectedNode.cost} Dream Shards
            </p>
            <p className="text-sm text-[#AAAAAA]">{selectedNode.effect}</p>
            
            <motion.button
              className={`w-full h-[44px] rounded-lg font-bold text-base ${
                selectedNode.status === 'unlockable' && dreamShards >= selectedNode.cost
                  ? 'bg-[#7B9EF0] text-white'
                  : selectedNode.status === 'unlocked'
                  ? 'bg-[#4CAF50] text-white'
                  : 'bg-[#555555] text-[#AAAAAA]'
              }`}
              whileTap={{ scale: 0.95 }}
              onClick={() => handleUnlock(selectedNode.id)}
              disabled={selectedNode.status !== 'unlockable' || dreamShards < selectedNode.cost}
            >
              {selectedNode.status === 'unlocked' 
                ? 'Unlocked' 
                : selectedNode.status === 'unlockable' && dreamShards >= selectedNode.cost
                ? 'Unlock'
                : 'Shards Insufficient'}
            </motion.button>
          </div>
        ) : (
          <div className="flex items-center justify-center h-full text-[#AAAAAA]">
            Tap a node to view details
          </div>
        )}
      </div>
    </div>
  )
}
