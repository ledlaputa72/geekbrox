import React, { useState } from 'react';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import EquipmentDetailModal from './EquipmentDetailModal';

export default function CharacterEquipmentTab() {
  const [selectedEquipment, setSelectedEquipment] = useState(null);

  // 착용 장비 슬롯 (6개: 무기, 방어구, 반지×2, 목걸이×2)
  const equippedSlots = [
    { id: 'weapon', name: '무기', type: 'weapon', equipped: { id: 'sword-001', name: '마법 검', level: 20, tier: 'rare', icon: '⚔️' } },
    { id: 'armor', name: '방어구', type: 'armor', equipped: { id: 'armor-001', name: '드래곤 갑옷', level: 18, tier: 'rare', icon: '🛡️' } },
    { id: 'ring-1', name: '반지 1', type: 'ring', equipped: { id: 'ring-001', name: '힘의 반지', level: 15, tier: 'uncommon', icon: '💍' } },
    { id: 'ring-2', name: '반지 2', type: 'ring', equipped: null },
    { id: 'necklace-1', name: '목걸이 1', type: 'necklace', equipped: { id: 'neck-001', name: '마나 목걸이', level: 20, tier: 'rare', icon: '✨' } },
    { id: 'necklace-2', name: '목걸이 2', type: 'necklace', equipped: null },
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
  ];

  // 티어별 색상 매핑
  const tierColors = {
    common: 'border-gray-500 bg-gray-900',
    uncommon: 'border-green-500 bg-green-900/30',
    rare: 'border-blue-500 bg-blue-900/30',
    epic: 'border-purple-500 bg-purple-900/30',
    legendary: 'border-orange-500 bg-orange-900/30',
  };

  // 장비 종류 한글명
  const typeNames = {
    weapon: '무기',
    armor: '방어구',
    ring: '반지',
    necklace: '목걸이',
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-900 via-slate-800 to-slate-900 text-white p-4">
      {/* 헤더 */}
      <div className="mb-6">
        <h1 className="text-2xl font-bold">캐릭터</h1>
      </div>

      {/* 캐릭터 정보 영역 */}
      <div className="bg-slate-700/50 rounded-lg border border-slate-600 p-6 mb-6">
        {/* 캐릭터 스프라이트 영역 */}
        <div className="flex flex-col items-center mb-6">
          {/* Level 배지 */}
          <div className="mb-3 bg-orange-500 text-white px-3 py-1 rounded-full text-sm font-bold">
            LV 20
          </div>

          {/* 캐릭터 스프라이트 (플레이스홀더) */}
          <div className="w-24 h-32 bg-slate-600 rounded-lg border-2 border-purple-500 flex items-center justify-center text-4xl mb-4">
            🧑‍🎨
          </div>

          {/* 스탯 표시 */}
          <div className="flex gap-6 justify-center w-full">
            <div className="text-center">
              <div className="text-red-400 text-xl mb-1">❤️</div>
              <div className="text-sm text-gray-300">HP</div>
              <div className="text-lg font-bold">996</div>
            </div>
            <div className="text-center">
              <div className="text-yellow-400 text-xl mb-1">⚔️</div>
              <div className="text-sm text-gray-300">ATK</div>
              <div className="text-lg font-bold">390</div>
            </div>
            <div className="text-center">
              <div className="text-cyan-400 text-xl mb-1">🛡️</div>
              <div className="text-sm text-gray-300">DEF</div>
              <div className="text-lg font-bold">63</div>
            </div>
          </div>
        </div>
      </div>

      {/* 착용 장비 슬롯 (6개) */}
      <div className="mb-6">
        <h2 className="text-lg font-bold mb-3">착용 장비</h2>
        <div className="grid grid-cols-3 gap-3">
          {equippedSlots.map((slot) => (
            <div
              key={slot.id}
              className={`aspect-square rounded-lg border-2 p-2 flex flex-col items-center justify-center cursor-pointer transition ${
                slot.equipped
                  ? `${tierColors[slot.equipped.tier]} border-2`
                  : 'border-slate-600 bg-slate-700/50'
              }`}
              onClick={() => setSelectedEquipment(slot.equipped)}
            >
              {slot.equipped ? (
                <>
                  {/* 장비 종류 (좌상단) */}
                  <div className="absolute top-1 left-1 text-xs bg-slate-900 px-2 py-1 rounded font-bold">
                    {typeNames[slot.equipped.type]}
                  </div>

                  {/* 레벨 (우상단) */}
                  <div className="absolute top-1 right-1 text-xs bg-slate-900 px-2 py-1 rounded font-bold">
                    LV {slot.equipped.level}
                  </div>

                  {/* 아이콘 (중앙) */}
                  <div className="text-3xl">{slot.equipped.icon}</div>
                </>
              ) : (
                <div className="text-slate-500 text-center">
                  <div className="text-xs">{typeNames[slot.type]}</div>
                  <div className="text-xl">+</div>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* 보유 장비 스크롤 리스트 */}
      <div className="mb-6">
        <h2 className="text-lg font-bold mb-3">보유 장비</h2>
        <div className="bg-slate-700/50 rounded-lg border border-slate-600 p-3">
          <div className="overflow-x-auto scrollbar-hide">
            <div className="flex gap-3 pb-2">
              {inventory.map((item) => (
                <div
                  key={item.id}
                  className={`flex-shrink-0 w-20 h-20 rounded-lg border-2 p-2 flex flex-col items-center justify-center cursor-pointer transition ${
                    tierColors[item.tier]
                  } relative`}
                  onClick={() => setSelectedEquipment(item)}
                >
                  {/* 장비 종류 (좌상단) */}
                  <div className="absolute top-1 left-1 text-xs bg-slate-900 px-1.5 py-0.5 rounded font-bold">
                    {typeNames[item.type]}
                  </div>

                  {/* 레벨 (우상단) */}
                  <div className="absolute top-1 right-1 text-xs bg-slate-900 px-1.5 py-0.5 rounded font-bold">
                    LV {item.level}
                  </div>

                  {/* 아이콘 (중앙) */}
                  <div className="text-2xl">{item.icon}</div>

                  {/* 착용 표시 */}
                  {item.equipped && (
                    <div className="absolute bottom-1 right-1 text-xs bg-green-500 text-white px-1 rounded">
                      착용
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* 하단 네비게이션 */}
      <div className="fixed bottom-0 left-0 right-0 bg-slate-900 border-t border-slate-700 px-4 py-3 flex justify-around">
        <button className="flex flex-col items-center gap-1 text-gray-400 hover:text-white">
          <span className="text-xl">🏠</span>
          <span className="text-xs">홈</span>
        </button>
        <button className="flex flex-col items-center gap-1 text-gray-400 hover:text-white">
          <span className="text-xl">🎴</span>
          <span className="text-xs">카드</span>
        </button>
        <button className="flex flex-col items-center gap-1 text-gray-400 hover:text-white">
          <span className="text-xl">⬆️</span>
          <span className="text-xs">업그레이드</span>
        </button>
        <button className="flex flex-col items-center gap-1 text-yellow-400 hover:text-yellow-300">
          <span className="text-xl">👤</span>
          <span className="text-xs">캐릭터</span>
        </button>
        <button className="flex flex-col items-center gap-1 text-gray-400 hover:text-white">
          <span className="text-xl">🏪</span>
          <span className="text-xs">상점</span>
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
