import React, { useState, useEffect } from 'react';

interface Card {
  id: number;
  name: string;
  cost: number;
  type: 'Attack' | 'Defense' | 'Collection' | 'Synergy';
  rarity: 'Common' | 'Uncommon' | 'Rare' | 'Epic' | 'Legendary';
  owned: boolean;
  description: string;
}

const generateCards = (): Card[] => {
  const rarities: Card['rarity'][] = ['Common', 'Uncommon', 'Rare', 'Epic', 'Legendary'];
  const types: Card['type'][] = ['Attack', 'Defense', 'Collection', 'Synergy'];
  const cards: Card[] = [];
  
  for (let i = 1; i <= 85; i++) {
    const owned = Math.random() > 0.5;
    const rarity = rarities[Math.floor(Math.random() * rarities.length)];
    cards.push({
      id: i,
      name: owned ? `Card ${i}` : '???',
      cost: Math.floor(Math.random() * 5) + 1,
      type: types[Math.floor(Math.random() * types.length)],
      rarity: rarity,
      owned: owned,
      description: `This is the description for Card ${i}. It has special effects.`
    });
  }
  return cards;
};

const getRarityGradient = (rarity: Card['rarity'], owned: boolean) => {
  const gradients = {
    Common: 'linear-gradient(135deg, #AAAAAA 0%, #CCCCCC 100%)',
    Uncommon: 'linear-gradient(135deg, #4CAF50 0%, #81C784 100%)',
    Rare: 'linear-gradient(135deg, #2196F3 0%, #64B5F6 100%)',
    Epic: 'linear-gradient(135deg, #9C27B0 0%, #BA68C8 100%)',
    Legendary: 'linear-gradient(135deg, #FFC107 0%, #FFD54F 100%)'
  };
  return owned ? gradients[rarity] : '#555555';
};

const getTypeIcon = (type: Card['type']) => {
  const icons = {
    Attack: '⚔️',
    Defense: '🛡',
    Collection: '💎',
    Synergy: '✨'
  };
  return icons[type];
};

const CardLibrary: React.FC = () => {
  const [cards, setCards] = useState<Card[]>([]);
  const [filteredCards, setFilteredCards] = useState<Card[]>([]);
  const [selectedCard, setSelectedCard] = useState<Card | null>(null);
  const [typeFilter, setTypeFilter] = useState('All');
  const [rarityFilter, setRarityFilter] = useState('All');
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    const allCards = generateCards();
    setCards(allCards);
    setFilteredCards(allCards);
  }, []);

  useEffect(() => {
    let filtered = cards;
    
    if (typeFilter !== 'All') {
      filtered = filtered.filter(c => c.type === typeFilter);
    }
    if (rarityFilter !== 'All') {
      filtered = filtered.filter(c => c.rarity === rarityFilter);
    }
    if (searchTerm) {
      filtered = filtered.filter(c => 
        c.name.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }
    
    setFilteredCards(filtered);
  }, [typeFilter, rarityFilter, searchTerm, cards]);

  const stats = cards.reduce((acc, card) => {
    if (card.owned) {
      acc.total++;
      acc[card.rarity] = (acc[card.rarity] || 0) + 1;
    }
    return acc;
  }, { total: 0, Common: 0, Uncommon: 0, Rare: 0, Epic: 0, Legendary: 0 } as any);

  return (
    <div className="card-library">
      {/* Header */}
      <div className="header">
        <button className="back-button">←</button>
        <div className="title">Card Library</div>
        <button className="filter-button">⚙</button>
      </div>

      {/* Stats Bar */}
      <div className="stats-bar">
        <span>Collected: {stats.total}/85</span>
        <span>|</span>
        <span>Common: {stats.Common}</span>
        <span>|</span>
        <span>Rare: {stats.Rare}</span>
        <span>|</span>
        <span>Epic: {stats.Epic}</span>
        <span>|</span>
        <span>Legendary: {stats.Legendary}</span>
      </div>

      {/* Filter Bar */}
      <div className="filter-bar">
        <select 
          value={typeFilter}
          onChange={(e) => setTypeFilter(e.target.value)}
          className="filter-select"
        >
          <option>All Types</option>
          <option>Attack</option>
          <option>Defense</option>
          <option>Collection</option>
          <option>Synergy</option>
        </select>
        
        <select 
          value={rarityFilter}
          onChange={(e) => setRarityFilter(e.target.value)}
          className="filter-select"
        >
          <option>All Rarities</option>
          <option>Common</option>
          <option>Uncommon</option>
          <option>Rare</option>
          <option>Epic</option>
          <option>Legendary</option>
        </select>

        <input 
          type="text"
          placeholder="🔍 Search"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="search-input"
        />
      </div>

      {/* Card Grid */}
      <div className="card-grid">
        {filteredCards.map(card => (
          <div
            key={card.id}
            onClick={() => setSelectedCard(card)}
            className="card-item"
            style={{
              background: getRarityGradient(card.rarity, card.owned),
              filter: card.owned ? 'none' : 'grayscale(100%)',
              opacity: card.owned ? 1 : 0.6
            }}
          >
            <div className="cost-badge">{card.cost}</div>
            <div className="card-name">{card.name}</div>
            <div className="card-footer">
              <div className="type-icon">{getTypeIcon(card.type)}</div>
              <div className="ownership-icon">{card.owned ? '✓' : '🔒'}</div>
            </div>
          </div>
        ))}
      </div>

      {/* Card Detail Modal */}
      {selectedCard && (
        <div className="modal-overlay" onClick={() => setSelectedCard(null)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <button onClick={() => setSelectedCard(null)} className="close-button">×</button>
            <div 
              className="large-card"
              style={{ background: getRarityGradient(selectedCard.rarity, selectedCard.owned) }}
            >
              <div className="large-icon">{getTypeIcon(selectedCard.type)}</div>
            </div>
            <div className="modal-details">
              <div className="modal-name">{selectedCard.name}</div>
              <div className="modal-cost">Cost: {selectedCard.cost} Energy</div>
              <div className="modal-type">Type: {selectedCard.type}</div>
              <div className="modal-description">{selectedCard.description}</div>
              <div className="modal-rarity">{selectedCard.rarity}</div>
            </div>
          </div>
        </div>
      )}

      {/* Bottom Tab Bar */}
      <div className="tab-bar">
        <button className="tab-button">
          <div className="tab-icon">🏠</div>
          <div className="tab-label">Home</div>
        </button>
        <button className="tab-button active">
          <div className="tab-icon">🎴</div>
          <div className="tab-label">Cards</div>
        </button>
        <button className="tab-button">
          <div className="tab-icon">⬆️</div>
          <div className="tab-label">Upgrade</div>
        </button>
        <button className="tab-button disabled">
          <div className="tab-icon">📊</div>
          <div className="tab-label">Progress</div>
        </button>
        <button className="tab-button">
          <div className="tab-icon">🛒</div>
          <div className="tab-label">Shop</div>
        </button>
      </div>

      <style jsx>{`
        .card-library {
          width: 390px;
          height: 844px;
          background: #1A1A2E;
          font-family: 'Nunito', sans-serif;
          color: #FFFFFF;
          position: relative;
          overflow: hidden;
        }

        .header {
          height: 60px;
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 0 20px;
          background: #2C2C3E;
        }

        .back-button, .filter-button {
          font-size: 24px;
          background: none;
          border: none;
          color: white;
          cursor: pointer;
        }

        .title {
          font-size: 18px;
          font-weight: bold;
        }

        .stats-bar {
          height: 40px;
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 8px;
          font-size: 12px;
          background: #2C2C3E;
        }

        .filter-bar {
          height: 50px;
          display: flex;
          align-items: center;
          gap: 10px;
          padding: 0 20px;
        }

        .filter-select {
          padding: 8px;
          border-radius: 8px;
          border: none;
          background: #5A7FC0;
          color: white;
          font-family: 'Nunito';
          cursor: pointer;
        }

        .search-input {
          flex: 1;
          padding: 8px;
          border-radius: 8px;
          border: none;
          background: #2C2C3E;
          color: white;
          font-family: 'Nunito';
        }

        .card-grid {
          height: calc(844px - 60px - 40px - 50px - 60px);
          overflow-y: auto;
          padding: 20px;
          display: grid;
          grid-template-columns: repeat(3, 1fr);
          gap: 12px;
        }

        .card-item {
          width: 100px;
          height: 140px;
          border-radius: 12px;
          padding: 8px;
          display: flex;
          flex-direction: column;
          justify-content: space-between;
          cursor: pointer;
          position: relative;
          box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }

        .cost-badge {
          position: absolute;
          top: 8px;
          right: 8px;
          width: 20px;
          height: 20px;
          border-radius: 50%;
          background: #1A1A2E;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 10px;
          font-weight: bold;
        }

        .card-name {
          font-size: 12px;
          font-weight: bold;
          text-align: center;
          margin-top: 20px;
        }

        .card-footer {
          display: flex;
          justify-content: space-between;
          align-items: center;
        }

        .type-icon, .ownership-icon {
          font-size: 16px;
        }

        .modal-overlay {
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          background: rgba(0,0,0,0.8);
          display: flex;
          align-items: center;
          justify-content: center;
          z-index: 200;
        }

        .modal-content {
          width: 350px;
          height: 600px;
          background: #2C2C3E;
          border-radius: 16px;
          padding: 20px;
          position: relative;
        }

        .close-button {
          position: absolute;
          top: 10px;
          right: 10px;
          background: none;
          border: none;
          color: white;
          font-size: 24px;
          cursor: pointer;
        }

        .large-card {
          width: 200px;
          height: 280px;
          margin: 20px auto;
          border-radius: 16px;
          display: flex;
          align-items: center;
          justify-content: center;
        }

        .large-icon {
          font-size: 64px;
        }

        .modal-details {
          text-align: center;
        }

        .modal-name {
          font-size: 20px;
          font-weight: bold;
          margin-bottom: 10px;
        }

        .modal-cost {
          font-size: 16px;
          font-weight: bold;
          margin-bottom: 10px;
        }

        .modal-type {
          font-size: 14px;
          margin-bottom: 10px;
        }

        .modal-description {
          font-size: 14px;
          color: #AAAAAA;
          margin-bottom: 10px;
        }

        .modal-rarity {
          display: inline-block;
          padding: 4px 12px;
          border-radius: 12px;
          font-size: 12px;
          font-weight: bold;
          background: rgba(123, 158, 240, 0.3);
        }

        .tab-bar {
          position: absolute;
          bottom: 0;
          left: 0;
          width: 100%;
          height: 60px;
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
          font-family: 'Nunito';
          color: #888888;
        }

        .tab-button.active {
          color: #7B9EF0;
        }

        .tab-button.active .tab-label {
          color: #FFFFFF;
        }

        .tab-button.disabled {
          opacity: 0.4;
          cursor: not-allowed;
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
      `}</style>
    </div>
  );
};

export default CardLibrary;
