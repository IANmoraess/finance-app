/* data.jsx — category model + color helpers */

// type meta (matches the movimentação segmented control)
const TYPES = [
  { key: 'gasto',         label: 'Gastos',         single: 'Gasto',         dot: '#FB5757' },
  { key: 'entrada',       label: 'Entradas',       single: 'Entrada',       dot: '#34D399' },
  { key: 'investimento',  label: 'Investimentos',  single: 'Investimento',  dot: '#7C9CFF' },
];

// curated color palette — quick suggestions on the create screen
const PALETTE = [
  '#FB5757', // coral
  '#F97316', // orange
  '#F59E0B', // amber
  '#84CC16', // lime
  '#22C55E', // green
  '#14B8A6', // teal
  '#06B6D4', // cyan
  '#3B82F6', // blue
  '#6366F1', // indigo
  '#A855F7', // purple
  '#EC4899', // pink
  '#94A3B8', // slate
];

// full color library, grouped by hue — browsed inside the dedicated color picker
const PALETTE_GROUPS = [
  { label: 'Vermelhos & Rosas',   colors: ['#FB5757','#EF4444','#F43F5E','#EC4899','#DB2777','#BE123C'] },
  { label: 'Laranjas & Âmbar',    colors: ['#F97316','#FB923C','#EA580C','#F59E0B','#FBBF24','#D97706'] },
  { label: 'Amarelos & Limão',    colors: ['#EAB308','#FACC15','#A3E635','#84CC16','#65A30D','#BEF264'] },
  { label: 'Verdes',              colors: ['#22C55E','#16A34A','#10B981','#34D399','#14B8A6','#059669'] },
  { label: 'Azuis & Ciano',       colors: ['#06B6D4','#38BDF8','#0EA5E9','#3B82F6','#2563EB','#0284C7'] },
  { label: 'Roxos & Índigo',      colors: ['#6366F1','#818CF8','#8B5CF6','#A855F7','#7C3AED','#C084FC'] },
  { label: 'Neutros',             colors: ['#94A3B8','#64748B','#475569','#78716C','#A8A29E','#6B7280'] },
];

let _uid = 100;
const newId = () => 'c' + (++_uid);

const SEED = [
  // ---- Gastos ----
  { id:'g1', type:'gasto', name:'Alimentação',  icon:'utensils',       color:'#F59E0B' },
  { id:'g2', type:'gasto', name:'Moradia',      icon:'home',           color:'#3B82F6' },
  { id:'g3', type:'gasto', name:'Transporte',   icon:'car',            color:'#06B6D4' },
  { id:'g4', type:'gasto', name:'Saúde',        icon:'heart-pulse',    color:'#EF4444' },
  { id:'g5', type:'gasto', name:'Lazer',        icon:'gamepad-2',      color:'#A855F7' },
  { id:'g6', type:'gasto', name:'Compras',      icon:'shopping-bag',   color:'#EC4899' },
  { id:'g7', type:'gasto', name:'Educação',     icon:'graduation-cap', color:'#6366F1' },
  { id:'g8', type:'gasto', name:'Mercado',      icon:'shopping-cart',  color:'#84CC16' },
  { id:'g9', type:'gasto', name:'Contas',       icon:'receipt',        color:'#14B8A6' },
  { id:'g10',type:'gasto', name:'Viagem',       icon:'plane',          color:'#0EA5E9' },
  { id:'g11',type:'gasto', name:'Pets',         icon:'paw-print',      color:'#F97316' },
  { id:'g12',type:'gasto', name:'Assinaturas',  icon:'wifi',           color:'#8B5CF6' },
  { id:'g13',type:'gasto', name:'Outros',       icon:'more-horizontal',color:'#94A3B8' },

  // ---- Entradas ----
  { id:'e1', type:'entrada', name:'Salário',     icon:'banknote',     color:'#22C55E' },
  { id:'e2', type:'entrada', name:'Freelance',   icon:'laptop',       color:'#10B981' },
  { id:'e3', type:'entrada', name:'Vendas',      icon:'tag',          color:'#84CC16' },
  { id:'e4', type:'entrada', name:'Reembolso',   icon:'wallet',       color:'#14B8A6' },
  { id:'e5', type:'entrada', name:'Presente',    icon:'gift',         color:'#EC4899' },
  { id:'e6', type:'entrada', name:'Bônus',       icon:'sparkles',     color:'#F59E0B' },
  { id:'e7', type:'entrada', name:'Outros',      icon:'more-horizontal', color:'#94A3B8' },

  // ---- Investimentos ----
  { id:'i1', type:'investimento', name:'Ações',      icon:'trending-up',  color:'#22C55E' },
  { id:'i2', type:'investimento', name:'Fundos',     icon:'chart-pie',    color:'#3B82F6' },
  { id:'i3', type:'investimento', name:'Cripto',     icon:'bitcoin',      color:'#F59E0B' },
  { id:'i4', type:'investimento', name:'Renda Fixa', icon:'landmark',     color:'#14B8A6' },
  { id:'i5', type:'investimento', name:'Tesouro',    icon:'briefcase',    color:'#6366F1' },
  { id:'i6', type:'investimento', name:'Poupança',   icon:'piggy-bank',   color:'#EC4899' },
  { id:'i7', type:'investimento', name:'Dividendos', icon:'coins',        color:'#A855F7' },
  { id:'i8', type:'investimento', name:'Outros',     icon:'more-horizontal', color:'#94A3B8' },
];

// #RRGGBB -> rgba()
function rgba(hex, a){
  const h = hex.replace('#','');
  const r = parseInt(h.substring(0,2),16);
  const g = parseInt(h.substring(2,4),16);
  const b = parseInt(h.substring(4,6),16);
  return `rgba(${r},${g},${b},${a})`;
}

Object.assign(window, { TYPES, PALETTE, PALETTE_GROUPS, SEED, newId, rgba });
