import React, { useState } from 'react';

const dreamers = [
  { id: 1, name: 'Serenity', difficulty: 'Easy', icon: '😌', hp: 10, reward: '+20% Reveries', gradient: 'linear-gradient(135deg, #4CAF50 0%, #81C784 100%)' },
  { id: 2, name: 'Anxiety', difficulty: 'Normal', icon: '😰', hp: 8, reward: '+0% Reveries', gradient: 'linear-gradient(135deg, #FFC107 0%, #FFD54F 100%)' },
  { id: 3, name: 'Fear', difficulty: 'Hard', icon: '😱', hp: 6, reward: '+50% Card drops', gradient: 'linear-gradient(135deg, #F44336 0%, #E57373 100%)' }
];

const RunPrep: React.FC = () => {
  const [selectedDreamer, setSelectedDreamer] = useState(dreamers[1]);
  return (
    <div className="run-prep">
      <div className="header"><button className="back-button">←</button><div className="title">Run Preparation</div></div>
      <div className="section-title">Select Dreamer:</div>
      <div className="dreamer-selection">
        {dreamers.map(d => (
          <div key={d.id} onClick={() => setSelectedDreamer(d)} className={\`dreamer-card \${selectedDreamer.id === d.id ? 'selected' : ''}\`} style={{background: d.gradient}}>
            <div className="dreamer-name">{d.name}</div>
            <div className="dreamer-icon">{d.icon}</div>
            <div className="dreamer-hp">{d.hp} HP</div>
          </div>
        ))}
      </div>
      <button className="start-button">🚀 Start Run</button>
      <style jsx>{\`
        .run-prep { width: 390px; height: 844px; background: #1A1A2E; font-family: 'Nunito', sans-serif; color: #FFF; padding: 20px; }
        .header { height: 60px; display: flex; align-items: center; gap: 20px; background: #2C2C3E; margin: -20px -20px 20px; padding: 0 20px; }
        .back-button { font-size: 24px; background: none; border: none; color: white; cursor: pointer; }
        .title { font-size: 18px; font-weight: bold; }
        .section-title { font-size: 16px; font-weight: bold; margin-bottom: 20px; }
        .dreamer-selection { display: flex; gap: 16px; margin-bottom: 30px; overflow-x: auto; }
        .dreamer-card { min-width: 140px; height: 180px; border-radius: 16px; padding: 16px; display: flex; flex-direction: column; align-items: center; justify-content: space-between; cursor: pointer; transition: all 0.3s; opacity: 0.7; }
        .dreamer-card.selected { border: 4px solid #7B9EF0; box-shadow: 0 0 16px rgba(123,158,240,0.6); opacity: 1; transform: scale(1.05); }
        .dreamer-name { font-size: 16px; font-weight: bold; }
        .dreamer-icon { font-size: 48px; }
        .dreamer-hp { font-size: 18px; font-weight: bold; }
        .start-button { width: 100%; height: 60px; border-radius: 16px; border: none; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; font-family: 'Nunito'; font-weight: bold; font-size: 20px; cursor: pointer; box-shadow: 0 8px 16px rgba(102,126,234,0.5); }
      \`}</style>
    </div>
  );
};
export default RunPrep;
