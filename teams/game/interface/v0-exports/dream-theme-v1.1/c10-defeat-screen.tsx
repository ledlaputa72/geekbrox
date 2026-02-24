import React from 'react';

const DefeatScreen: React.FC = () => {
  return (
    <div className="defeat-screen">
      <div className="defeat-title"><div className="emoji">💀</div><div className="title">DEFEAT</div><div className="subtitle">The Dream Has Ended</div></div>
      <div className="cause-panel"><div className="label">Defeated by:</div><div className="enemy">Shadow Fiend</div><div className="blow">Enemy dealt 5 damage (HP: 0/10)</div></div>
      <div className="stats-box"><div className="stat"><div className="value">6/10</div><div className="label">Nodes</div></div><div className="stat"><div className="value">18</div><div className="label">Turns</div></div></div>
      <button className="retry-button">🔄 Retry (Same Setup)</button>
      <button className="lobby-button">Return to Main Lobby</button>
      <style jsx>{\`
        .defeat-screen { width: 390px; height: 844px; background: linear-gradient(180deg, #1A1A2E 0%, #1C1C2E 100%); font-family: 'Nunito', sans-serif; color: #FFF; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 20px; }
        .defeat-title { text-align: center; margin-bottom: 30px; }
        .emoji { font-size: 64px; opacity: 0.8; margin-bottom: 16px; }
        .title { font-size: 36px; font-weight: bold; color: #F44336; margin-bottom: 12px; }
        .subtitle { font-size: 16px; color: #AAA; }
        .cause-panel { width: 100%; background: #2C2C3E; border: 2px solid #F44336; border-radius: 16px; padding: 20px; margin-bottom: 20px; }
        .label { font-size: 14px; color: #AAA; margin-bottom: 8px; }
        .enemy { font-size: 24px; font-weight: bold; color: #F44336; margin-bottom: 12px; }
        .blow { font-size: 12px; background: #1A1A2E; padding: 12px; border-radius: 8px; font-family: monospace; }
        .stats-box { width: 100%; background: #2C2C3E; border-radius: 16px; padding: 20px; margin-bottom: 30px; display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; }
        .stat { text-align: center; }
        .value { font-size: 32px; font-weight: bold; color: #7B9EF0; }
        .retry-button { width: 100%; height: 56px; border-radius: 16px; border: none; background: linear-gradient(135deg, #F44336 0%, #E91E63 100%); color: white; font-family: 'Nunito'; font-weight: bold; font-size: 18px; margin-bottom: 12px; cursor: pointer; box-shadow: 0 8px 16px rgba(244,67,54,0.3); }
        .lobby-button { width: 100%; height: 48px; border-radius: 12px; border: none; background: #5A7FC0; color: white; font-family: 'Nunito'; font-weight: bold; cursor: pointer; }
      \`}</style>
    </div>
  );
};
export default DefeatScreen;
