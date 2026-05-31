/* icons.jsx — thin React wrapper over the Lucide icon set (loaded via CDN).
   Renders crisp inline SVGs that inherit `currentColor`, so chip/tile color
   drives the stroke color. */

function _pascal(name){
  return String(name).split(/[-_]/).map(s => s.charAt(0).toUpperCase() + s.slice(1)).join('');
}
function _camelAttrs(attrs){
  const out = {};
  for (const k in attrs){
    const ck = k.replace(/-([a-z])/g, (_, c) => c.toUpperCase());
    out[ck] = attrs[k];
  }
  return out;
}

function Icon({ name, size = 20, stroke = 2, className = 'ic', style }){
  const lib = (typeof window !== 'undefined' && window.lucide && window.lucide.icons) || null;
  const node = lib ? lib[_pascal(name)] : null;
  const common = {
    width: size, height: size, viewBox: '0 0 24 24', fill: 'none',
    stroke: 'currentColor', strokeWidth: stroke,
    strokeLinecap: 'round', strokeLinejoin: 'round',
    className, style, 'aria-hidden': true,
  };
  if (!node) {
    // graceful fallback: a small rounded square so layout never collapses
    return React.createElement('svg', common,
      React.createElement('rect', { x: 4, y: 4, width: 16, height: 16, rx: 4 }));
  }
  // lucide icon node = ["svg", attrs, [ [tag, attrs], ... ]]
  const kids = Array.isArray(node[2]) ? node[2] : [];
  const children = kids.map((entry, i) => {
    const [tag, attrs] = entry;
    return React.createElement(tag, { ...(_camelAttrs(attrs)), key: i });
  });
  return React.createElement('svg', common, children);
}

// full icon library, grouped — browsed inside the dedicated icon picker
const ICON_GROUPS = [
  { label: 'Geral',              icons: ['tag','star','heart','sparkles','flag','bookmark','bell','calendar','clock','map-pin','circle','more-horizontal'] },
  { label: 'Alimentação',        icons: ['utensils','coffee','pizza','beer','wine','apple','cake','soup','sandwich','cooking-pot','salad','ice-cream-cone'] },
  { label: 'Mercado & Compras',  icons: ['shopping-cart','shopping-bag','shopping-basket','store','gift','shirt','gem','watch','scissors','glasses','credit-card','receipt'] },
  { label: 'Casa & Contas',      icons: ['home','lightbulb','plug','droplet','flame','wifi','key','sofa','bed','trash-2','wrench','washing-machine'] },
  { label: 'Transporte',         icons: ['car','bus','train-front','plane','bike','fuel','ship','truck','map','navigation','footprints','parking-meter'] },
  { label: 'Saúde & Bem-estar',  icons: ['heart-pulse','pill','stethoscope','dumbbell','activity','syringe','brain','leaf','smile','bandage','hand-heart','baby'] },
  { label: 'Lazer & Educação',   icons: ['gamepad-2','film','music','book-open','graduation-cap','ticket','palette','camera','tv','headphones','trophy','popcorn'] },
  { label: 'Pets & Família',     icons: ['paw-print','dog','cat','bird','bone','rabbit','fish','users'] },
  { label: 'Trabalho & Renda',   icons: ['briefcase','laptop','banknote','wallet','building-2','handshake','mail','phone','factory','presentation','clipboard','calculator'] },
  { label: 'Investimentos',      icons: ['trending-up','trending-down','chart-pie','bitcoin','landmark','coins','piggy-bank','dollar-sign','percent','line-chart','candlestick-chart','wallet-cards'] },
];

// flat lookup of every icon name in the library
const ICON_CHOICES = ICON_GROUPS.reduce((all, g) => all.concat(g.icons), []);

// short "suggested" row shown on the create screen (selected icon is always prepended)
const QUICK_ICONS = ['utensils','home','car','shopping-bag','heart-pulse','banknote','trending-up','gift'];

Object.assign(window, { Icon, ICON_GROUPS, ICON_CHOICES, QUICK_ICONS });
