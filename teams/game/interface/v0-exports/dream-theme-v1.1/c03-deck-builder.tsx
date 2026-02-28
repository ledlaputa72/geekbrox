import React, { useState, useEffect } from 'react';

interface Card {
  id: number;
  name: string;
  cost: number;
  type: 'Attack' | 'Defense' | 'Collection' | 'Synergy';
  rarity: 'Common' | 'Uncommon' | 'Rare' | 'Epic' | 'Legendary';
}

const getRarityGradient = (rarity: Card['rarity']) => {
  const gradients = {
    Common: 'linear-gradient(135deg, #AAAAAA 0%, #CCCCCC 100%)',
    Uncommon: 'linear-gradient(135deg, #4CAF50 0%, #81C784 100%)',
    Rare: 'linear-gradient(135deg, #2196F3 0%, #64B5F6 100%)',
    Epic: 'linear-gradient(135deg, #9C27B0 0%, #BA68C8 100%)',
    Legendary: 'linear-gradient(135deg, #FFC107 0%, #FFD54F 100%)'
  };
  return gradients[rarity];
};

const generateCards = (): Card[] => {
  const rarities: Card['rarity'][] = ['Common', 'Uncommon', 'Rare', 'Epic', 'Legendary'];
  const types: Card['type'][] = ['Attack', 'Defense', 'Collection', 'Synergy'];
  const cards: Card[] = [];
  
  for (let i = 1; i <= 30; i++) {
    cards.push({
      id: i,
      name: `Card ${i}`,
      cost: Math.floor(Math.random() * 5) + 1,
      type: types[Math.floor(Math.random() * types.length)],
      rarity: rarities[Math.floor(Math.random() * rarities.length)]
    });
  }
  return cards;
};

const DeckBuilder: React.FC = () => {
  const [availableCards, setAvailableCards] = useState<Card[]>([]);
  const [deck, setDeck] = useState<Card[]>([]);
  const maxDeckSize = 12;

  useEffect(() => {
    setAvailableCards(generateCards());
  }, []);

  const addToDeck = (card: Card) => {
    if (deck.length < maxDeckSize && !deck.find(c => c.id === card.id)) {
      setDeck([...deck, card]);
    }
  };

  const removeFromDeck = (cardId: number) => {
    setDeck(deck.filter(c => c.id !== cardId));
  };

  const deckStats = deck.reduce((acc, card) => {
    acc.dps += card.type === 'Attack' ? 10 : 0;
    acc.totalCost += card.cost;
    return acc;
  }, { dps: 0, totalCost: 0 });

  const avgCost = deck.length > 0 ? (deckStats.totalCost / deck.length).toFixed(1) : '0';

  return (
    <div className="deck-builder">
      <div className="header">
        <button className="back-button">←</button>
        <div className="title">Deck Builder</div>
        <button className={`save-button ${deck.length >= 8 ? 'active' : 'inactive'}`}>
          💾 Save
        </button>
      </div>

      <div className="deck-summary">
        Current deck ({deck.length}/{maxDeckSize}): DPS: {deckStats.dps} | Avg cost: {avgCost}
      </div>

      <div className="current-deck">
        {deck.map(card => (
          <div
            key={card.id}
            onClick={() => removeFromDeck(card.id)}
            className="deck-card"
            style={{ background: getRarityGradient(card.rarity) }}
          >
            <div className="deck-card-cost">{card.cost}</div>
            <div className="deck-card-name">{card.name}</div>
          </div>
        ))}
        {[...Array(maxDeckSize - deck.length)].map((_, i) => (
          <div key={`empty-${i}`} className="empty-slot">+</div>
        ))}
      </div>

      <div className="filter-bar">
        <button className="filter-btn">Filter ▼</button>
        <button className="filter-btn">Sort ▼</button>
        <button className="filter-btn">🔍 Search</button>
      </div>

      <div className="available-cards">
        {availableCards.map(card => {
          const inDeck = deck.find(c => c.id === card.id);
          return (
            <div
              key={card.id}
              onClick={() => !inDeck && addToDeck(card)}
              className="available-card"
              style={{
                background: getRarityGradient(card.rarity),
                opacity: inDeck ? 0.5 : 1,
                cursor: inDeck ? 'not-allowed' : 'pointer'
              }}
            >
              <div className="card-cost">{card.cost}</div>
              <div className="card-name">{card.name}</div>
              <div className="card-type">{card.type === 'Attack' ? '⚔️' : card.type === 'Defense' ? '🛡' : card.type === 'Collection' ? '💎' : '✨'}</div>
              {inDeck && <div className="in-deck-label">In Deck</div>}
            </div>
          );
        })}
      </div>

      <div className="tab-bar">
        <button className="tab-button"><div className="tab-icon">🏠</div><div className="tab-label">Home</div></button>
        <button className="tab-button active"><div className="tab-icon">🎴</div><div className="tab-label">Cards</div></button>
        <button className="tab-button"><div className="tab-icon">⬆️</div><div className="tab-label">Upgrade</div></button>
        <button className="tab-button disabled"><div className="tab-icon">📊</div><div className="tab-label">Progress</div></button>
        <button className="tab-button"><div className="tab-icon">🛒</div><div className="tab-label">Shop</div></button>
      </div>

      <style jsx>{`
        .deck-builder { width: 390px; height: 844px; background: #1A1A2E; font-family: 'Nunito', sans-serif; color: #FFF; position: relative; overflow: hidden; }
        .header { height: 60px; display: flex; justify-content: space-between; align-items: center; padding: 0 20px; background: #2C2C3E; }
        .back-button { font-size: 24px; background: none; border: none; color: white; cursor: pointer; }
        .title { font-size: 18px; font-weight: bold; }
        .save-button { padding: 8px 16px; border-radius: 8px; border: none; color: white; font-family: 'Nunito'; font-weight: bold; cursor: pointer; }
        .save-button.active { background: #5A7FC0; }
        .save-button.inactive { background: #555; cursor: not-allowed; }
        .deck-summary { height: 40px; display: flex; align-items: center; justify-content: center; background: #2C2C3E; font-size: 14px; }
        .current-deck { height: 120px; padding: 10px 20px; display: flex; gap: 8px; overflow-x: auto; align-items: center; }
        .deck-card { min-width: 64px; height: 90px; border-radius: 8px; padding: 6px; display: flex; flex-direction: column; justify-content: space-between; cursor: pointer; position: relative; box-shadow: 0 2px 4px rgba(0,0,0,0.2); }
        .deck-card-cost { position: absolute; top: 4px; right: 4px; width: 16px; height: 16px; border-radius: 50%; background: #1A1A2E; display: flex; align-items: center; justify-content: center; font-size: 8px; font-weight: bold; }
        .deck-card-name { font-size: 9px; font-weight: bold; text-align: center; margin-top: 16px; }
        .empty-slot { min-width: 64px; height: 90px; border: 2px dashed #555; border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: 24px; color: #555; }
        .filter-bar { height: 50px; display: flex; align-items: center; gap: 10px; padding: 0 20px; }
        .filter-btn { padding: 8px 16px; border-radius: 8px; border: none; background: #5A7FC0; color: white; font-family: 'Nunito'; cursor: pointer; }
        .available-cards { height: calc(844px - 60px - 40px - 120px - 50px - 60px); overflow-y: auto; padding: 20px; display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; }
        .available-card { width: 100px; height: 140px; border-radius: 12px; padding: 8px; display: flex; flex-direction: column; justify-content: space-between; position: relative; box-shadow: 0 2px 4px rgba(0,0,0,0.2); }
        .card-cost { position: absolute; top: 8px; right: 8px; width: 20px; height: 20px; border-radius: 50%; background: #1A1A2E; display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: bold; }
        .card-name { font-size: 12px; font-weight: bold; text-align: center; margin-top: 20px; }
        .card-type { font-size: 16px; text-align: center; }
        .in-deck-label { position: absolute; bottom: 8px; left: 50%; transform: translateX(-50%); background: rgba(0,0,0,0.7); padding: 2px 8px; border-radius: 8px; font-size: 10px; }
        .tab-bar { position: absolute; bottom: 0; left: 0; width: 100%; height: 60px; background: #2C2C3E; border-top: 1px solid #1A1A2E; display: flex; justify-content: space-around; align-items: center; }
        .tab-button { background: none; border: none; display: flex; flex-direction: column; align-items: center; gap: 4px; cursor: pointer; font-family: 'Nunito'; color: #888; }
        .tab-button.active { color: #7B9EF0; }
        .tab-button.active .tab-label { color: #FFF; }
        .tab-button.disabled { opacity: 0.4; cursor: not-allowed; }
        .tab-icon { font-size: 24px; filter: grayscale(100%); }
        .tab-button.active .tab-icon { filter: none; }
        .tab-label { font-size: 12px; font-weight: bold; }
      `}</style>
    </div>
  );
};

export default DeckBuilder;
