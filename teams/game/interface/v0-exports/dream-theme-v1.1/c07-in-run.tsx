import React, { useState } from 'react';

const InRun: React.FC = () => {
  const [hp] = useState(6);
  const [maxHp] = useState(10);
  const [energy] = useState(2);
  const [reveries] = useState(125);
  return (
    <div className="in-run">
      <div className="status-bar">
        <div className="hp-bar"><div className="hp-fill" style={{width: \`\${(hp/maxHp)*100}%\`}}></div><div className="hp-text">HP: {hp}/{maxHp}</div></div>
        <div className="energy-text">EN: {energy}/3</div>
        <div className="reveries-text">R: {reveries}</div>
      </div>
      <div className="node-map">{[...Array(10)].map((_, i) => <div key={i} className={\`node \${i === 2 ? 'current' : i < 2 ? 'completed' : ''}\`}>{i === 2 ? '❓' : i < 2 ? '✓' : '○'}</div>)}</div>
      <div className="main-view"><div className="node-icon">❓</div></div>
      <div className="info-panel"><div className="panel-title">Current Node: Event ❓</div><div className="panel-desc">"Two paths diverge..."</div><button className="choice-button">[A] Safe path (20 R)</button><button className="choice-button">[B] Risky path (50% 50R)</button></div>
      <div className="action-bar"><button>⏩ Skip</button><button>🤖 Auto</button><button>☰ Menu</button></div>
      <style jsx>{\`
        .in-run { width: 390px; height: 844px; background: linear-gradient(180deg, #1A1A2E 0%, #2C3E50 100%); font-family: 'Nunito', sans-serif; color: #FFF; position: relative; }
        .status-bar { height: 50px; display: flex; justify-content: space-between; align-items: center; padding: 0 20px; background: rgba(26,26,46,0.9); }
        .hp-bar { width: 140px; height: 20px; background: #333; border-radius: 10px; position: relative; overflow: hidden; }
        .hp-fill { height: 100%; background: #4CAF50; transition: width 0.3s; }
        .hp-text { position: absolute; top: 0; left: 0; width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: bold; }
        .energy-text, .reveries-text { font-size: 14px; font-weight: bold; }
        .reveries-text { color: #FFD700; }
        .node-map { height: 80px; display: flex; justify-content: center; align-items: center; gap: 8px; padding: 0 20px; }
        .node { width: 24px; height: 24px; border-radius: 50%; background: #666; display: flex; align-items: center; justify-content: center; font-size: 12px; }
        .node.completed { background: #4CAF50; }
        .node.current { background: #7B9EF0; border: 3px solid white; animation: pulse 2s infinite; }
        @keyframes pulse { 0%, 100% { transform: scale(1); } 50% { transform: scale(1.1); } }
        .main-view { height: 400px; display: flex; align-items: center; justify-content: center; }
        .node-icon { font-size: 96px; animation: float 3s ease-in-out infinite; }
        @keyframes float { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-10px); } }
        .info-panel { position: absolute; bottom: 60px; left: 0; width: 100%; height: 200px; background: rgba(44,44,62,0.95); border-radius: 16px 16px 0 0; padding: 20px; box-shadow: 0 -4px 8px rgba(0,0,0,0.3); }
        .panel-title { font-size: 20px; font-weight: bold; margin-bottom: 12px; }
        .panel-desc { font-size: 14px; color: #AAA; margin-bottom: 16px; }
        .choice-button { width: 100%; height: 44px; border-radius: 8px; border: none; background: #5A7FC0; color: white; font-family: 'Nunito'; font-weight: bold; margin-bottom: 12px; cursor: pointer; text-align: left; padding: 0 16px; }
        .action-bar { position: absolute; bottom: 0; left: 0; width: 100%; height: 60px; display: flex; justify-content: space-around; align-items: center; background: rgba(26,26,46,0.9); }
        .action-bar button { width: 100px; height: 44px; border-radius: 8px; border: none; background: #5A7FC0; color: white; font-family: 'Nunito'; font-weight: bold; cursor: pointer; }
      \`}</style>
    </div>
  );
};
export default InRun;
