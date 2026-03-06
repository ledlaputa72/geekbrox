import React, { useState } from 'react';
import EquipmentDetailModal from './EquipmentDetailModal';

interface Equipment {
  id: string;
  name: string;
  type: 'weapon' | 'armor' | 'ring' | 'necklace';
  level: number;
  tier: 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary';
  icon: string;
  equipped?: boolean;
}

export default function CharacterEquipmentTab() {
  const [selectedEquipment, setSelectedEquipment] = useState<Equipment | null>(null);

  // 착용 장비 슬롯 (6개: 무기, 방어구, 반지×2, 목걸이×2)
  const equippedSlots = [
    { id: 'weapon', name: '무기', type: 'weapon', slot: 0, equipped: { id: 'sword-001', name: '마법 검', level: 20, tier: 'rare', icon: '⚔️' } },
    { id: 'ring-1', name: '반지 1', type: 'ring', slot: 1, equipped: { id: 'ring-001', name: '힘의 반지', level: 15, tier: 'uncommon', icon: '💍' } },
    { id: 'armor', name: '방어구', type: 'armor', slot: 2, equipped: { id: 'armor-001', name: '드래곤 갑옷', level: 18, tier: 'rare', icon: '🛡️' } },
    { id: 'ring-2', name: '반지 2', type: 'ring', slot: 3, equipped: null },
    { id: 'necklace-1', name: '목걸이 1', type: 'necklace', slot: 4, equipped: { id: 'neck-001', name: '마나 목걸이', level: 20, tier: 'rare', icon: '✨' } },
    { id: 'necklace-2', name: '목걸이 2', type: 'necklace', slot: 5, equipped: null },
  ];

  // 보유 장비 목록 (스크롤 가능)
  const inventory = [
    { id: 'sword-001', name: '마법 검', type: 'weapon', level: 20, tier: 'rare', icon: '⚔️', equipped: true },
    { id: 'sword-002', name: '철 검', type: 'weapon', level: 15, tier: 'common', icon: '🗡️', equipped: false },
    { id: 'armor-001', name: '드래곤 갑옷', type: 'armor', level: 18, tier: 'rare', icon: '🛡️', equipped: true },
    { id: 'armor-002', name: '가죽 갑옷', type: 'armor', level: 10, tier: 'uncommon', icon: '🧥', equipped: false },
    { id: 'ring-001', name: '힘의 반지', type: 'ring', level: 15, tier: 'uncommon', icon: '💍', equipped: true },
    { id: 'ring-002', name: '현명함 반지', type: 'ring', level: 12, tier: 'common', icon: '💎', equipped: false },
    { id: 'ring-003', name: '속도 반지', type: 'ring', level: 16, tier: 'rare', icon: '⚡', equipped: false },
    { id: 'neck-001', name: '마나 목걸이', type: 'necklace', level: 20, tier: 'rare', icon: '✨', equipped: true },
    { id: 'neck-002', name: '생명 목걸이', type: 'necklace', level: 14, tier: 'uncommon', icon: '💚', equipped: false },
    { id: 'neck-003', name: '골드 목걸이', type: 'necklace', level: 11, tier: 'common', icon: '⭐', equipped: false },
    { id: 'sword-003', name: '불의 검', type: 'weapon', level: 13, tier: 'uncommon', icon: '🔥', equipped: false },
    { id: 'armor-003', name: '얼음 갑옷', type: 'armor', level: 12, tier: 'uncommon', icon: '❄️', equipped: false },
  ];

  // 티어별 색상 매핑
  const tierColors = {
    common: { bg: 'bg-gray-600', border: 'border-gray-500' },
    uncommon: { bg: 'bg-green-600', border: 'border-green-500' },
    rare: { bg: 'bg-blue-600', border: 'border-blue-500' },
    epic: { bg: 'bg-purple-600', border: 'border-purple-500' },
    legendary: { bg: 'bg-yellow-600', border: 'border-yellow-500' },
  };

  const typeIcon = {
    weapon: '⚔️',
    armor: '🛡️',
    ring: '💍',
    necklace: '✨',
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-900 via-slate-800 to-slate-900 text-white flex flex-col pb-24">
      {/* 상단 자원 표시바 */}
      <div className="bg-red-600 px-4 py-2 flex justify-between items-center text-sm font-bold">
        <div className="flex items-center gap-4">
          <span className="text-lg">⚙️</span>
          <span className="flex items-center gap-1">
            💎 <span>5</span>
          </span>
          <span className="flex items-center gap-1">
            🪙 <span>5</span>
          </span>
          <span className="flex items-center gap-1">
            ⚡ <span>5/10</span>
          </span>
        </div>
      </div>

      {/* 메인 콘텐츠 */}
      <div className="flex-1 px-4 py-4">
        {/* 캐릭터 정보 영역 */}
        <div className="bg-slate-700/50 rounded-lg border-2 border-blue-500 p-4 mb-4">
          {/* 캐릭터 + 장비 슬롯 배치 */}
          <div className="flex justify-between items-start gap-4">
            {/* 왼쪽 슬롯 (무기, 반지1) */}
            <div className="flex flex-col gap-2">
              {equippedSlots.slice(0, 2).map((slot) => (
                <button
                  key={slot.id}
                  onClick={() => slot.equipped && setSelectedEquipment(slot.equipped)}
                  className={`w-20 h-20 rounded border-2 flex flex-col items-center justify-center cursor-pointer transition font-bold text-sm ${
                    slot.equipped
                      ? `${tierColors[slot.equipped.tier].bg} ${tierColors[slot.equipped.tier].border}`
                      : 'bg-slate-600 border-slate-500 text-slate-400'
                  }`}
                >
                  {slot.equipped ? (
                    <>
                      <div className="text-2xl">{slot.equipped.icon}</div>
                      <div className="text-xs text-slate-200">LV.{slot.equipped.level}</div>
                    </>
                  ) : (
                    <div className="text-xs text-center">+</div>
                  )}
                </button>
              ))}
            </div>

            {/* 중앙 캐릭터 */}
            <div className="flex-1 flex flex-col items-center">
              {/* Level 배지 */}
              <div className="mb-2 bg-orange-500 text-white px-3 py-1 rounded-full text-xs font-bold">
                LV 20
              </div>

              {/* 캐릭터 스프라이트 (큼) */}
              <div className="w-32 h-40 bg-slate-600 rounded-lg border-2 border-purple-500 flex items-center justify-center text-6xl mb-4">
                🧑‍🎨
              </div>

              {/* 캐릭터 ID/이름 */}
              <div className="text-center text-xs text-gray-300 mb-2">4935</div>

              {/* 스탯 표시 */}
              <div className="flex gap-4 w-full justify-center">
                <div className="text-center">
                  <div className="text-lg">❤️</div>
                  <div className="text-xs text-gray-400">906</div>
                </div>
                <div className="text-center">
                  <div className="text-lg">⚔️</div>
                  <div className="text-xs text-gray-400">390</div>
                </div>
                <div className="text-center">
                  <div className="text-lg">🛡️</div>
                  <div className="text-xs text-gray-400">63</div>
                </div>
                <div className="text-center">
                  <div className="text-lg">📋</div>
                  <div className="text-xs text-gray-400">?</div>
                </div>
              </div>
            </div>

            {/* 오른쪽 슬롯 (방어구, 반지2) */}
            <div className="flex flex-col gap-2">
              {equippedSlots.slice(2, 4).map((slot) => (
                <button
                  key={slot.id}
                  onClick={() => slot.equipped && setSelectedEquipment(slot.equipped)}
                  className={`w-20 h-20 rounded border-2 flex flex-col items-center justify-center cursor-pointer transition font-bold text-sm ${
                    slot.equipped
                      ? `${tierColors[slot.equipped.tier].bg} ${tierColors[slot.equipped.tier].border}`
                      : 'bg-slate-600 border-slate-500 text-slate-400'
                  }`}
                >
                  {slot.equipped ? (
                    <>
                      <div className="text-2xl">{slot.equipped.icon}</div>
                      <div className="text-xs text-slate-200">LV.{slot.equipped.level}</div>
                    </>
                  ) : (
                    <div className="text-xs text-center">+</div>
                  )}
                </button>
              ))}
            </div>
          </div>

          {/* 목걸이 슬롯 (아래) */}
          <div className="flex gap-2 justify-center mt-4">
            {equippedSlots.slice(4, 6).map((slot) => (
              <button
                key={slot.id}
                onClick={() => slot.equipped && setSelectedEquipment(slot.equipped)}
                className={`w-20 h-20 rounded border-2 flex flex-col items-center justify-center cursor-pointer transition font-bold text-sm ${
                  slot.equipped
                    ? `${tierColors[slot.equipped.tier].bg} ${tierColors[slot.equipped.tier].border}`
                    : 'bg-slate-600 border-slate-500 text-slate-400'
                }`}
              >
                {slot.equipped ? (
                  <>
                    <div className="text-2xl">{slot.equipped.icon}</div>
                    <div className="text-xs text-slate-200">LV.{slot.equipped.level}</div>
                  </>
                ) : (
                  <div className="text-xs text-center">+</div>
                )}
              </button>
            ))}
          </div>
        </div>

        {/* 보유 장비 (그리드) */}
        <div className="bg-slate-800 rounded-lg border-2 border-slate-600 p-3">
          <div className="grid grid-cols-5 gap-2 auto-rows-max max-h-96 overflow-y-auto">
            {inventory.map((item) => (
              <button
                key={item.id}
                onClick={() => setSelectedEquipment(item)}
                className={`w-full aspect-square rounded border-2 flex flex-col items-center justify-center cursor-pointer transition relative ${
                  tierColors[item.tier].bg
                } ${tierColors[item.tier].border} hover:opacity-80`}
              >
                {/* 레벨 배지 (좌상단) */}
                <div className="absolute top-1 left-1 bg-slate-900 text-white text-xs px-1 rounded font-bold">
                  LV.{item.level}
                </div>

                {/* 아이콘 (중앙) */}
                <div className="text-2xl">{item.icon}</div>

                {/* 착용 표시 (우상단) */}
                {item.equipped && (
                  <div className="absolute top-1 right-1 text-xs bg-green-500 text-white px-1 rounded font-bold">
                    착
                  </div>
                )}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* 하단 네비게이션 */}
      <div className="fixed bottom-0 left-0 right-0 bg-slate-900 border-t border-slate-700 px-4 py-2 flex justify-around">
        <button className="flex flex-col items-center gap-1 text-gray-400 hover:text-white text-xs">
          <span className="text-xl">🏠</span>
          <span>홈</span>
        </button>
        <button className="flex flex-col items-center gap-1 text-gray-400 hover:text-white text-xs">
          <span className="text-xl">🎴</span>
          <span>카드</span>
        </button>
        <button className="flex flex-col items-center gap-1 text-gray-400 hover:text-white text-xs">
          <span className="text-xl">⬆️</span>
          <span>업그레이드</span>
        </button>
        <button className="flex flex-col items-center gap-1 text-yellow-400 hover:text-yellow-300 text-xs font-bold">
          <span className="text-xl">👤</span>
          <span>캐릭터</span>
        </button>
        <button className="flex flex-col items-center gap-1 text-gray-400 hover:text-white text-xs">
          <span className="text-xl">🏪</span>
          <span>상점</span>
        </button>
      </div>

      {/* 장비 상세 모달 */}
      <EquipmentDetailModal
        equipment={selectedEquipment}
        onClose={() => setSelectedEquipment(null)}
        onEquip={(equipment) => {
          console.log(`${equipment.name} 장착됨`);
        }}
      />
    </div>
  );
}
