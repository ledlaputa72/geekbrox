import React from 'react';

interface Equipment {
  id: string;
  name: string;
  type: 'weapon' | 'armor' | 'ring' | 'necklace';
  level: number;
  tier: 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary';
  icon: string;
  equipped?: boolean;
}

interface EquipmentDetailModalProps {
  equipment: Equipment | null;
  onClose: () => void;
  onEquip?: (equipment: Equipment) => void;
}

const typeNames = {
  weapon: '무기',
  armor: '방어루',
  ring: '반지',
  necklace: '목걸이',
};

const tierInfo = {
  common: { name: '일반', color: 'text-gray-400', bgColor: 'from-gray-700 to-gray-800', borderColor: 'border-gray-600' },
  uncommon: { name: '고급', color: 'text-green-400', bgColor: 'from-green-700 to-green-800', borderColor: 'border-green-600' },
  rare: { name: '레어', color: 'text-blue-400', bgColor: 'from-blue-700 to-blue-800', borderColor: 'border-blue-600' },
  epic: { name: '에픽', color: 'text-purple-400', bgColor: 'from-purple-700 to-purple-800', borderColor: 'border-purple-600' },
  legendary: { name: '전설', color: 'text-yellow-400', bgColor: 'from-yellow-700 to-yellow-800', borderColor: 'border-yellow-600' },
};

// 장비별 샘플 데이터 (실제로는 props로 받아야 함)
const getEquipmentDetails = (equipment: Equipment) => {
  const baseDetails: { [key: string]: any } = {
    'sword-001': {
      skills: '마법 강화',
      skillDesc: '마법 공격력 20% 증가. 최대 마나 +30',
      skillColor: 'purple',
      stats: { atk: '+50', def: '+30' },
      options: ['치명타율 15%', '회피율 8%'],
      usageCount: '0/10',
      usagePercent: 0,
    },
    'sword-002': {
      skills: '날카로운 검',
      skillDesc: '일반 공격 시 20% 확률로 추가 타격',
      skillColor: 'blue',
      stats: { atk: '+25', def: '+10' },
      options: ['공격력 8%', '방어력 5%'],
      usageCount: '2/10',
      usagePercent: 20,
    },
    'armor-001': {
      skills: '드래곤 가죽',
      skillDesc: '모든 피해 15% 감소. 불 속성 저항 +25%',
      skillColor: 'red',
      stats: { def: '+80', atk: '+20' },
      options: ['체력 30', '방어력 20%'],
      usageCount: '0/8',
      usagePercent: 0,
    },
    'armor-002': {
      skills: '가죽 강화',
      skillDesc: '기본 방어력 +15%',
      skillColor: 'orange',
      stats: { def: '+40', atk: '+5' },
      options: ['방어력 10%'],
      usageCount: '1/5',
      usagePercent: 20,
    },
    'ring-001': {
      skills: '힘의 축복',
      skillDesc: '모든 속성 공격력 +10%',
      skillColor: 'yellow',
      stats: { atk: '+30', def: '+15' },
      options: ['공격력 12%', '회심확률 5%'],
      usageCount: '0/6',
      usagePercent: 0,
    },
    'ring-002': {
      skills: '현명함',
      skillDesc: '최대 마나 +50. 마법 시전 시간 -10%',
      skillColor: 'cyan',
      stats: { atk: '+10', def: '+20' },
      options: ['마나 재생 +5/s'],
      usageCount: '0/7',
      usagePercent: 0,
    },
    'ring-003': {
      skills: '번개의 속도',
      skillDesc: '행동 속도 +15%. 회피율 +10%',
      skillColor: 'blue',
      stats: { atk: '+20', def: '+10' },
      options: ['회피율 12%', '행동속도 8%'],
      usageCount: '0/9',
      usagePercent: 0,
    },
    'neck-001': {
      skills: '마나 회복',
      skillDesc: '전투 중 매 턴 마나 +5% 회복',
      skillColor: 'green',
      stats: { atk: '+15', def: '+25' },
      options: ['마나 회복 +8%'],
      usageCount: '0/10',
      usagePercent: 0,
    },
    'neck-002': {
      skills: '생명력',
      skillDesc: '최대 체력 +20%. 회복 효과 +15%',
      skillColor: 'red',
      stats: { def: '+40', atk: '+10' },
      options: ['체력 25', '회복 효율 +10%'],
      usageCount: '0/8',
      usagePercent: 0,
    },
    'neck-003': {
      skills: '행운',
      skillDesc: '골드 획득량 +20%. 경험치 +10%',
      skillColor: 'yellow',
      stats: { atk: '+5', def: '+5' },
      options: ['골드 획득 +15%'],
      usageCount: '0/3',
      usagePercent: 0,
    },
  };

  return baseDetails[equipment.id] || {
    skills: '기본 장비',
    skillDesc: '특별한 능력이 없습니다.',
    skillColor: 'gray',
    stats: { atk: '+0', def: '+0' },
    options: [],
    usageCount: '0/1',
    usagePercent: 0,
  };
};

const getSkillColorClass = (color: string) => {
  const colors: { [key: string]: string } = {
    purple: 'border-purple-500 text-purple-300',
    blue: 'border-blue-500 text-blue-300',
    red: 'border-red-500 text-red-300',
    orange: 'border-orange-500 text-orange-300',
    yellow: 'border-yellow-500 text-yellow-300',
    cyan: 'border-cyan-500 text-cyan-300',
    green: 'border-green-500 text-green-300',
    gray: 'border-gray-500 text-gray-300',
  };
  return colors[color] || colors.gray;
};

export default function EquipmentDetailModal({ equipment, onClose, onEquip }: EquipmentDetailModalProps) {
  if (!equipment) return null;

  const details = getEquipmentDetails(equipment);
  const tier = tierInfo[equipment.tier];
  const skillColorClass = getSkillColorClass(details.skillColor);
  const usageValues = details.usageCount.split('/');

  return (
    <div className="fixed inset-0 bg-black/70 flex items-center justify-center p-4 z-50">
      <div className={`bg-gradient-to-b ${tier.bgColor} rounded-xl border-2 ${tier.borderColor} p-5 max-w-sm w-full shadow-2xl`}>
        {/* 상단: 아이콘 + 이름 + 등급 */}
        <div className="text-center mb-5 pb-4 border-b border-slate-600">
          <div className="inline-block mb-3 p-3 bg-slate-600/50 rounded-lg">
            <div className="text-5xl">{equipment.icon}</div>
          </div>
          <h3 className="text-xl font-bold mb-1">{equipment.name}</h3>
          <div className="flex justify-center gap-2 text-sm">
            <span className={tier.color}>{tier.name}</span>
            <span className="text-gray-500">•</span>
            <span className="text-gray-400">{typeNames[equipment.type]}</span>
            <span className="text-gray-500">•</span>
            <span className="text-gray-400">LV {equipment.level}</span>
          </div>
        </div>

        {/* 기본 능력치 */}
        <div className="mb-4">
          <div className="text-sm font-bold text-gray-300 mb-2">기본 능력치</div>
          <div className="grid grid-cols-2 gap-2">
            <div className="bg-slate-700/50 rounded p-2">
              <div className="text-xs text-gray-400">공격력</div>
              <div className="text-sm font-bold text-yellow-400">{details.stats.atk}</div>
            </div>
            <div className="bg-slate-700/50 rounded p-2">
              <div className="text-xs text-gray-400">방어력</div>
              <div className="text-sm font-bold text-cyan-400">{details.stats.def}</div>
            </div>
          </div>
        </div>

        {/* 장비 스킬 */}
        <div className="mb-4">
          <div className="text-sm font-bold text-gray-300 mb-2">장비 스킬</div>
          <div className={`bg-slate-700/50 rounded p-3 border-l-2 ${skillColorClass}`}>
            <div className="text-xs font-bold mb-1">{details.skills}</div>
            <div className="text-xs text-gray-400">
              {details.skillDesc}
            </div>
          </div>
        </div>

        {/* 추가 옵션 */}
        {details.options.length > 0 && (
          <div className="mb-4">
            <div className="text-sm font-bold text-gray-300 mb-2">추가 옵션</div>
            <div className="space-y-1">
              {details.options.map((option, idx) => (
                <div key={idx} className="text-xs text-gray-400">
                  <span className="text-green-400">+</span> {option}
                </div>
              ))}
            </div>
          </div>
        )}

        {/* 사용 횟수 */}
        <div className="mb-4 p-3 bg-slate-700/30 rounded border border-slate-600">
          <div className="flex justify-between items-center">
            <div className="text-xs text-gray-400">사용 가능 횟수</div>
            <div className={`text-sm font-bold ${tier.color}`}>{details.usageCount}</div>
          </div>
          <div className="w-full bg-slate-700 rounded-full h-2 mt-2">
            <div
              className={`h-2 rounded-full transition-all ${
                details.skillColor === 'purple' ? 'bg-purple-500' :
                details.skillColor === 'blue' ? 'bg-blue-500' :
                details.skillColor === 'red' ? 'bg-red-500' :
                details.skillColor === 'orange' ? 'bg-orange-500' :
                details.skillColor === 'yellow' ? 'bg-yellow-500' :
                details.skillColor === 'cyan' ? 'bg-cyan-500' :
                details.skillColor === 'green' ? 'bg-green-500' :
                'bg-gray-500'
              }`}
              style={{ width: `${details.usagePercent}%` }}
            ></div>
          </div>
        </div>

        {/* 하단 버튼 */}
        <div className="flex gap-2">
          <button
            onClick={onClose}
            className="flex-1 bg-slate-600 hover:bg-slate-500 py-2.5 rounded-lg font-bold text-sm transition"
          >
            닫기
          </button>
          <button
            onClick={() => {
              if (onEquip) onEquip(equipment);
              onClose();
            }}
            className="flex-1 bg-gradient-to-r from-blue-600 to-blue-500 hover:from-blue-500 hover:to-blue-400 py-2.5 rounded-lg font-bold text-sm transition text-white"
          >
            장착
          </button>
        </div>
      </div>
    </div>
  );
}
