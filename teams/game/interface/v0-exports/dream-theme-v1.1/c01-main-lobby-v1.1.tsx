'use client'

import { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import { Settings, Home, BookOpen, TrendingUp, BarChart3, ShoppingCart } from 'lucide-react'

export default function MainLobby() {
  const [reveries, setReveries] = useState(1234)
  const [offlineRewards, setOfflineRewards] = useState(2345)
  const [showOfflineBanner, setShowOfflineBanner] = useState(true)
  const [activeTab, setActiveTab] = useState('home')
  
  const newCardsCount = 3
  const upgradesAvailable = 5
  const newItems = 2

  const handleCollectRewards = () => {
    setReveries(prev => prev + offlineRewards)
    setShowOfflineBanner(false)
  }

  const actionButtons = [
    { id: 'run', label: 'Run Start', icon: '🚀', color: 'from-[#7B9EF0] to-[#5A7FC0]', badge: null, pulse: true },
    { id: 'cards', label: 'Cards', icon: '📚', color: 'from-[#5A7FC0] to-[#4A6FA0]', badge: newCardsCount },
    { id: 'upgrade', label: 'Upgrade', icon: '⬆️', color: 'from-[#9BA4C0] to-[#7B84A0]', badge: upgradesAvailable },
    { id: 'shop', label: 'Shop', icon: '🛒', color: 'from-[#8B5FBF] to-[#6B3F9F]', badge: newItems },
  ]

  const tabButtons = [
    { id: 'home', icon: Home, label: 'Home' },
    { id: 'cards', icon: BookOpen, label: 'Cards' },
    { id: 'upgrade', icon: TrendingUp, label: 'Upgrade' },
    { id: 'progress', icon: BarChart3, label: 'Progress' },
    { id: 'shop', icon: ShoppingCart, label: 'Shop' },
  ]

  return (
    <div className="relative w-[390px] h-[844px] bg-[#1A1A2E] text-white font-['Nunito',sans-serif] overflow-hidden">
      {/* Particles Background */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        {[...Array(20)].map((_, i) => (
          <motion.div
            key={i}
            className="absolute w-2 h-2 bg-white/30 rounded-full"
            initial={{
              x: Math.random() * 390,
              y: Math.random() * 844,
              scale: Math.random() * 0.5 + 0.5
            }}
            animate={{
              x: Math.random() * 390,
              y: Math.random() * 844,
              rotate: 360,
            }}
            transition={{
              duration: Math.random() * 10 + 20,
              repeat: Infinity,
              ease: 'linear'
            }}
          />
        ))}
      </div>

      {/* Top Bar */}
      <div className="relative h-[60px] flex items-center justify-between px-5 z-10">
        <motion.button
          className="text-[#FFD700] text-lg font-bold"
          whileTap={{ scale: 0.95 }}
          onClick={() => {}}
        >
          Reveries: {reveries.toLocaleString()}
        </motion.button>
        
        <motion.button
          className="w-10 h-10 flex items-center justify-center rounded-full hover:bg-white/10"
          whileTap={{ scale: 0.95 }}
        >
          <Settings className="w-6 h-6" />
        </motion.button>
      </div>

      {/* Character Area */}
      <div className="relative h-[300px] flex items-center justify-center">
        <motion.div
          className="w-[200px] h-[250px] bg-gradient-to-br from-[#7B9EF0]/20 to-[#5A7FC0]/20 rounded-3xl flex items-center justify-center text-6xl"
          animate={{
            y: [0, -10, 0],
          }}
          transition={{
            duration: 2,
            repeat: Infinity,
            ease: 'easeInOut'
          }}
        >
          <div className="relative">
            <span className="text-8xl">💭</span>
            <motion.div
              className="absolute -top-2 -right-2 w-4 h-4 bg-white rounded-full"
              animate={{
                scale: [1, 1.2, 1],
                opacity: [0.5, 1, 0.5]
              }}
              transition={{
                duration: 1.5,
                repeat: Infinity,
              }}
            />
          </div>
        </motion.div>
      </div>

      {/* Offline Rewards Banner */}
      {showOfflineBanner && (
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.9 }}
          className="relative mx-5 mb-5"
        >
          <motion.button
            className="w-full h-[80px] bg-gradient-to-r from-[#667eea] to-[#764ba2] rounded-2xl shadow-lg shadow-purple-500/30 flex flex-col items-center justify-center"
            whileTap={{ scale: 0.98 }}
            onClick={handleCollectRewards}
          >
            <div className="text-white font-bold text-base flex items-center gap-2">
              Offline rewards ready! ⭐
            </div>
            <div className="text-white/90 text-sm mt-1">
              Tap to collect: {offlineRewards.toLocaleString()} R
            </div>
          </motion.button>
        </motion.div>
      )}

      {/* Main Action Grid */}
      <div className="relative px-5 mb-5">
        <div className="grid grid-cols-2 gap-3">
          {actionButtons.map((button, index) => (
            <motion.button
              key={button.id}
              className={`relative h-[120px] bg-gradient-to-br ${button.color} rounded-2xl shadow-lg flex flex-col items-center justify-center overflow-hidden`}
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.95 }}
              animate={button.pulse ? {
                boxShadow: [
                  '0 4px 12px rgba(123, 158, 240, 0.3)',
                  '0 4px 20px rgba(123, 158, 240, 0.6)',
                  '0 4px 12px rgba(123, 158, 240, 0.3)',
                ]
              } : {}}
              transition={button.pulse ? {
                duration: 2,
                repeat: Infinity,
                ease: 'easeInOut'
              } : {}}
            >
              <span className="text-4xl mb-2">{button.icon}</span>
              <span className="text-white font-bold text-lg">{button.label}</span>
              
              {button.badge && (
                <motion.div
                  className="absolute top-2 right-2 w-7 h-7 bg-red-500 rounded-full flex items-center justify-center text-white text-xs font-bold"
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ type: 'spring', stiffness: 500, damping: 15 }}
                >
                  {button.badge}
                </motion.div>
              )}
            </motion.button>
          ))}
        </div>
      </div>

      {/* Tab Bar */}
      <div className="absolute bottom-0 left-0 right-0 h-[80px] bg-[#1A1A2E]/90 backdrop-blur-sm border-t border-white/10">
        <div className="h-full flex items-center justify-around px-2">
          {tabButtons.map((tab) => {
            const Icon = tab.icon
            const isActive = activeTab === tab.id
            
            return (
              <motion.button
                key={tab.id}
                className="flex flex-col items-center justify-center gap-1 px-3"
                whileTap={{ scale: 0.9 }}
                onClick={() => setActiveTab(tab.id)}
              >
                <motion.div
                  animate={isActive ? {
                    y: [0, -4, 0],
                  } : {}}
                  transition={{
                    duration: 0.3,
                    ease: 'easeOut'
                  }}
                >
                  <Icon 
                    className={`w-6 h-6 ${isActive ? 'text-[#7B9EF0]' : 'text-[#666666]'}`}
                  />
                </motion.div>
                <span className={`text-xs ${isActive ? 'text-[#7B9EF0]' : 'text-[#666666]'}`}>
                  {tab.label}
                </span>
              </motion.button>
            )
          })}
        </div>
      </div>
    </div>
  )
}
