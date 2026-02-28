'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Card } from '@/components/ui/card'
import { 
  ShoppingBag, 
  Package, 
  Sparkles, 
  Calendar,
  Gem,
  Coins,
  Star,
  Gift,
  NoSymbol
} from 'lucide-react'

type CategoryTab = 'packages' | 'cardpacks' | 'cosmetics' | 'events'

interface Product {
  id: string
  name: string
  description: string
  price: string
  originalPrice?: string
  image: string
  badge?: string
}

interface CardPack {
  id: string
  name: string
  image: string
  cardCount: number
  price: string
}

export default function ShopPage() {
  const [activeTab, setActiveTab] = useState<CategoryTab>('packages')

  const products: Product[] = [
    {
      id: '1',
      name: '드림샤드 팩',
      description: '프리미엄 재화 100개',
      price: '$2.99',
      image: '💎'
    },
    {
      id: '2',
      name: '골드 팩',
      description: '게임 내 골드 10,000개',
      price: '$1.99',
      image: '🪙'
    },
    {
      id: '3',
      name: '경험치 부스터',
      description: '24시간 경험치 2배',
      price: '$0.99',
      image: '⚡'
    }
  ]

  const cardPacks: CardPack[] = [
    {
      id: '1',
      name: '기본 팩',
      image: '🎴',
      cardCount: 5,
      price: '$1.99'
    },
    {
      id: '2',
      name: '레어 팩',
      image: '✨',
      cardCount: 5,
      price: '$4.99'
    },
    {
      id: '3',
      name: '전설 팩',
      image: '🌟',
      cardCount: 3,
      price: '$9.99'
    },
    {
      id: '4',
      name: '이벤트 팩',
      image: '🎁',
      cardCount: 7,
      price: '$7.99'
    }
  ]

  const tabs = [
    { id: 'packages' as CategoryTab, label: '패키지', icon: Package },
    { id: 'cardpacks' as CategoryTab, label: '카드팩', icon: Sparkles },
    { id: 'cosmetics' as CategoryTab, label: '꾸미기', icon: Star },
    { id: 'events' as CategoryTab, label: '이벤트', icon: Calendar }
  ]

  return (
    <div className="w-[390px] h-[844px] mx-auto relative overflow-hidden" 
         style={{ backgroundColor: 'var(--color-bg-main)' }}>
      
      {/* Header with Currency */}
      <div className="absolute top-0 left-0 right-0 z-20 pt-11 pb-4 px-4"
           style={{ 
             background: 'linear-gradient(180deg, var(--color-bg-main) 0%, transparent 100%)',
             height: '108px'
           }}>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <ShoppingBag className="w-6 h-6" style={{ color: 'var(--color-primary)' }} />
            <h1 className="text-xl font-bold text-white">상점</h1>
          </div>
          
          <div className="flex items-center gap-3">
            <div className="flex items-center gap-1 px-3 py-1.5 rounded-full"
                 style={{ backgroundColor: 'var(--color-bg-panel)' }}>
              <Gem className="w-4 h-4" style={{ color: 'var(--color-currency-2)' }} />
              <span className="text-sm font-medium text-white">1,250</span>
            </div>
            <div className="flex items-center gap-1 px-3 py-1.5 rounded-full"
                 style={{ backgroundColor: 'var(--color-bg-panel)' }}>
              <Coins className="w-4 h-4" style={{ color: 'var(--color-currency-1)' }} />
              <span className="text-sm font-medium text-white">45,680</span>
            </div>
          </div>
        </div>
      </div>

      {/* Category Tabs */}
      <div className="absolute top-[108px] left-0 right-0 z-10 px-4 pb-4">
        <div className="flex gap-2">
          {tabs.map((tab) => {
            const Icon = tab.icon
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex-1 flex items-center justify-center gap-1.5 py-3 px-2 rounded-xl transition-all ${
                  activeTab === tab.id 
                    ? 'text-white shadow-lg' 
                    : 'text-gray-400'
                }`}
                style={{
                  backgroundColor: activeTab === tab.id 
                    ? 'var(--color-primary)' 
                    : 'var(--color-bg-panel)',
                  backdropFilter: 'blur(10px)'
                }}
              >
                <Icon className="w-4 h-4" />
                <span className="text-xs font-medium">{tab.label}</span>
              </button>
            )
          })}
        </div>
      </div>

      {/* Content Area */}
      <div className="absolute top-[172px] left-0 right-0 bottom-[152px] overflow-y-auto">
        <div className="px-4 pb-4">
          
          {/* Starter Package Banner */}
          {activeTab === 'packages' && (
            <Card className="mb-6 p-4 border-0 relative overflow-hidden"
                  style={{ 
                    backgroundColor: 'var(--color-bg-panel)',
                    backdropFilter: 'blur(10px)',
                    borderRadius: 'var(--radius-card)'
                  }}>
              <div className="absolute top-2 right-2">
                <Badge className="text-xs font-bold px-2 py-1"
                       style={{ 
                         backgroundColor: '#FF4444',
                         color: 'white'
                       }}>
                  -50%
                </Badge>
              </div>
              
              <div className="flex items-center gap-3">
                <div className="w-16 h-16 rounded-xl flex items-center justify-center text-2xl"
                     style={{ backgroundColor: 'var(--color-accent)' }}>
                  🎁
                </div>
                
                <div className="flex-1">
                  <h3 className="text-lg font-bold text-white mb-1">스타터 패키지</h3>
                  <p className="text-sm text-gray-300 mb-2">드림샤드×100 + 카드팩×3</p>
                  
                  <div className="flex items-center gap-2">
                    <span className="text-lg font-bold" style={{ color: 'var(--color-primary)' }}>
                      $2.49
                    </span>
                    <span className="text-sm text-gray-400 line-through">$4.99</span>
                  </div>
                </div>
                
                <Button className="px-6 py-2 font-medium"
                        style={{ 
                          backgroundColor: 'var(--color-primary)',
                          borderRadius: 'var(--radius-button)'
                        }}>
                  구매
                </Button>
              </div>
            </Card>
          )}

          {/* Products List */}
          {activeTab === 'packages' && (
            <div className="space-y-3">
              {products.map((product) => (
                <Card key={product.id} 
                      className="p-4 border-0"
                      style={{ 
                        backgroundColor: 'var(--color-bg-panel)',
                        backdropFilter: 'blur(10px)',
                        borderRadius: 'var(--radius-card)'
                      }}>
                  <div className="flex items-center gap-3">
                    <div className="w-20 h-20 rounded-xl flex items-center justify-center text-3xl"
                         style={{ backgroundColor: 'var(--color-accent)' }}>
                      {product.image}
                    </div>
                    
                    <div className="flex-1">
                      <h3 className="font-semibold text-white mb-1">{product.name}</h3>
                      <p className="text-sm text-gray-300 mb-2">{product.description}</p>
                      <span className="text-lg font-bold" style={{ color: 'var(--color-primary)' }}>
                        {product.price}
                      </span>
                    </div>
                    
                    <Button size="sm" 
                            className="px-4 py-2 font-medium"
                            style={{ 
                              backgroundColor: 'var(--color-primary)',
                              borderRadius: 'var(--radius-button)'
                            }}>
                      구매
                    </Button>
                  </div>
                </Card>
              ))}
            </div>
          )}

          {/* Card Packs Grid */}
          {activeTab === 'cardpacks' && (
            <div className="grid grid-cols-2 gap-3">
              {cardPacks.map((pack) => (
                <Card key={pack.id} 
                      className="p-4 border-0"
                      style={{ 
                        backgroundColor: 'var(--color-bg-panel)',
                        backdropFilter: 'blur(10px)',
                        borderRadius: 'var(--radius-card)'
                      }}>
                  <div className="text-center">
                    <div className="w-full h-24 rounded-lg flex items-center justify-center text-4xl mb-3"
                         style={{ backgroundColor: 'var(--color-accent)' }}>
                      {pack.image}
                    </div>
                    
                    <h3 className="font-semibold text-white mb-1">{pack.name}</h3>
                    <p className="text-xs text-gray-300 mb-2">{pack.cardCount}장 포함</p>
                    <p className="text-sm font-bold mb-3" style={{ color: 'var(--color-primary)' }}>
                      {pack.price}
                    </p>
                    
                    <Button size="sm" 
                            className="w-full py-2 font-medium"
                            style={{ 
                              backgroundColor: 'var(--color-primary)',
                              borderRadius: 'var(--radius-button)'
                            }}>
                      구매
                    </Button>
                  </div>
                </Card>
              ))}
            </div>
          )}

          {/* Other tabs placeholder */}
          {(activeTab === 'cosmetics' || activeTab === 'events') && (
            <div className="text-center py-12">
              <div className="text-4xl mb-4">🚧</div>
              <p className="text-gray-400">준비 중입니다</p>
            </div>
          )}
        </div>
      </div>

      {/* Ad-Free Banner */}
      <div className="absolute bottom-[80px] left-4 right-4 z-10">
        <Card className="p-3 border-0"
              style={{ 
                backgroundColor: 'var(--color-secondary)',
                borderRadius: 'var(--radius-card)'
              }}>
          <div className="flex items-center gap-3">
            <NoSymbol className="w-6 h-6 text-white" />
            <div className="flex-1">
              <p className="text-sm font-medium text-white">광고 없는 게임 - 영구</p>
            </div>
            <Button size="sm" 
                    className="px-4 py-2 bg-white text-black font-medium hover:bg-gray-100"
                    style={{ borderRadius: 'var(--radius-button)' }}>
              $