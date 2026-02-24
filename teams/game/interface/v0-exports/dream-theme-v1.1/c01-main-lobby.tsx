import React, { useState } from 'react';

interface MainLobbyProps {}

const MainLobby: React.FC<MainLobbyProps> = () => {
  const [reveries, setReveries] = useState(1234);
  const [offlineRewards, setOfflineRewards] = useState(2345);
  const [showOfflineRewards, setShowOfflineRewards] = useState(true);

  const collectOfflineRewards = () => {
    setReveries(reveries + offlineRewards);
    setShowOfflineRewards(false);
  };

  return (
    <div className="main-lobby">
      {/* Top Bar */}
      <div className="top-bar">
        <div className="reveries-counter">
          💰 {reveries.toLocaleString()} R
        </div>
        <button className="settings-button">⚙️</button>
      </div>

      {/* Character Area */}
      <div className="character-area">
        <div className="character-container">
          <div className="character">☁️</div>
          <div className="particles">
            {[...Array(8)].map((_, i) => (
              <div key={i} className="particle" style={{
                animationDelay: `${i * 0.5}s`,
                left: `${50 + Math.cos((i * Math.PI) / 4) * 40}%`,
                top: `${50 + Math.sin((i * Math.PI) / 4) * 40}%`
              }}>✨</div>
            ))}
          </div>
        </div>
      </div>

      {/* Offline Rewards Banner */}
      {showOfflineRewards && (
        <div className="offline-rewards" onClick={collectOfflineRewards}>
          <div className="banner-content">
            <span className="banner-title">Offline rewards ready! ⭐</span>
            <span className="banner-amount">Tap to collect: {offlineRewards.toLocaleString()} R</span>
          </div>
        </div>
      )}

      {/* Main Action Grid */}
      <div className="action-grid">
        <button className="action-button run-start">
          <div className="button-icon">🚀</div>
          <div className="button-label">Run Start</div>
        </button>
        
        <button className="action-button cards">
          <div className="button-icon">🎴</div>
          <div className="button-label">Cards</div>
          <div className="badge">3</div>
        </button>
        
        <button className="action-button upgrade">
          <div className="button-icon">⬆️</div>
          <div className="button-label">Upgrade</div>
          <div className="badge">5</div>
        </button>
        
        <button className="action-button shop">
          <div className="button-icon">🛒</div>
          <div className="button-label">Shop</div>
          <div className="badge">2</div>
        </button>
      </div>

      {/* Bottom Tab Bar */}
      <div className="tab-bar">
        <button className="tab-button active">
          <div className="tab-icon">🏠</div>
          <div className="tab-label">Home</div>
        </button>
        <button className="tab-button">
          <div className="tab-icon">🎴</div>
          <div className="tab-label">Cards</div>
        </button>
        <button className="tab-button">
          <div className="tab-icon">⬆️</div>
          <div className="tab-label">Upgrade</div>
        </button>
        <button className="tab-button">
          <div className="tab-icon">📊</div>
          <div className="tab-label">Progress</div>
        </button>
        <button className="tab-button">
          <div className="tab-icon">🛒</div>
          <div className="tab-label">Shop</div>
        </button>
      </div>

      <style jsx>{`
        .main-lobby {
          width: 390px;
          height: 844px;
          background: #1A1A2E;
          font-family: 'Nunito', sans-serif;
          color: #FFFFFF;
          position: relative;
          overflow: hidden;
        }

        .top-bar {
          height: 60px;
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 0 20px;
          background: rgba(44, 44, 62, 0.9);
        }

        .reveries-counter {
          font-size: 18px;
          font-weight: bold;
          color: #FFD700;
          cursor: pointer;
          transition: transform 0.2s;
        }

        .reveries-counter:hover {
          transform: scale(1.05);
        }

        .settings-button {
          font-size: 24px;
          background: none;
          border: none;
          cursor: pointer;
          padding: 8px;
          transition: transform 0.2s;
        }

        .settings-button:hover {
          transform: rotate(90deg);
        }

        .character-area {
          height: 300px;
          display: flex;
          justify-content: center;
          align-items: center;
          position: relative;
        }

        .character-container {
          position: relative;
          width: 200px;
          height: 250px;
        }

        .character {
          font-size: 120px;
          animation: float 2s ease-in-out infinite;
          text-align: center;
        }

        @keyframes float {
          0%, 100% { transform: translateY(0); }
          50% { transform: translateY(-10px); }
        }

        .particles {
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
        }

        .particle {
          position: absolute;
          font-size: 16px;
          animation: rotate 4s linear infinite;
          opacity: 0.6;
        }

        @keyframes rotate {
          from { transform: rotate(0deg) translateX(40px) rotate(0deg); }
          to { transform: rotate(360deg) translateX(40px) rotate(-360deg); }
        }

        .offline-rewards {
          height: 100px;
          margin: 0 20px 20px;
          background: linear-gradient(135deg, #8B5FBF 0%, #9C27B0 100%);
          border-radius: 16px;
          display: flex;
          align-items: center;
          justify-content: center;
          cursor: pointer;
          transition: transform 0.3s;
          box-shadow: 0 4px 12px rgba(139, 95, 191, 0.4);
        }

        .offline-rewards:hover {
          transform: scale(1.02);
        }

        .banner-content {
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 8px;
        }

        .banner-title {
          font-size: 18px;
          font-weight: bold;
        }

        .banner-amount {
          font-size: 20px;
          font-weight: bold;
          color: #FFD700;
        }

        .action-grid {
          display: grid;
          grid-template-columns: repeat(2, 1fr);
          gap: 12px;
          padding: 0 20px;
          margin-bottom: 20px;
        }

        .action-button {
          height: 120px;
          border: none;
          border-radius: 16px;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          gap: 8px;
          cursor: pointer;
          position: relative;
          transition: transform 0.1s, box-shadow 0.3s;
          font-family: 'Nunito', sans-serif;
          color: white;
        }

        .action-button:active {
          transform: scale(0.95);
        }

        .run-start {
          background: #7B9EF0;
          animation: pulse 2s ease-in-out infinite;
        }

        @keyframes pulse {
          0%, 100% { box-shadow: 0 0 0 0 rgba(123, 158, 240, 0.7); }
          50% { box-shadow: 0 0 0 10px rgba(123, 158, 240, 0); }
        }

        .cards {
          background: #5A7FC0;
        }

        .upgrade {
          background: #9BA4C0;
        }

        .shop {
          background: #8B5FBF;
        }

        .button-icon {
          font-size: 40px;
        }

        .button-label {
          font-size: 16px;
          font-weight: bold;
        }

        .badge {
          position: absolute;
          top: 8px;
          right: 8px;
          width: 24px;
          height: 24px;
          background: #F44336;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 12px;
          font-weight: bold;
        }

        .tab-bar {
          position: absolute;
          bottom: 0;
          left: 0;
          width: 100%;
          height: 80px;
          background: #2C2C3E;
          border-top: 1px solid #1A1A2E;
          display: flex;
          justify-content: space-around;
          align-items: center;
        }

        .tab-button {
          background: none;
          border: none;
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 4px;
          cursor: pointer;
          font-family: 'Nunito', sans-serif;
          color: #888888;
          transition: transform 0.2s;
        }

        .tab-button.active {
          color: #7B9EF0;
        }

        .tab-button:hover {
          transform: translateY(-2px);
        }

        .tab-icon {
          font-size: 24px;
          filter: grayscale(100%);
        }

        .tab-button.active .tab-icon {
          filter: none;
        }

        .tab-label {
          font-size: 12px;
          font-weight: bold;
        }

        .tab-button.active .tab-label {
          color: #FFFFFF;
        }
      `}</style>
    </div>
  );
};

export default MainLobby;
