import React, { useState, useEffect } from 'react';

const VictoryScreen: React.FC = () => {
  const [showConfetti, setShowConfetti] = useState(true);
  const [selectedCard, setSelectedCard] = useState<number | null>(null);

  useEffect(() => {
    setTimeout(() => setShowConfetti(false), 5000);
  }, []);

  return (
    <div className="victory-screen">
      {showConfetti && [...Array(30)].map((_, i) => (
        <div key={i} className="confetti" style={{ left: \`\${Math.random() * 100}%\`, animationDelay: \`\${Math.random()}s\` }} />
      ))}
      <div className="victory-title">
        <div className="emoji">🎉</div>
        <div className="title">VICTORY!</div>
        <div className="subtitle">Dream Cleared Successfully</div>
      </div>
      <div className="stats-box">
        <div className="stat"><div className="value">24</div><div className="label">Turns</div></div>
        <div className="stat"><div className="value">156</div><div className="label">Damage</div></div>
        <div className="stat"><div className="value">235</div><div className="label">Reveries</div></div>
        <div className="stat"><div className="value">10/10</div><div className="label">Nodes</div></div>
      </div>
      <div className="reward-section">
        <div className="section-title">Choose Your Reward</div>
        <div className="reward-cards">
          {[1, 2, 3].map(i => (
            <div key={i} onClick={() => setSelectedCard(i)} className={\`reward-card \${selectedCard === i ? 'selected' : ''}\`}>
              Card {i}
            </div>
          ))}
        </div>
      </div>
      <button className="claim-button" disabled={!selectedCard}>Claim Reward</button>
      <button className="continue-button">Continue to Main Lobby</button>
      <style jsx>{\`
        @keyframes confetti { from { transform: translateY(-100vh) rotate(0deg); } to { transform: translateY(100vh) rotate(720deg); } }
        .victory-screen { width: 390px; height: 844px; background: linear-gradient(180deg, #1A1A2E 0%, #2C3E50 100%); font-family: 'Nunito', sans-serif; color: #FFF; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 20px; position: relative; overflow: hidden; }
        .confetti { position: absolute; width: 10px; height: 10px; background: #FFD700; border-radius: 50%; animation: confetti 3s linear forwards; }
        .victory-title { text-align: center; margin-bottom: 30px; }
        .emoji { font-size: 64px; margin-bottom: 16px; }
        .title { font-size: 36px; font-weight: bold; color: #FFD700; margin-bottom: 12px; }
        .subtitle { font-size: 16px; color: #AAA; }
        .stats-box { width: 100%; background: #2C2C3E; border-radius: 16px; padding: 20px; margin-bottom: 30px; display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; }
        .stat { text-align: center; }
        .value { font-size: 32px; font-weight: bold; color: #7B9EF0; }
        .label { font-size: 14px; color: #AAA; }
        .reward-section { width: 100%; margin-bottom: 30px; }
        .section-title { font-size: 18px; font-weight: bold; text-align: center; margin-bottom: 16px; }
        .reward-cards { display: flex; gap: 12px; justify-content: center; }
        .reward-card { width: 100px; height: 140px; background: linear-gradient(135deg, #2196F3 0%, #64B5F6 100%); border-radius: 12px; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: all 0.3s; }
        .reward-card.selected { border: 3px solid #FFD700; transform: scale(1.05); box-shadow: 0 8px 24px rgba(255,215,0,0.6); }
        .claim-button { width: 100%; height: 56px; border-radius: 12px; border: none; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; font-family: 'Nunito'; font-weight: bold; font-size: 18px; margin-bottom: 12px; cursor: pointer; }
        .claim-button:disabled { background: #555; cursor: not-allowed; }
        .continue-button { width: 100%; height: 48px; border-radius: 12px; border: none; background: #5A7FC0; color: white; font-family: 'Nunito'; font-weight: bold; cursor: pointer; }
      \`}</style>
    </div>
  );
};

export default VictoryScreen;
