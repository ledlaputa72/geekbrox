'use client'

import { useState } from 'react'
import { ChevronLeft, Zap, Users, Star, Sparkles, Lock } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { ScrollArea } from '@/components/ui/scroll-area'

interface UpgradeNode {
  id: string
  name: string
  description: string
  icon: React.ReactNode
  level: number
  maxLevel: number
  cost: number
  status: 'available' | 'insufficient' | 'max' | 'locked'
  position: { row: number; col: number }
  connections?: string[]
}

const categories = [
  { id: 'idle', name: '방치속도', icon: <Zap className="w-4 h-4" /> },
  { id: 'deck', name: '덱확장', icon: <Users className="w-4 h-4" /> },
  { id: 'prestige', name: '프레스티지', icon: <Star className="w-4 h-4" /> },
  { id: 'special', name: '특수능력', icon: <Sparkles className="w-4 h-4" /> },
]

const upgradeNodes: Record<string, UpgradeNode[]> = {
  idle: [
    {
      id: 'speed1',
      name: '기본 속도',
      description: '방치 수익 +20%',
      icon: <Zap className="w-10 h-10" />,
      level: 3,
      maxLevel: 10,
      cost: 150,
      status: 'available',
      position: { row: 0, col: 1 },
    },
    {
      id: 'speed2',
      name: '가속화',
      description: '방치 속도 +50%',
      icon: <Zap className="w-10 h-10" />,
      level: 0,
      maxLevel: 5,
      cost: 500,
      status: 'insufficient',
      position: { row: 1, col: 0 },
      connections: ['speed1'],
    },
    {
      id: 'speed3',
      name: '초고속',
      description: '방치 효율 2배',
      icon: <Zap className="w-10 h-10" />,
      level: 10,
      maxLevel: 10,
      cost: 0,
      status: 'max',
      position: { row: 1, col: 2 },
      connections: ['speed1'],
    },
    {
      id: 'speed4',
      name: '궁극 속도',
      description: '모든 수익 3배',
      icon: <Zap className="w-10 h-10" />,
      level: 0,
      maxLevel: 1,
      cost: 10000,
      status: 'locked',
      position: { row: 2, col: 1 },
      connections: ['speed2', 'speed3'],
    },
  ],
  deck: [
    {
      id: 'deck1',
      name: '덱 슬롯',
      description: '덱 크기 +2',
      icon: <Users className="w-10 h-10" />,
      level: 5,
      maxLevel: 20,
      cost: 200,
      status: 'available',
      position: { row: 0, col: 1 },
    },
    {
      id: 'deck2',
      name: '카드 품질',
      description: '희귀 카드 확률 +10%',
      icon: <Users className="w-10 h-10" />,
      level: 2,
      maxLevel: 10,
      cost: 800,
      status: 'insufficient',
      position: { row: 1, col: 0 },
      connections: ['deck1'],
    },
    {
      id: 'deck3',
      name: '덱 마스터',
      description: '모든 카드 효과 +25%',
      icon: <Users className="w-10 h-10" />,
      level: 0,
      maxLevel: 5,
      cost: 5000,
      status: 'locked',
      position: { row: 1, col: 2 },
      connections: ['deck1'],
    },
  ],
  prestige: [
    {
      id: 'prestige1',
      name: '환생 보너스',
      description: '환생 시 보너스 +50%',
      icon: <Star className="w-10 h-10" />,
      level: 1,
      maxLevel: 10,
      cost: 1000,
      status: 'available',
      position: { row: 0, col: 1 },
    },
  ],
  special: [
    {
      id: 'special1',
      name: '행운의 손',
      description: '크리티컬 확률 +15%',
      icon: <Sparkles className="w-10 h-10" />,
      level: 0,
      maxLevel: 5,
      cost: 2000,
      status: 'insufficient',
      position: { row: 0, col: 1 },
    },
  ],
}

function UpgradeNodeComponent({ node, onUpgrade }: { node: UpgradeNode; onUpgrade: (id: string) => void }) {
  const getStatusStyles = () => {
    switch (node.status) {
      case 'available':
        return 'bg-[var(--color-primary)] border-[var(--color-primary)] text-white'
      case 'insufficient':
        return 'bg-gray-600 border-gray-500 text-gray-300'
      case 'max':
        return 'bg-gradient-to-br from-yellow-400 to-yellow-600 border-yellow-400 text-black'
      case 'locked':
        return 'bg-gray-800 border-gray-700 text-gray-500'
      default:
        return 'bg-gray-600 border-gray-500 text-gray-300'
    }
  }

  const getButtonStyles = () => {
    switch (node.status) {
      case 'available':
        return 'bg-[var(--color-primary)] hover:bg-[var(--color-primary)]/80 text-white'
      case 'max':
        return 'bg-yellow-500 text-black cursor-default'
      default:
        return 'bg-gray-600 text-gray-400 cursor-not-allowed'
    }
  }

  return (
    <div className={`relative w-[120px] h-[120px] rounded-[var(--radius-card)] border-2 backdrop-blur-sm ${getStatusStyles()}`}>
      {node.status === 'locked' && (
        <div className="absolute top-2 right-2">
          <Lock className="w-4 h-4" />
        </div>
      )}
      
      <div className="p-3 h-full flex flex-col">
        <div className="flex items-center justify-center mb-1">
          {node.icon}
        </div>
        
        <div className="text-xs font-medium text-center mb-1 leading-tight">
          {node.name}
        </div>
        
        <div className="text-[10px] text-center opacity-80 mb-2 leading-tight">
          {node.description}
        </div>
        
        <div className="mt-auto">
          <div className="text-[10px] text-center mb-1">
            {node.status === 'max' ? 'MAX' : `${node.level}/${node.maxLevel}`}
          </div>
          
          <Button
            size="sm"
            className={`w-full h-6 text-[10px] rounded-[var(--radius-button)] ${getButtonStyles()}`}
            onClick={() => onUpgrade(node.id)}
            disabled={node.status !== 'available'}
          >
            {node.status === 'max' ? 'MAX' : node.status === 'locked' ? '잠김' : `💎${node.cost}`}
          </Button>
        </div>
      </div>
    </div>
  )
}

function ConnectionLines({ nodes }: { nodes: UpgradeNode[] }) {
  return (
    <svg className="absolute inset-0 w-full h-full pointer-events-none" style={{ zIndex: 0 }}>
      {nodes.map((node) =>
        node.connections?.map((connectionId) => {
          const connectedNode = nodes.find((n) => n.id === connectionId)
          if (!connectedNode) return null

          const startX = connectedNode.position.col * 130 + 60
          const startY = connectedNode.position.row * 140 + 60
          const endX = node.position.col * 130 + 60
          const endY = node.position.row * 140 + 60

          return (
            <line
              key={`${connectionId}-${node.id}`}
              x1={startX}
              y1={startY}
              x2={endX}
              y2={endY}
              stroke="rgba(255,255,255,0.3)"
              strokeWidth="2"
              strokeDasharray="4,4"
            />
          )
        })
      )}
    </svg>
  )
}

export default function UpgradeTree() {
  const [activeCategory, setActiveCategory] = useState('idle')
  const [currency, setCurrency] = useState(1234)

  const handleUpgrade = (nodeId: string) => {
    const node = upgradeNodes[activeCategory]?.find((n) => n.id === nodeId)
    if (node && node.status === 'available' && currency >= node.cost) {
      setCurrency(prev => prev - node.cost)
      // 업그레이드 로직 구현
      console.log(`Upgrading ${nodeId}`)
    }
  }

  const currentNodes = upgradeNodes[activeCategory] || []

  return (
    <div className="w-[390px] h-[844px] bg-[var(--color-bg-main)] text-white overflow-hidden relative">
      {/* Header */}
      <div className="h-[108px] bg-[var(--color-bg-panel)] backdrop-blur-md border-b border-white/10">
        <div className="pt-11 px-4 h-full flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Button size="sm" variant="ghost" className="w-8 h-8 p-0">
              <ChevronLeft className="w-5 h-5" />
            </Button>
            <h1 className="text-lg font-bold">⬆ 업그레이드</h1>
          </div>
          
          <div className="flex items-center gap-2 bg-[var(--color-bg-panel)] backdrop-blur-sm rounded-full px-3 py-1.5">
            <span className="text-[var(--color-currency-1)]">💎</span>
            <span className="font-bold">{currency.toLocaleString()}</span>
          </div>
        </div>
      </div>

      {/* Category Tabs */}
      <div className="px-4 py-3">
        <ScrollArea className="w-full">
          <div className="flex gap-2">
            {categories.map((category) => (
              <Button
                key={category.id}
                variant={activeCategory === category.id ? 'default' : 'ghost'}
                size="sm"
                className={`flex items-center gap-2 whitespace-nowrap rounded-[var(--radius-button)] ${
                  activeCategory === category.id
                    ? 'bg-[var(--color-primary)] text-white'
                    : 'bg-[var(--color-bg-panel)] text-white/70 hover:text-white'
                }`}
                onClick={() => setActiveCategory(category.id)}
              >
                {category.icon}
                {category.name}
              </Button>
            ))}
          </div>
        </ScrollArea>
      </div>

      {/* Tree Area */}
      <div className="flex-1 px-4 pb-[152px]">
        <ScrollArea className="h-full">
          <div className="relative min-h-[400px]">
            <ConnectionLines nodes={currentNodes} />
            
            <div className="relative" style={{ zIndex: 1 }}>
              {currentNodes.map((node) => (
                <div
                  key={node.id}
                  className="absolute"
                  style={{
                    left: node.position.col * 130,
                    top: node.position.row * 140,
                  }}
                >
                  <UpgradeNodeComponent node={node} on