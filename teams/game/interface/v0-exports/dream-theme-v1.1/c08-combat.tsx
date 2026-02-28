import React, { useState } from 'react';

const Combat: React.FC = () => {
  const [playerHp] = useState(7);
  const [energy] = useState(2);
  const [enemyHp] = useState(15);
  const hand = [
    { id: 1, name: 'Strike', cost: 1, type: 'Attack' },
    { id: 2, name: 'Defend', cost: 1, type: 'Defense' },
    { id: 3, name: 'Oblivion Strike', cost: 5, type: 'Attack' }
  ];
  return (
    <div className="combat">
      <div className="top-bar"><button>☰</button><div>Turn: 3</div><button className="end-turn">End Turn</button></div>
      <div className="enemy-area"><div className="enemy-card"><div className="enemy-name">Shadow Fiend</div><div className="enemy-hp-bar"><div className="fill" style={{width: \`\${(enemyHp/18)*100}%\`}}></div></div><div className="enemy-hp-text">{enemyHp}/18 HP</div><div className="intent">⚔️ Attack 3</div></div></div>
      <div className="combat-log"><div>• You dealt 10 damage</div><div>• Enemy attacks for 3 damage</div></div>
      <div className="player-area"><div className="player-hp">HP: {playerHp}/10</div><div className="player-energy">EN: {energy}/3</div></div>
      <div className="hand">{hand.map(card => <div key={card.id} className="card"><div className="card-cost">{card.cost}</div><div className="card-name">{card.name}</div><div className="card-icon">{card.type === 'Attack' ? '⚔️' : '🛡'}</div></div>)}</div>
      <style jsx>{\`
        .combat { width: 390px; height: 844px; background: #1A1A2E; font-family: 'Nunito', sans-serif; color: #FFF; }
        .top-bar { height: 50px; display: flex; justify-content: space-between; align-items: center; padding: 0 20px; background: #2C2C3E; }
        .top-bar button { background: none; border: none; color: white; cursor: pointer; font-size: 20px; }
        .end-turn { padding: 8px 16px; border-radius: 8px; background: #5A7FC0; font-family: 'Nunito'; font-weight: bold; font-size: 16px; }
        .enemy-area { height: 180px; display: flex; align-items: center; justify-content: center; padding: 20px; }
        .enemy-card { width: 350px; height: 160px; background: linear-gradient(135deg, #434343 0%, #000 100%); border-radius: 16px; padding: 16px; position: relative; }
        .enemy-name { font-size: 20px; font-weight: bold; margin-bottom: 8px; }
        .enemy-hp-bar { width: 300px; height: 12px; background: #333; border-radius: 6px; overflow: hidden; margin-bottom: 8px; }
        .fill { height: 100%; background: #4CAF50; transition: width 0.3s; }
        .enemy-hp-text { font-size: 16px; font-weight: bold; }
        .intent { position: absolute; top: 16px; right: 16px; font-size: 14px; font-weight: bold; }
        .combat-log { height: 100px; padding: 10px 20px; background: rgba(26,26,46,0.8); overflow-y: auto; font-size: 14px; }
        .combat-log div { margin-bottom: 4px; }
        .player-area { height: 60px; padding: 10px 20px; display: flex; justify-content: space-between; align-items: center; }
        .player-hp, .player-energy { font-size: 14px; font-weight: bold; }
        .hand { height: 150px; padding: 10px 20px; display: flex; gap: 8px; overflow-x: auto; align-items: center; }
        .card { min-width: 72px; height: 101px; background: linear-gradient(135deg, #2196F3 0%, #64B5F6 100%); border-radius: 8px; padding: 6px; display: flex; flex-direction: column; justify-content: space-between; cursor: pointer; position: relative; }
        .card-cost { position: absolute; top: 4px; right: 4px; width: 20px; height: 20px; border-radius: 50%; background: #1A1A2E; display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: bold; }
        .card-name { font-size: 9px; font-weight: bold; text-align: center; margin-top: 16px; }
        .card-icon { font-size: 16px; text-align: center; }
      \`}</style>
    </div>
  );
};
export default Combat;
