import React, { useState } from 'react';

const RewardsModal: React.FC = () => {
  const [selectedCard, setSelectedCard] = useState<number | null>(null);
  const cards = [
    { id: 1, name: 'Void Strike', cost: 3, type: 'Attack', rarity: 'Rare' },
    { id: 2, name: 'Dream Shield', cost: 2, type: 'Defense', rarity: 'Uncommon' },
    { id: 3, name: 'Memory Blast', cost: 4, type: 'Attack', rarity: 'Epic' }
  ];
  return (
    <div className="modal-overlay">
      <div className="modal-container">
        <div className="modal-header"><div className="emoji">✨</div><div className="title">Choose Your Reward</div><div className="subtitle">Select 1 card to add to your deck</div></div>
        <div className="card-row">{cards.map(card => <div key={card.id} onClick={() => setSelectedCard(card.id)} className={\`reward-card \${selectedCard === card.id ? 'selected' : ''}\`}><div className="card-cost">{card.cost}</div><div className="card-name">{card.name}</div><div className="card-icon">{card.type === 'Attack' ? '⚔️' : '🛡'}</div></div>)}</div>
        <button className="claim-button" disabled={!selectedCard}>Add to Deck</button>
        <button className="skip-button">Skip Reward</button>
      </div>
      <style jsx>{\`
        @keyframes slideDown { from { opacity: 0; transform: translateY(-50px); } to { opacity: 1; transform: translateY(0); } }
        .modal-overlay { width: 390px; height: 844px; background: rgba(0,0,0,0.85); display: flex; align-items: center; justify-content: center; }
        .modal-container { width: 350px; background: #2C2C3E; border-radius: 20px; padding: 24px; box-shadow: 0 16px 32px rgba(0,0,0,0.5); animation: slideDown 0.5s ease-out; }
        .modal-header { text-align: center; margin-bottom: 24px; }
        .emoji { font-size: 32px; margin-bottom: 12px; }
        .title { font-size: 24px; font-weight: bold; margin-bottom: 8px; color: white; font-family: 'Nunito'; }
        .subtitle { font-size: 14px; color: #AAA; font-family: 'Nunito'; }
        .card-row { display: flex; gap: 12px; margin-bottom: 24px; justify-content: center; }
        .reward-card { width: 100px; height: 160px; background: linear-gradient(135deg, #2196F3 0%, #64B5F6 100%); border-radius: 12px; padding: 10px; display: flex; flex-direction: column; justify-content: space-between; cursor: pointer; position: relative; transition: all 0.3s; }
        .reward-card.selected { border: 3px solid #FFD700; transform: scale(1.08); box-shadow: 0 8px 24px rgba(255,215,0,0.6); }
        .card-cost { position: absolute; top: 8px; right: 8px; width: 24px; height: 24px; border-radius: 50%; background: #1A1A2E; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: bold; color: white; }
        .card-name { font-size: 12px; font-weight: bold; text-align: center; color: white; font-family: 'Nunito'; }
        .card-icon { font-size: 40px; text-align: center; }
        .claim-button { width: 100%; height: 56px; border-radius: 12px; border: none; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; font-family: 'Nunito'; font-weight: bold; font-size: 18px; margin-bottom: 12px; cursor: pointer; }
        .claim-button:disabled { background: #555; cursor: not-allowed; }
        .skip-button { width: 100%; height: 44px; border-radius: 12px; border: 2px solid #7B9EF0; background: transparent; color: #7B9EF0; font-family: 'Nunito'; font-weight: bold; cursor: pointer; }
      \`}</style>
    </div>
  );
};
export default RewardsModal;
