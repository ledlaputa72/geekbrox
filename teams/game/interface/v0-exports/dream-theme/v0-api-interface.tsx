'use client'

import { useState } from 'react'
import { Copy, CheckCircle2, Code, Book, Lightbulb, ArrowRight, Github } from 'lucide-react'
import { ScrollArea } from '@/components/ui/scroll-area'
import { Button } from '@/components/ui/button'

interface ApiExample {
  id: string
  title: string
  category: string
  description: string
  code: string
  result?: string
  icon: string
}

const apiExamples: ApiExample[] = [
  {
    id: 'state',
    title: 'State Management',
    category: 'core',
    description: 'useState hook으로 컴포넌트 상태 관리',
    icon: '⚡',
    code: `const [activeTab, setActiveTab] = useState('idle')
    
// 상태 업데이트
setActiveTab('deck')`,
    result: 'Component 상태 실시간 변경'
  },
  {
    id: 'styling',
    title: 'CSS Variables',
    category: 'styling',
    description: '동적 테마 색상 시스템',
    icon: '🎨',
    code: `style={{ 
  backgroundColor: 'var(--color-primary)',
  color: 'var(--color-accent)'
}}`,
    result: 'Theme-aware 컴포넌트'
  },
  {
    id: 'glassmorphism',
    title: 'Glassmorphism',
    category: 'styling',
    description: '현대적 UI 효과 구현',
    icon: '✨',
    code: `className="backdrop-blur-md bg-white/10 
  border border-white/20"`,
    result: '세련된 반투명 효과'
  },
  {
    id: 'grid',
    title: 'Grid Layout',
    category: 'layout',
    description: 'Tailwind CSS 그리드 시스템',
    icon: '📐',
    code: `className="grid grid-cols-3 gap-3"`,
    result: '반응형 3열 레이아웃'
  },
  {
    id: 'scrollarea',
    title: 'ScrollArea',
    category: 'components',
    description: '커스텀 스크롤 영역',
    icon: '📜',
    code: `<ScrollArea className="h-96">
  {/* Content */}
</ScrollArea>`,
    result: '부드러운 스크롤 경험'
  },
  {
    id: 'animations',
    title: 'Animations',
    category: 'effects',
    description: 'Tailwind 애니메이션',
    icon: '🎬',
    code: `className="animate-pulse 
  animate-bounce transition-all"`,
    result: '부드러운 애니메이션'
  },
  {
    id: 'conditional',
    title: 'Conditional Styling',
    category: 'logic',
    description: '상태에 따른 스타일 변경',
    icon: '🔀',
    code: `className={${activeTab === 'cards' 
  ? 'bg-primary' 
  : 'bg-gray-500'}}`,
    result: '동적 스타일 적용'
  },
  {
    id: 'icons',
    title: 'Lucide Icons',
    category: 'components',
    description: '고급 아이콘 라이브러리',
    icon: '🎯',
    code: `<ChevronDown className="w-4 h-4" />
<Star className="w-5 h-5" />`,
    result: '일관된 아이콘 스타일'
  }
]

const categories = [
  { id: 'all', label: '전체', icon: '📚' },
  { id: 'core', label: 'Core', icon: '⚙️' },
  { id: 'styling', label: 'Styling', icon: '🎨' },
  { id: 'layout', label: 'Layout', icon: '📐' },
  { id: 'components', label: 'Components', icon: '🧩' },
  { id: 'effects', label: 'Effects', icon: '✨' },
  { id: 'logic', label: 'Logic', icon: '🔀' }
]

function ExampleCard({ example, onCopy }: { example: ApiExample; onCopy: (code: string) => void }) {
  const [copied, setCopied] = useState(false)

  const handleCopy = () => {
    onCopy(example.code)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  return (
    <div 
      className="group rounded-2xl backdrop-blur-sm border border-white/20 overflow-hidden hover:border-white/40 transition-all"
      style={{ backgroundColor: 'var(--color-bg-panel)' }}
    >
      {/* Header */}
      <div className="px-4 py-3 border-b border-white/10 bg-gradient-to-r from-white/5 to-transparent">
        <div className="flex items-center justify-between mb-1">
          <div className="flex items-center gap-2">
            <span className="text-2xl">{example.icon}</span>
            <div>
              <h3 className="font-bold text-white text-sm">{example.title}</h3>
              <p className="text-xs text-white/60">{example.description}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Code Block */}
      <div className="relative">
        <pre className="px-4 py-3 text-[11px] text-white/80 font-mono bg-black/30 overflow-x-auto">
          <code>{example.code}</code>
        </pre>
        
        {/* Copy Button */}
        <button
          onClick={handleCopy}
          className="absolute top-2 right-2 w-8 h-8 rounded-lg flex items-center justify-center bg-white/10 hover:bg-white/20 transition-all opacity-0 group-hover:opacity-100"
        >
          {copied ? (
            <CheckCircle2 className="w-4 h-4 text-green-400" />
          ) : (
            <Copy className="w-4 h-4 text-white/60" />
          )}
        </button>
      </div>

      {/* Result */}
      {example.result && (
        <div className="px-4 py-2 bg-green-500/10 border-t border-white/10 text-xs text-green-400/80 flex items-center gap-2">
          <ArrowRight className="w-3 h-3" />
          {example.result}
        </div>
      )}
    </div>
  )
}

export default function V0ApiInterface() {
  const [selectedCategory, setSelectedCategory] = useState('all')
  const [copiedCode, setCopiedCode] = useState('')
  const [showNotification, setShowNotification] = useState(false)

  const filteredExamples = selectedCategory === 'all' 
    ? apiExamples 
    : apiExamples.filter(ex => ex.category === selectedCategory)

  const handleCopy = (code: string) => {
    setCopiedCode(code)
    setShowNotification(true)
    setTimeout(() => setShowNotification(false), 2000)
    navigator.clipboard.writeText(code)
  }

  return (
    <div className="w-[390px] h-[844px] mx-auto relative overflow-hidden" style={{ backgroundColor: 'var(--color-bg-main)' }}>
      {/* CSS Variables */}
      <style jsx>{`
        :root {
          --color-primary: #7B9EF0;
          --color-secondary: #C4A8E8;
          --color-accent: #F5F0FF;
          --color-bg-main: #0D1B3E;
          --color-bg-panel: rgba(255,255,255,0.10);
          --color-currency-1: #FFE066;
          --color-currency-2: #E8D5FF;
          --radius-card: 16px;
          --radius-button: 20px;
        }
      `}</style>

      {/* Background */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute w-1 h-1 bg-white rounded-full opacity-60 animate-pulse" style={{top: '15%', left: '10%'}}></div>
        <div className="absolute w-1 h-1 bg-white rounded-full opacity-40 animate-pulse" style={{top: '40%', right: '12%', animationDelay: '1s'}}></div>
        <div className="absolute w-0.5 h-0.5 bg-white rounded-full opacity-70 animate-pulse" style={{bottom: '30%', left: '20%', animationDelay: '1.5s'}}></div>
      </div>

      {/* Header - 100px */}
      <div className="relative z-20 px-4 py-3">
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-2">
            <span className="text-2xl">⚡</span>
            <div>
              <h1 className="text-base font-bold text-white leading-tight">v0 API</h1>
              <p className="text-xs text-white/60">Dream Theme Guide</p>
            </div>
          </div>
          <button className="w-10 h-10 rounded-full flex items-center justify-center" style={{ backgroundColor: 'var(--color-bg-panel)' }}>
            <Code className="w-5 h-5 text-white/60" />
          </button>
        </div>

        {/* Quick Stats */}
        <div className="flex gap-2">
          <div className="px-3 py-1.5 rounded-full flex-1 text-center backdrop-blur-md text-xs font-medium text-white/70" style={{ backgroundColor: 'var(--color-bg-panel)' }}>
            {filteredExamples.length} 예제
          </div>
          <div className="px-3 py-1.5 rounded-full flex-1 text-center backdrop-blur-md text-xs font-medium text-[var(--color-currency-1)]" style={{ backgroundColor: 'var(--color-bg-panel)' }}>
            React 18+
          </div>
        </div>
      </div>

      {/* Category Filter - Horizontal Scroll */}
      <div className="relative z-10 px-4 py-3">
        <ScrollArea className="w-full">
          <div className="flex gap-2 pb-2">
            {categories.map((cat) => (
              <button
                key={cat.id}
                onClick={() => setSelectedCategory(cat.id)}
                className={`px-3 py-1.5 rounded-full text-xs font-medium whitespace-nowrap transition-all flex items-center gap-1 backdrop-blur-md border ${
                  selectedCategory === cat.id
                    ? 'border-transparent text-white'
                    : 'border-white/20 text-white/70 hover:text-white/90'
                }`}
                style={{
                  backgroundColor: selectedCategory === cat.id ? 'var(--color-primary)' : 'var(--color-bg-panel)'
                }}
              >
                <span>{cat.icon}</span>
                <span>{cat.label}</span>
              </button>
            ))}
          </div>
        </ScrollArea>
      </div>

      {/* Content - Examples Grid */}
      <div className="relative z-10 h-[540px] px-4 pb-4">
        <ScrollArea className="h-full">
          <div className="grid grid-cols-1 gap-3 pb-40 pr-4">
            {filteredExamples.map((example) => (
              <ExampleCard 
                key={example.id} 
                example={example}
                onCopy={handleCopy}
              />
            ))}
          </div>
        </ScrollArea>
      </div>

      {/* Copy Notification */}
      {showNotification && (
        <div className="fixed top-20 left-1/2 -translate-x-1/2 px-4 py-2 rounded-full backdrop-blur-md flex items-center gap-2 z-50 text-sm"
          style={{ backgroundColor: 'var(--color-primary)' }}
        >
          <CheckCircle2 className="w-4 h-4" />
          <span className="text-white">코드 복사됨!</span>
        </div>
      )}

      {/* Bottom Navigation - 80px */}
      <div className="absolute bottom-0 left-0 right-0 h-20 backdrop-blur-md border-t border-white/10" style={{ backgroundColor: 'var(--color-bg-panel)' }}>
        <div className="flex items-center justify-around h-full px-4">
          {/* Docs */}
          <button className="flex flex-col items-center justify-center min-w-[44px] min-h-[44px] px-2 rounded-lg transition-all" style={{ backgroundColor: 'var(--color-primary)' }}>
            <Book className="w-5 h-5 text-white mb-0.5" />
            <span className="text-xs text-white font-medium">가이드</span>
          </button>

          {/* Examples */}
          <button className="flex flex-col items-center justify-center min-w-[44px] min-h-[44px] px-2 hover:bg-white/10 rounded-lg transition-all">
            <Lightbulb className="w-5 h-5 text-white/60 mb-0.5" />
            <span className="text-xs text-white/60 font-medium">예제</span>
          </button>

          {/* Components */}
          <button className="flex flex-col items-center justify-center min-w-[44px] min-h-[44px] px-2 hover:bg-white/10 rounded-lg transition-all">
            <span className="text-xl mb-0.5">🧩</span>
            <span className="text-xs text-white/60 font-medium">컴포넌트</span>
          </button>

          {/* GitHub */}
          <button className="flex flex-col items-center justify-center min-w-[44px] min-h-[44px] px-2 hover:bg-white/10 rounded-lg transition-all">
            <Github className="w-5 h-5 text-white/60 mb-0.5" />
            <span className="text-xs text-white/60 font-medium">GitHub</span>
          </button>

          {/* Settings */}
          <button className="flex flex-col items-center justify-center min-w-[44px] min-h-[44px] px-2 hover:bg-white/10 rounded-lg transition-all">
            <span className="text-lg mb-0.5">⚙️</span>
            <span className="text-xs text-white/60 font-medium">설정</span>
          </button>
        </div>
      </div>
    </div>
  )
}
