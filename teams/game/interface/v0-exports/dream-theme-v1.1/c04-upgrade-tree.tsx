import React, { useState } from 'react';

interface Upgrade {
  id: number;
  name: string;
  cost: number;
  effect: string;
  icon: string;
  row: number;
  col: number;
  requires: number[];
}

const upgrades: Upgrade[] = [
  { id: 1, name: 'Enhanced Starting Deck', cost: 3, effect: 'Start with 1 Rare card', icon: '🎴', row: 0, col: 0, requires: [] },
  { id: 2, name: 'Energy Boost', cost: 5, effect: '+1 max energy', icon: '⚡', row: 0, col: 2, requires: [1] },
  { id: 3, name: 'HP Recovery', cost: 4, effect: '+2 starting HP', icon: '❤️', row: 0, col: 4, requires: [2] },
  { id: 4, name: 'Card Draw', cost: 7, effect: 'Draw 1 extra card at turn start', icon: '🎯', row: 1, col: 1, requires: [1, 2] },
  { id: 5, name: 'Reveries Boost', cost: 6, effect: '+20% Reveries earned', icon: '💎', row: 1, col: 3, requires: [2, 3] },
  { id: 6, name: 'Dream Mastery', cost: 10, effect: 'All cards cost 1 less', icon: '✨', row: 2, col: 2, requires: [4, 5] }
];

const UpgradeTree: React.FC = () => {
  const [dreamShards, setDreamShards] = useState(12);
  const [unlockedUpgrades, setUnlockedUpgrades] = useState<number[]>([]);
  const [selectedUpgrade, setSelectedUpgrade] = useState<Upgrade>(upgrades[0]);

  const isUnlocked = (id: number) => unlockedUpgrades.includes(id);
  
  const canUnlock = (upgrade: Upgrade) => {
    if (isUnlocked(upgrade.id)) return false;
    if (dreamShards < upgrade.cost) return false;
    if (upgrade.requires.length === 0) return true;
    return upgrade.requires.every(reqId => isUnlocked(reqId));
  };

  const unlockUpgrade = () => {
    if (canUnlock(selectedUpgrade)) {
      setDreamShards(dreamShards - selectedUpgrade.cost);
      setUnlockedUpgrades([...unlockedUpgrades, selectedUpgrade.id]);
    }
  };

  const getNodeStatus = (upgrade: Upgrade) => {
    if (isUnlocked(upgrade.id)) return 'unlocked';
    if (canUnlock(upgrade)) return 'unlockable';
    return 'locked';
  };

  const getNodeColor = (status: string) => {
    if (status === 'unlocked') return '#4CAF50';
    if (status === 'unlockable') return '#7B9EF0';
    return '#333333';
  };

  return (
    <div className="upgrade-tree">
      <div className="header">
        <button className="back-button">←</button>
        <div className="title">Upgrade Tree</div>
        <div className="dream-shards">Dream Shards: {dreamShards}</div>
      </div>

      <div className="tree-visual">
        <svg width="310" height="400" style={{ position: 'absolute', top: 40, left: 40 }}>
          {upgrades.map(upgrade => 
            upgrade.requires.map(reqId => {
              const fromNode = upgrades.find(u => u.id === reqId);
              if (!fromNode) return null;
              const toNode = upgrade;
              const fromStatus = getNodeStatus(fromNode);
              const toStatus = getNodeStatus(toNode);
              const lineColor = (fromStatus === 'unlocked' && toStatus !== 'locked') ? '#7B9EF0' : '#555555';
              const isDashed = toStatus === 'locked';
              
              return (
                <line
                  key={`${reqId}-${upgrade.id}`}
                  x1={fromNode.col * 70 + 25}
                  y1={fromNode.row * 120 + 25}
                  x2={toNode.col * 70 + 25}
                  y2={toNode.row * 120 + 25}
                  stroke={lineColor}
                  strokeWidth="2"
                  strokeDasharray={isDashed ? "5,5" : "0"}
                />
              );
            })
          )}
        </svg>

        {upgrades.map(upgrade => {
          const status = getNodeStatus(upgrade);
          const color = getNodeColor(status);
          const isSelected = selectedUpgrade?.id === upgrade.id;
          
          return (
            <div
              key={upgrade.id}
              onClick={() => setSelectedUpgrade(upgrade)}
              className="node"
              style={{
                left: upgrade.col * 70 + 40,
                top: upgrade.row * 120 + 40,
                background: color,
                border: `3px solid ${isSelected ? '#FFD700' : color}`,
                boxShadow: isSelected ? '0 0 20px rgba(255,215,0,0.6)' : '0 2px 4px rgba(0,0,0,0.3)',
                animation: status === 'unlockable' ? 'pulse 2s infinite' : 'none'
              }}
            >
              {status === 'unlocked' ? '✓' : upgrade.icon}
            </div>
          );
        })}
      </div>

      {selectedUpgrade && (
        <div className="info-panel">
          <div className="upgrade-name">{selectedUpgrade.name}</div>
          <div className="upgrade-cost">Cost: {selectedUpgrade.cost} Dream Shards</div>
          <div className="upgrade-effect">{selectedUpgrade.effect}</div>
          <button
            onClick={unlockUpgrade}
            disabled={!canUnlock(selectedUpgrade)}
            className={`unlock-button ${canUnlock(selectedUpgrade) ? 'active' : 'inactive'}`}
          >
            {isUnlocked(selectedUpgrade.id) ? 'Unlocked' :
             canUnlock(selectedUpgrade) ? 'Unlock' : 
             dreamShards < selectedUpgrade.cost ? 'Shards Insufficient' : 'Requirements Not Met'}
          </button>
        </div>
      )}

      <div className="tab-bar">
        <button className="tab-button"><div className="tab-icon">🏠</div><div className="tab-label">Home</div></button>
        <button className="tab-button"><div className="tab-icon">🎴</div><div className="tab-label">Cards</div></button>
        <button className="tab-button active"><div className="tab-icon">⬆️</div><div className="tab-label">Upgrade</div></button>
        <button className="tab-button disabled"><div className="tab-icon">📊</div><div className="tab-label">Progress</div></button>
        <button className="tab-button"><div className="tab-icon">🛒</div><div className="tab-label">Shop</div></button>
      </div>

      <style jsx>{`
        @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.6; } }
        .upgrade-tree { width: 390px; height: 844px; background: #1A1A2E; font-family: 'Nunito', sans-serif; color: #FFF; position: relative; overflow: hidden; }
        .header { height: 60px; display: flex; justify-content: space-between; align-items: center; padding: 0 20px; background: #2C2C3E; }
        .back-button { font-size: 24px; background: none; border: none; color: white; cursor: pointer; }
        .title { font-size: 18px; font-weight: bold; }
        .dream-shards { font-size: 16px; font-weight: bold; color: #00CED1; }
        .tree-visual { height: calc(844px - 60px - 140px - 60px); padding: 40px; position: relative; overflow-y: auto; }
        .node { position: absolute; width: 50px; height: 50px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 24px; cursor: pointer; }
        .info-panel { position: absolute; bottom: 60px; left: 0; width: 100%; height: 140px; background: #2C2C3E; border-radius: 16px 16px 0 0; padding: 20px; box-shadow: 0 -4px 8px rgba(0,0,0,0.3); }
        .upgrade-name { font-size: 18px; font-weight: bold; margin-bottom: 8px; }
        .upgrade-cost { font-size: 14px; font-weight: bold; color: #00CED1; margin-bottom: 8px; }
        .upgrade-effect { font-size: 14px; color: #AAA; margin-bottom: 12px; }
        .unlock-button { width: 100%; height: 44px; border-radius: 8px; border: none; font-family: 'Nunito'; font-weight: bold; font-size: 16px; cursor: pointer; }
        .unlock-button.active { background: #7B9EF0; color: white; }
        .unlock-button.inactive { background: #555; color: white; cursor: not-allowed; }
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

export default UpgradeTree;
