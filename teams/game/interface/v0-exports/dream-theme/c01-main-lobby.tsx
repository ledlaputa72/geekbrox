# 모바일 방치형 덱빌딩 게임 - 메인 로비 UI

<div className="w-[390px] h-[844px] mx-auto bg-gradient-to-b from-[var(--color-bg-main)] to-[#1A2A5E] relative overflow-hidden">
  {/* CSS Custom Properties */}
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

  {/* Background Stars Animation */}
  <div className="absolute inset-0 overflow-hidden">
    <div className="absolute w-1 h-1 bg-white rounded-full opacity-60 animate-pulse" style={{top: '20%', left: '15%'}}></div>
    <div className="absolute w-1 h-1 bg-white rounded-full opacity-40 animate-pulse" style={{top: '35%', left: '80%', animationDelay: '1s'}}></div>
    <div className="absolute w-0.5 h-0.5 bg-white rounded-full opacity-80 animate-pulse" style={{top: '60%', left: '25%', animationDelay: '2s'}}></div>
    <div className="absolute w-1 h-1 bg-white rounded-full opacity-50 animate-pulse" style={{top: '75%', left: '70%', animationDelay: '0.5s'}}></div>
    <div className="absolute w-0.5 h-0.5 bg-white rounded-full opacity-70 animate-pulse" style={{top: '45%', left: '60%', animationDelay: '1.5s'}}></div>
  </div>

  {/* Top Currency Bar - 108px */}
  <div className="relative z-10 h-[108px] pt-11 px-4">
    <div className="flex items-center justify-between h-16">
      {/* Left Currency */}
      <div className="flex items-center gap-3">
        {/* Reverie Currency */}
        <div className="flex items-center gap-2 px-3 py-2 rounded-full backdrop-blur-md" style={{backgroundColor: 'var(--color-bg-panel)'}}>
          <span className="text-lg">💎</span>
          <span className="text-sm font-semibold text-white">1,234</span>
        </div>
        
        {/* Dream Shard Currency */}
        <div className="flex items-center gap-2 px-3 py-2 rounded-full backdrop-blur-md" style={{backgroundColor: 'var(--color-bg-panel)'}}>
          <span className="text-lg">✨</span>
          <span className="text-sm font-semibold text-white">56</span>
        </div>
      </div>

      {/* Right Icons */}
      <div className="flex items-center gap-2">
        <button className="w-11 h-11 flex items-center justify-center rounded-full backdrop-blur-md" style={{backgroundColor: 'var(--color-bg-panel)'}}>
          <span className="text-lg">🔔</span>
        </button>
        <button className="w-11 h-11 flex items-center justify-center rounded-full backdrop-blur-md" style={{backgroundColor: 'var(--color-bg-panel)'}}>
          <span className="text-lg">⚙️</span>
        </button>
      </div>
    </div>
  </div>

  {/* Main Visual Area - ~380px */}
  <div className="relative h-[380px] flex flex-col items-center justify-center px-4">
    {/* Character Silhouette */}
    <div className="relative mb-8">
      <div className="w-48 h-64 relative">
        {/* Character Shadow/Silhouette */}
        <div className="absolute inset-0 bg-gradient-to-b from-white/20 to-white/5 rounded-full blur-sm transform scale-110"></div>
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="w-32 h-40 bg-gradient-to-b from-white/30 to-white/10 rounded-full relative">
            {/* Cape/Cloak effect */}
            <div className="absolute -inset-4 bg-gradient-to-b from-white/15 to-transparent rounded-full blur-md"></div>
            {/* Character body */}
            <div className="absolute inset-x-4 top-8 bottom-4 bg-gradient-to-b from-white/25 to-white/5 rounded-full"></div>
          </div>
        </div>
        
        {/* Floating particles around character */}
        <div className="absolute w-2 h-2 bg-white/60 rounded-full animate-bounce" style={{top: '20%', left: '10%', animationDelay: '0s'}}></div>
        <div className="absolute w-1 h-1 bg-white/40 rounded-full animate-bounce" style={{top: '40%', right: '15%', animationDelay: '1s'}}></div>
        <div className="absolute w-1.5 h-1.5 bg-white/50 rounded-full animate-bounce" style={{bottom: '30%', left: '20%', animationDelay: '2s'}}></div>
      </div>
    </div>

    {/* Offline Revenue Banner */}
    <div className="w-full max-w-sm mx-auto px-4 py-3 rounded-2xl backdrop-blur-md border border-white/20" style={{backgroundColor: 'var(--color-bg-panel)'}}>
      <div className="text-center">
        <p className="text-sm text-white/80 mb-1">오프라인 수익</p>
        <p className="text-lg font-bold text-[var(--color-currency-1)]">+345 레버리</p>
      </div>
    </div>
  </div>

  {/* Main Action Button - 72px */}
  <div className="h-[72px] px-4 flex items-center">
    <button className="w-full h-14 rounded-[var(--radius-button)] bg-gradient-to-r from-[var(--color-primary)] to-[#9BB5F5] flex items-center justify-center shadow-lg active:scale-95 transition-transform">
      <span className="text-lg font-bold text-white">💎 수집하기 (345 레버리)</span>
    </button>
  </div>

  {/* Bottom Navigation - 80px */}
  <div className="absolute bottom-0 left-0 right-0 h-20">
    <div className="h-full backdrop-blur-md border-t border-white/10" style={{backgroundColor: 'var(--color-bg-panel)'}}>
      <div className="flex items-center justify-around h-full px-4">
        {/* Home Tab - Active */}
        <button className="flex flex-col items-center justify-center min-w-[44px] min-h-[44px] px-2">
          <div className="w-8 h-8 rounded-lg bg-[var(--color-primary)] flex items-center justify-center mb-1">
            <span className="text-lg">🏠</span>
          </div>
          <span className="text-xs text-[var(--color-primary)] font-medium">홈</span>
        </button>

        {/* Cards Tab */}
        <button className="flex flex-col items-center justify-center min-w-[44px] min-h-[44px] px-2">
          <div className="w-8 h-8 flex items-center justify-center mb-1">
            <span className="text-lg opacity-60">🃏</span>
          </div>
          <span className="text-xs text-white/60">카드</span>
        </button>

        {/* Upgrade Tab */}
        <button className="flex flex-col items-center justify-center min-w-[44px] min-h-[44px] px-2">
          <div className="w-8 h-8 flex items-center justify-center mb-1">
            <span className="text-lg opacity-60">⬆️</span>
          </div>
          <span className="text-xs text-white/60">업그레이드</span>
        </button>

        {/* Prestige Tab */}
        <button className="flex flex-col items-center justify-center min-w-[44px] min-h-[44px] px-2">
          <div className="w-8 h-8 flex items-center justify-center mb-1">
            <span className="text-lg opacity-60">🌙</span>
          </div>
          <span className="text-xs text-white/60">프레스티지</span>
        </button>

        {/* Shop Tab */}
        <button className="flex flex-col items-center justify-center min-w-[44px] min-h-[44px] px-2">
          <div className="w-8 h-8 flex items-center justify-center mb-1">
            <span className="text-lg opacity-60">🏪</span>
          </div>
          <span className="text-xs text-white/60">상점</span>
        </button>
      </div>
    </div>
  </div>
</div>

이 UI는 다음과 같은 특징을 가지고 있습니다:

## 주요 특징

1. **정확한 레이아웃 구조**
   - 상단 재화 바: 108px (Safe Area 포함)
   - 메인 비주얼: 380px
   - 메인 액션 버튼: 72px  
   - 하단 내비게이션: 80px

2. **글래스모피즘 디자인**
   - `backdrop-blur-md` + 반투명 배경
   - CSS Custom Properties 활용
   - 부드러운 그라데이션과 테두리

3. **몽환적인 비주얼**
   - 별빛 파티클 애니메이션
   - 중앙 캐릭터 실루엣 (흰 망토 효과)
   - 떠다니는 파티클 효과

4. **접근성 고려**
   - 모든 버튼 최소 44×44px
   - 충분한 색상 대비
   - 명확한 시각적 피드백

5. **모바일 최적화**
   - 390×844px 정확한 크기
   - 터치 친화적 인터페이스
   - 활성 상태 시각적 표시