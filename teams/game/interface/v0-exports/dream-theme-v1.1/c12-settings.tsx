import React, { useState } from 'react';

const Settings: React.FC = () => {
  const [masterVolume, setMasterVolume] = useState(80);
  const [musicVolume, setMusicVolume] = useState(70);
  const [sfxVolume, setSfxVolume] = useState(60);
  const [particleEffects, setParticleEffects] = useState(true);
  const [screenShake, setScreenShake] = useState(true);
  const [language, setLanguage] = useState('EN');

  return (
    <div className="settings">
      <div className="header">
        <button className="back-button">←</button>
        <div className="title">Settings</div>
        <div></div>
      </div>
      <div className="content">
        <div className="section">
          <div className="section-title">🔊 Audio</div>
          <div className="slider-group">
            <div className="slider-label">Master Volume <span>{masterVolume}%</span></div>
            <input type="range" min="0" max="100" value={masterVolume} onChange={(e) => setMasterVolume(Number(e.target.value))} />
          </div>
          <div className="slider-group">
            <div className="slider-label">Music Volume <span>{musicVolume}%</span></div>
            <input type="range" min="0" max="100" value={musicVolume} onChange={(e) => setMusicVolume(Number(e.target.value))} />
          </div>
          <div className="slider-group">
            <div className="slider-label">SFX Volume <span>{sfxVolume}%</span></div>
            <input type="range" min="0" max="100" value={sfxVolume} onChange={(e) => setSfxVolume(Number(e.target.value))} />
          </div>
        </div>
        <div className="section">
          <div className="section-title">🎨 Display</div>
          <div className="toggle-group">
            <span>Particle Effects</span>
            <button className={\`toggle \${particleEffects ? 'on' : 'off'}\`} onClick={() => setParticleEffects(!particleEffects)}>
              <div className="toggle-thumb" />
            </button>
          </div>
          <div className="toggle-group">
            <span>Screen Shake</span>
            <button className={\`toggle \${screenShake ? 'on' : 'off'}\`} onClick={() => setScreenShake(!screenShake)}>
              <div className="toggle-thumb" />
            </button>
          </div>
        </div>
        <div className="section">
          <div className="section-title">🌐 Language</div>
          <div className="language-buttons">
            <button className={language === 'EN' ? 'active' : ''} onClick={() => setLanguage('EN')}>English</button>
            <button className={language === 'KR' ? 'active' : ''} onClick={() => setLanguage('KR')}>한국어</button>
          </div>
        </div>
      </div>
      <style jsx>{\`
        .settings { width: 390px; height: 844px; background: #1A1A2E; font-family: 'Nunito', sans-serif; color: #FFF; overflow: hidden; }
        .header { height: 60px; display: flex; justify-content: space-between; align-items: center; padding: 0 20px; background: #2C2C3E; }
        .back-button { font-size: 24px; background: none; border: none; color: white; cursor: pointer; }
        .title { font-size: 18px; font-weight: bold; }
        .content { height: calc(844px - 60px); overflow-y: auto; padding: 20px; }
        .section { background: #2C2C3E; border-radius: 16px; padding: 20px; margin-bottom: 20px; }
        .section-title { font-size: 18px; font-weight: bold; margin-bottom: 20px; }
        .slider-group { margin-bottom: 20px; }
        .slider-label { display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 14px; }
        .slider-label span { color: #7B9EF0; font-weight: bold; }
        input[type="range"] { width: 100%; height: 8px; border-radius: 4px; background: #555; outline: none; }
        .toggle-group { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
        .toggle { width: 56px; height: 32px; border-radius: 16px; border: none; position: relative; cursor: pointer; transition: background 0.3s; }
        .toggle.on { background: #4CAF50; }
        .toggle.off { background: #555; }
        .toggle-thumb { width: 24px; height: 24px; border-radius: 50%; background: white; position: absolute; top: 4px; transition: left 0.3s; box-shadow: 0 2px 4px rgba(0,0,0,0.3); }
        .toggle.on .toggle-thumb { left: 28px; }
        .toggle.off .toggle-thumb { left: 4px; }
        .language-buttons { display: flex; gap: 12px; }
        .language-buttons button { flex: 1; height: 44px; border-radius: 8px; border: none; font-family: 'Nunito'; font-weight: bold; cursor: pointer; background: #1A1A2E; color: white; }
        .language-buttons button.active { background: #7B9EF0; border: 2px solid #7B9EF0; }
      \`}</style>
    </div>
  );
};

export default Settings;
