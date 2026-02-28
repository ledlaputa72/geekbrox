import React, { useState } from 'react';

const products = {
  'Daily Deal': [{ id: 1, name: 'Legendary Card', icon: '💎', desc: '1 random Legendary card', price: 250, originalPrice: 500, badge: 'LIMITED' }],
  'Cards': [
    { id: 2, name: 'Rare Card Pack', icon: '🎴', desc: '5 random Rare cards', price: 100 },
    { id: 3, name: 'Epic Card Pack', icon: '✨', desc: '3 random Epic cards', price: 300 }
  ],
  'Energy': [
    { id: 6, name: 'Energy Refill', icon: '⚡', desc: 'Restore 100% energy', price: 50 }
  ]
};

const Shop: React.FC = () => {
  const [reveries, setReveries] = useState(1234);
  const [activeTab, setActiveTab] = useState('Daily Deal');
  const [purchasedItems, setPurchasedItems] = useState<number[]>([]);

  return (
    <div className="shop">
      <div className="header">
        <button className="back-button">←</button>
        <div className="title">Shop</div>
        <div className="reveries">Reveries: {reveries}</div>
      </div>
      <div className="tab-bar-top">
        {Object.keys(products).map(tab => (
          <button key={tab} onClick={() => setActiveTab(tab)} className={activeTab === tab ? 'active' : ''}>{tab}</button>
        ))}
      </div>
      <div className="product-grid">
        {products[activeTab as keyof typeof products].map(product => (
          <div key={product.id} className="product-card">
            <div className="product-icon">{product.icon}</div>
            <div className="product-name">{product.name}</div>
            <div className="product-desc">{product.desc}</div>
            <div className="product-price">{product.price} R</div>
            <button className="buy-button">Buy</button>
          </div>
        ))}
      </div>
      <style jsx>{\`
        .shop { width: 390px; height: 844px; background: #1A1A2E; font-family: 'Nunito', sans-serif; color: #FFF; }
        .header { height: 60px; display: flex; justify-content: space-between; align-items: center; padding: 0 20px; background: #2C2C3E; }
        .back-button { font-size: 24px; background: none; border: none; color: white; cursor: pointer; }
        .title { font-size: 18px; font-weight: bold; }
        .reveries { font-size: 16px; font-weight: bold; color: #FFD700; }
        .tab-bar-top { height: 50px; display: flex; background: #2C2C3E; }
        .tab-bar-top button { flex: 1; background: none; border: none; color: #666; font-family: 'Nunito'; font-weight: bold; cursor: pointer; }
        .tab-bar-top button.active { color: #7B9EF0; border-bottom: 4px solid #7B9EF0; }
        .product-grid { height: calc(844px - 110px); overflow-y: auto; padding: 20px; display: grid; grid-template-columns: repeat(2, 1fr); gap: 12px; }
        .product-card { background: #2C2C3E; border-radius: 16px; padding: 16px; text-align: center; }
        .product-icon { font-size: 48px; margin-bottom: 12px; }
        .product-name { font-size: 16px; font-weight: bold; margin-bottom: 8px; }
        .product-desc { font-size: 12px; color: #AAA; margin-bottom: 12px; }
        .product-price { font-size: 18px; font-weight: bold; color: #FFD700; margin-bottom: 12px; }
        .buy-button { width: 100%; height: 40px; border-radius: 8px; border: none; background: #5A7FC0; color: white; font-family: 'Nunito'; font-weight: bold; cursor: pointer; }
      \`}</style>
    </div>
  );
};

export default Shop;
