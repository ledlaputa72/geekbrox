'use client'

import { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { ChevronLeft, X } from 'lucide-react'

interface Product {
  id: number
  name: string
  description: string
  price: number
  icon: string
  category: 'daily' | 'cards' | 'energy'
  available: boolean
  purchased?: boolean
}

export default function Shop() {
  const [reveries, setReveries] = useState(1234)
  const [activeTab, setActiveTab] = useState<'daily' | 'cards' | 'energy'>('daily')
  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null)
  const [timeLeft, setTimeLeft] = useState(6 * 3600) // 6 hours in seconds

  useEffect(() => {
    const timer = setInterval(() => {
      setTimeLeft(prev => Math.max(0, prev - 1))
    }, 1000)
    return () => clearInterval(timer)
  }, [])

  const formatTime = (seconds: number) => {
    const hours = Math.floor(seconds / 3600)
    const minutes = Math.floor((seconds % 3600) / 60)
    return `${hours}h ${minutes}m`
  }

  const products: Product[] = [
    // Daily Deal
    { id: 1, name: 'Legendary Pack', description: '1 guaranteed Legendary card', price: 250, icon: '💎', category: 'daily', available: true },
    
    // Cards
    { id: 2, name: 'Rare Card Pack', description: '5 random Rare cards', price: 100, icon: '🎴', category: 'cards', available: true },
    { id: 3, name: 'Epic Card Pack', description: '3 random Epic cards', price: 300, icon: '✨', category: 'cards', available: true },
    { id: 4, name: 'Legendary Card', description: '1 random Legendary card', price: 500, icon: '💎', category: 'cards', available: true },
    { id: 5, name: 'Starter Deck Upgrade', description: 'Replace 3 Common with Uncommon', price: 200, icon: '📚', category: 'cards', available: true },
    { id: 6, name: 'Mystery Pack', description: 'Random cards of any rarity', price: 150, icon: '❓', category: 'cards', available: true },
    { id: 7, name: 'Collection Booster', description: '10 random cards', price: 400, icon: '🎁', category: 'cards', available: true },
    
    // Energy
    { id: 8, name: 'Energy Refill', description: 'Restore 100% energy', price: 50, icon: '⚡', category: 'energy', available: true },
    { id: 9, name: 'Energy Pack', description: '5 energy refills', price: 150, icon: '🔋', category: 'energy', available: true },
    { id: 10, name: 'Max Energy +1', description: 'Permanent +1 max energy', price: 500, icon: '⚡⚡', category: 'energy', available: true, purchased: false },
    { id: 11, name: 'Auto-Refill', description: 'Auto-refill energy daily', price: 300, icon: '🔄', category: 'energy', available: true },
  ]

  const filteredProducts = products.filter(p => p.category === activeTab)

  const handlePurchase = (product: Product) => {
    if (reveries >= product.price && product.available) {
      setReveries(prev => prev - product.price)
      setSelectedProduct(null)
      // Show success toast (implementation would go here)
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
        
        <h1 className="text-lg font-bold">Shop</h1>
        
        <div className="text-sm font-bold text-[#FFD700]">
          R: {reveries.toLocaleString()}
        </div>
      </div>

      {/* Tab Bar */}
      <div className="h-[50px] flex items-center border-b border-white/10 px-5">
        {(['daily', 'cards', 'energy'] as const).map((tab) => (
          <motion.button
            key={tab}
            className={`flex-1 h-full flex items-center justify-center font-bold text-sm relative ${
              activeTab === tab ? 'text-[#7B9EF0]' : 'text-[#666666]'
            }`}
            whileTap={{ scale: 0.95 }}
            onClick={() => setActiveTab(tab)}
          >
            {tab === 'daily' ? 'Daily Deal' : tab === 'cards' ? 'Cards' : 'Energy'}
            {activeTab === tab && (
              <motion.div
                className="absolute bottom-0 left-0 right-0 h-1 bg-[#7B9EF0]"
                layoutId="activeTab"
                transition={{ type: 'spring', stiffness: 500, damping: 30 }}
              />
            )}
          </motion.button>
        ))}
      </div>

      {/* Daily Deal Banner */}
      {activeTab === 'daily' && (
        <motion.div
          className="mx-5 mt-3 h-[80px] bg-gradient-to-r from-[#F093FB] to-[#F5576C] rounded-2xl shadow-lg shadow-pink-500/30 p-4 flex items-center justify-between"
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
        >
          <div>
            <div className="text-lg font-bold">🎁 Daily Deal</div>
            <div className="text-2xl font-bold">50% OFF</div>
          </div>
          <div className="text-right">
            <div className="text-sm opacity-90">{formatTime(timeLeft)} left</div>
            <div className={`text-xs ${timeLeft < 3600 ? 'text-red-300 font-bold' : ''}`}>
              {timeLeft < 3600 ? '⚠️ Hurry!' : 'Limited time'}
            </div>
          </div>
        </motion.div>
      )}

      {/* Product Grid */}
      <div className="h-[644px] overflow-y-auto px-5 pt-3">
        <div className="grid grid-cols-2 gap-3 pb-5">
          {filteredProducts.map((product) => {
            const canAfford = reveries >= product.price
            const isPurchased = product.purchased

            return (
              <motion.button
                key={product.id}
                className={`relative w-[170px] h-[220px] bg-[#2C2C3E] rounded-2xl shadow-lg p-4 flex flex-col items-center ${
                  !canAfford ? 'opacity-50' : ''
                } ${isPurchased ? 'opacity-70' : ''}`}
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                onClick={() => !isPurchased && setSelectedProduct(product)}
                disabled={isPurchased}
              >
                {/* Limited Badge for Daily */}
                {product.category === 'daily' && (
                  <div className="absolute top-2 right-2 bg-red-500 text-white text-[10px] font-bold px-2 py-1 rounded-full">
                    LIMITED
                  </div>
                )}

                {/* Icon */}
                <div className="text-5xl mb-3">{product.icon}</div>

                {/* Name */}
                <h3 className="text-base font-bold text-center mb-2">{product.name}</h3>

                {/* Description */}
                <p className="text-xs text-[#AAAAAA] text-center mb-3 line-clamp-2 flex-1">
                  {product.description}
                </p>

                {/* Price */}
                <div className="text-lg font-bold text-[#FFD700] mb-3">
                  {product.price} R
                </div>

                {/* Buy Button */}
                <motion.div
                  className={`w-full h-[40px] rounded-lg flex items-center justify-center font-bold text-sm ${
                    isPurchased
                      ? 'bg-[#4CAF50] text-white'
                      : canAfford
                      ? 'bg-[#5A7FC0] text-white'
                      : 'bg-[#555555] text-[#AAAAAA]'
                  }`}
                  whileTap={!isPurchased ? { scale: 0.95 } : {}}
                >
                  {isPurchased ? 'Purchased' : canAfford ? 'Buy' : 'Insufficient R'}
                </motion.div>

                {/* Glow effect for affordable items */}
                {canAfford && !isPurchased && (
                  <motion.div
                    className="absolute inset-0 rounded-2xl border-2 border-[#7B9EF0] opacity-0"
                    animate={{ opacity: [0, 0.3, 0] }}
                    transition={{ duration: 2, repeat: Infinity }}
                  />
                )}
              </motion.button>
            )
          })}
        </div>
      </div>

      {/* Purchase Confirmation Modal */}
      <AnimatePresence>
        {selectedProduct && (
          <motion.div
            className="absolute inset-0 bg-black/80 flex items-center justify-center z-50"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setSelectedProduct(null)}
          >
            <motion.div
              className="w-[340px] bg-[#2C2C3E] rounded-2xl shadow-2xl p-6 relative"
              initial={{ scale: 0.8, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.8, opacity: 0 }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Close Button */}
              <motion.button
                className="absolute top-4 right-4 w-8 h-8 flex items-center justify-center rounded-full bg-white/10 hover:bg-white/20"
                whileTap={{ scale: 0.95 }}
                onClick={() => setSelectedProduct(null)}
              >
                <X className="w-5 h-5" />
              </motion.button>

              {/* Product Details */}
              <div className="text-center space-y-4">
                <div className="text-6xl">{selectedProduct.icon}</div>
                <h2 className="text-xl font-bold">{selectedProduct.name}</h2>
                <p className="text-sm text-[#AAAAAA]">{selectedProduct.description}</p>

                <div className="bg-[#1A1A2E] rounded-lg p-4 space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="text-[#AAAAAA]">Current Reveries:</span>
                    <span className="font-bold text-[#FFD700]">{reveries.toLocaleString()}</span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-[#AAAAAA]">Cost:</span>
                    <span className="font-bold text-[#FFD700]">{selectedProduct.price} R</span>
                  </div>
                  <div className="flex justify-between text-sm border-t border-white/10 pt-2">
                    <span className="text-[#AAAAAA]">After purchase:</span>
                    <span className="font-bold text-[#FFD700]">
                      {(reveries - selectedProduct.price).toLocaleString()} R
                    </span>
                  </div>
                </div>

                {/* Action Buttons */}
                <div className="flex gap-3">
                  <motion.button
                    className="flex-1 h-[44px] bg-[#555555] rounded-lg font-bold text-sm"
                    whileTap={{ scale: 0.95 }}
                    onClick={() => setSelectedProduct(null)}
                  >
                    Cancel
                  </motion.button>
                  <motion.button
                    className={`flex-1 h-[44px] rounded-lg font-bold text-sm ${
                      reveries >= selectedProduct.price
                        ? 'bg-[#7B9EF0] text-white'
                        : 'bg-[#555555] text-[#AAAAAA]'
                    }`}
                    whileTap={{ scale: 0.95 }}
                    onClick={() => handlePurchase(selectedProduct)}
                    disabled={reveries < selectedProduct.price}
                  >
                    Confirm Purchase
                  </motion.button>
                </div>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
