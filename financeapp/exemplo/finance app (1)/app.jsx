/* app.jsx — navigation stack, tweaks, mount */

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "layout": "Seções",
  "colorMode": "Só ao selecionar",
  "accent": "#FB5757"
}/*EDITMODE-END*/;

const LAYOUT_MAP = { 'Seções': 'secoes', 'Abas': 'abas', 'Grade colorida': 'grade' };

function App(){
  const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);
  const layout = LAYOUT_MAP[t.layout] || 'secoes';
  const colorMode = t.colorMode === 'Sempre visível' ? 'always' : 'select';

  const [cats, setCats] = React.useState(SEED);
  const [nav, setNav] = React.useState({ screen: 'mov', editing: null });
  // movimentação form
  const [form, setForm] = React.useState({ type: 'gasto', digits: '', title: '', desc: '', catId: null });
  const setForm2 = (patch) => setForm(p => ({ ...p, ...patch }));

  const go = (screen, extra = {}) => setNav({ screen, editing: null, ...extra });

  // ---- category mutations ----
  const saveCat = (cat) => {
    setCats(prev => {
      const i = prev.findIndex(c => c.id === cat.id);
      if (i === -1) return [...prev, cat];
      const next = prev.slice(); next[i] = cat; return next;
    });
    setForm2({ type: cat.type, catId: cat.id });
    go('cats');
  };
  const deleteCats = (ids) => {
    setCats(prev => prev.filter(c => !ids.includes(c.id)));
    setForm(p => ids.includes(p.catId) ? { ...p, catId: null } : p);
  };

  let screenEl;
  if (nav.screen === 'mov'){
    screenEl = (
      <MovimentacaoScreen
        st={form} set={setForm2} categories={cats}
        onOpenCategorias={() => go('cats')}
      />
    );
  } else if (nav.screen === 'cats'){
    screenEl = (
      <CategoriasScreen
        categories={cats} layout={layout} colorMode={colorMode} selectedId={form.catId}
        onBack={() => go('mov')}
        onPick={(c) => { setForm2({ type: c.type, catId: c.id }); go('mov'); }}
        onCreate={(type) => setNav({ screen: 'create', editing: { type } })}
        onEdit={(c) => setNav({ screen: 'create', editing: c })}
        onDelete={deleteCats}
      />
    );
  } else {
    // editing.id present → edit; only {type} → new with that type
    const initial = nav.editing && nav.editing.id ? nav.editing : null;
    const seedType = nav.editing && nav.editing.type;
    screenEl = (
      <CriarCategoriaScreen
        initial={initial}
        seedType={seedType}
        onBack={() => go('cats')}
        onSave={saveCat}
        onDelete={(id) => { deleteCats([id]); go('cats'); }}
      />
    );
  }

  const accentStyle = { '--accent': t.accent, '--accent-weak': rgba(t.accent, 0.13) };

  return (
    <React.Fragment>
      <div className="stage">
        <IOSDevice dark width={390} height={844}>
          <div style={{ position: 'absolute', inset: 0, ...accentStyle }}>
            {screenEl}
          </div>
        </IOSDevice>
      </div>

      <TweaksPanel>
        <TweakSection label="Tela de categorias" />
        <TweakRadio label="Layout" value={t.layout}
          options={['Seções', 'Abas', 'Grade colorida']}
          onChange={(v) => setTweak('layout', v)} />
        <TweakRadio label="Cor do chip" value={t.colorMode}
          options={['Só ao selecionar', 'Sempre visível']}
          onChange={(v) => setTweak('colorMode', v)} />
        <TweakSection label="Marca" />
        <TweakColor label="Cor de destaque" value={t.accent}
          options={['#FB5757', '#6366F1', '#22C55E', '#F59E0B', '#EC4899']}
          onChange={(v) => setTweak('accent', v)} />
      </TweaksPanel>
    </React.Fragment>
  );
}

// fix: CriarCategoriaScreen treats an initial without id as "new"
ReactDOM.createRoot(document.getElementById('root')).render(<App />);
