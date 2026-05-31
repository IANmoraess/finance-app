/* screens.jsx — the three app screens */

// ── currency entry that formats as R$ 0,00 ─────────────────────
function CurrencyField({ digits, onDigits }){
  const ref = React.useRef(null);
  const cents = parseInt(digits || '0', 10);
  const text = (cents / 100).toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  const handle = (e) => {
    const only = e.target.value.replace(/\D/g, '').slice(0, 9);
    onDigits(only);
  };
  return (
    <div className="valuecard" onClick={() => ref.current && ref.current.focus()}>
      <div className="valuecard__label">Valor</div>
      <div className="valuecard__amount"><small>R$</small>{text}</div>
      <input
        ref={ref} value={digits} onChange={handle}
        inputMode="numeric" type="tel"
        style={{ position: 'absolute', opacity: 0, width: 1, height: 1, pointerEvents: 'none' }}
      />
    </div>
  );
}

// ════════════════════════════════════════════════════════════════
// 1 · Nova Movimentação  (recreated reference + entry point)
// ════════════════════════════════════════════════════════════════
function MovimentacaoScreen({ st, set, categories, onOpenCategorias }){
  const mains = categories
    .filter(c => c.type === st.type && c.name !== 'Outros')
    .slice(0, 7);
  const outros = categories.find(c => c.type === st.type && c.name === 'Outros');
  const typeLabel = TYPES.find(t => t.key === st.type).single;

  return (
    <div className="screen">
      <AppBar title="Nova Movimentação" onBack={() => {}} />
      <div className="screen__body">
        <Segmented value={st.type} onChange={(v) => set({ type: v, catId: null })} />

        <CurrencyField digits={st.digits} onDigits={(d) => set({ digits: d })} />

        <input
          className="field" placeholder="Título (opcional)"
          value={st.title} onChange={e => set({ title: e.target.value })}
          style={{ marginBottom: 4 }}
        />

        <div className="section-label">
          Categoria
          <button className="section-label__link" onClick={onOpenCategorias}>
            Ver todas <Icon name="chevron-right" size={14} />
          </button>
        </div>

        <div className="chips">
          {mains.map(c => (
            <Chip key={c.id + (st.catId === c.id ? '#on' : '')} cat={c} selected={st.catId === c.id}
              onTap={() => set({ catId: c.id })} onLong={onOpenCategorias} />
          ))}
          {outros && (
            <div className="chip chip--new" onClick={onOpenCategorias}>
              <Icon name="layout-grid" size={15} />
              <span>Outros</span>
            </div>
          )}
        </div>

        <div className="rowfield" style={{ marginTop: 18 }}>
          <Icon name="calendar" size={18} />
          <span className="rowfield__text">31 de maio, 2026</span>
          <Icon name="chevron-right" size={18} className="ic rowfield__chev" />
        </div>

        <textarea className="field" placeholder="Descrição (opcional)…"
          style={{ marginTop: 14 }} value={st.desc} onChange={e => set({ desc: e.target.value })} />
      </div>
      <div className="footer">
        <button className="btn">Salvar {typeLabel}</button>
      </div>
    </div>
  );
}

// ════════════════════════════════════════════════════════════════
// 2 · Categorias  (full list · pick · manage · multi-delete)
// ════════════════════════════════════════════════════════════════
function CategoriasScreen({ categories, layout, colorMode, selectedId, onBack, onPick, onCreate, onEdit, onDelete }){
  const [selectMode, setSelectMode] = React.useState(false);
  const [checked, setChecked] = React.useState({});
  const [tab, setTab] = React.useState('gasto');
  const [sheet, setSheet] = React.useState(null);     // category being long-pressed
  const [confirm, setConfirm] = React.useState(null); // { ids, title, message }
  const [picked, setPicked] = React.useState(selectedId); // shows the colored ring on tap

  const checkedIds = Object.keys(checked).filter(k => checked[k]);
  const useGrid = layout === 'grade';

  const exitSelect = () => { setSelectMode(false); setChecked({}); };

  const tap = (cat) => {
    if (selectMode){
      setChecked(p => ({ ...p, [cat.id]: !p[cat.id] }));
    } else {
      setPicked(cat.id);                       // ring lights up in the category color
      setTimeout(() => onPick(cat), 340);      // then return to the movimentação
    }
  };
  const long = (cat) => { if (!selectMode) setSheet(cat); };

  const renderItems = (list) => (
    useGrid
      ? <div className="grid-cats">
          {list.map(c => (
            <GridCell key={c.id + (picked === c.id ? '#s' : '') + (checked[c.id] ? '#k' : '') + (selectMode ? '#m' : '')} cat={c} selected={picked === c.id}
              selectMode={selectMode} checked={!!checked[c.id]}
              onTap={() => tap(c)} onLong={() => long(c)} />
          ))}
        </div>
      : <div className="chips">
          {list.map(c => (
            <Chip key={c.id + (picked === c.id ? '#s' : '') + (checked[c.id] ? '#k' : '') + (selectMode ? '#m' : '') + (colorMode === 'always' ? '#c' : '')} cat={c} colorMode={colorMode}
              selected={picked === c.id} selectMode={selectMode} checked={!!checked[c.id]}
              onTap={() => tap(c)} onLong={() => long(c)} />
          ))}
        </div>
  );

  const Group = ({ t }) => {
    const list = categories.filter(c => c.type === t.key);
    return (
      <div className="catgroup">
        <div className="catgroup__head">
          <span className="catgroup__dot" style={{ background: t.dot }} />
          <span className="catgroup__title">{t.label}</span>
          <span className="catgroup__count">{list.length}</span>
        </div>
        {renderItems(list)}
      </div>
    );
  };

  return (
    <div className="screen screen-enter">
      <AppBar
        title={selectMode ? `${checkedIds.length} selecionada${checkedIds.length === 1 ? '' : 's'}` : 'Categorias'}
        onBack={selectMode ? null : onBack}
        leading={selectMode ? <button className="iconbtn" onClick={exitSelect}><Icon name="x" size={22} /></button> : null}
        action={() => (selectMode ? exitSelect() : setSelectMode(true))}
        actionLabel={selectMode ? 'Concluir' : 'Selecionar'}
        actionMuted={selectMode}
      />

      <div className="screen__body">
        {layout === 'abas' ? (
          <React.Fragment>
            <Segmented value={tab} onChange={setTab} />
            {renderItems(categories.filter(c => c.type === tab))}
          </React.Fragment>
        ) : (
          TYPES.map(t => <Group key={t.key} t={t} />)
        )}
        <div style={{ height: 8 }} />
      </div>

      {selectMode ? (
        <div className="actionbar">
          <span className="actionbar__count"><b>{checkedIds.length}</b> selecionada{checkedIds.length === 1 ? '' : 's'}</span>
          <button className="btn-danger" disabled={!checkedIds.length}
            onClick={() => setConfirm({
              ids: checkedIds,
              title: `Excluir ${checkedIds.length} categoria${checkedIds.length === 1 ? '' : 's'}?`,
              message: 'As movimentações já registradas não serão removidas, mas a categoria deixará de aparecer.',
            })}>
            <Icon name="trash-2" size={16} /> Excluir
          </button>
        </div>
      ) : (
        <div className="footer">
          <button className="btn" onClick={() => onCreate(layout === 'abas' ? tab : 'gasto')}>
            <span style={{ display: 'inline-flex', alignItems: 'center', gap: 8, justifyContent: 'center' }}>
              <Icon name="plus" size={18} stroke={2.4} /> Nova categoria
            </span>
          </button>
        </div>
      )}

      {sheet && (
        <BottomSheet onClose={() => setSheet(null)}>
          <div className="sheet__head">
            <span className="gcell__tile" style={{ width: 44, height: 44, borderRadius: 13, background: rgba(sheet.color, 0.15), color: sheet.color }}>
              <Icon name={sheet.icon} size={22} />
            </span>
            <div>
              <div className="sheet__title">{sheet.name}</div>
              <div className="sheet__sub">{TYPES.find(t => t.key === sheet.type).single}</div>
            </div>
          </div>
          <button className="sheet__opt" onClick={() => { const c = sheet; setSheet(null); onEdit(c); }}>
            <Icon name="pencil" size={20} /> Editar categoria
          </button>
          <button className="sheet__opt is-danger" onClick={() => {
            const c = sheet; setSheet(null);
            setConfirm({ ids: [c.id], title: `Excluir "${c.name}"?`, message: 'Essa categoria deixará de aparecer ao criar movimentações.' });
          }}>
            <Icon name="trash-2" size={20} /> Excluir categoria
          </button>
        </BottomSheet>
      )}

      {confirm && (
        <ConfirmDialog
          title={confirm.title} message={confirm.message}
          onCancel={() => setConfirm(null)}
          onConfirm={() => { onDelete(confirm.ids); setConfirm(null); exitSelect(); }}
        />
      )}
    </div>
  );
}

// ════════════════════════════════════════════════════════════════
// 3 · Criar / Editar categoria
// ════════════════════════════════════════════════════════════════
function CriarCategoriaScreen({ initial, seedType, onBack, onSave, onDelete }){
  const editing = !!(initial && initial.id);
  const [type, setType]   = React.useState(initial ? initial.type : (seedType || 'gasto'));
  const [name, setName]   = React.useState(initial ? initial.name : '');
  const [icon, setIcon]   = React.useState(initial ? initial.icon : 'utensils');
  const [color, setColor] = React.useState(initial ? initial.color : '#FB5757');
  const [showIcons, setShowIcons] = React.useState(false);
  const [showColors, setShowColors] = React.useState(false);
  const valid = name.trim().length > 0;

  // suggested rows: always lead with the picked option, then fill from the quick lists
  const quick = [icon, ...QUICK_ICONS.filter(n => n !== icon)].slice(0, 5);
  const quickColors = [color, ...PALETTE.filter(c => c !== color)].slice(0, 7);

  return (
    <div className="screen screen-enter">
      <AppBar title={editing ? 'Editar categoria' : 'Nova categoria'} onBack={onBack} />
      <div className="screen__body">
        {/* live preview */}
        <div className="preview">
          <div className="preview__token" style={{ background: rgba(color, 0.16), color, boxShadow: `0 10px 30px ${rgba(color, 0.32)}` }}>
            <Icon name={icon} size={38} />
          </div>
          <div className={'preview__name' + (valid ? '' : ' is-ph')}>{valid ? name.trim() : 'Nome da categoria'}</div>
        </div>

        <Segmented value={type} onChange={setType} />

        <input className="field" placeholder="Título da categoria"
          value={name} onChange={e => setName(e.target.value)} maxLength={22} autoFocus />

        <div className="picker-label picker-label--row">
          ÍCONE
          <button className="section-label__link" onClick={() => setShowIcons(true)}>
            Ver todos <Icon name="chevron-right" size={14} />
          </button>
        </div>
        <div className="icon-grid">
          {quick.map(n => (
            <div key={n + (icon === n ? '#on' : '#off')} className={'icon-opt' + (icon === n ? ' is-sel' : '')}
              style={icon === n ? { '--c': color } : undefined}
              onClick={() => setIcon(n)}>
              <Icon name={n} size={22} />
            </div>
          ))}
        </div>

        <div className="picker-label picker-label--row">
          COR
          <button className="section-label__link" onClick={() => setShowColors(true)}>
            Ver todas <Icon name="chevron-right" size={14} />
          </button>
        </div>
        <div className="color-grid">
          {quickColors.map(c => (
            <div key={c + (color === c ? '#on' : '#off')} className={'color-opt' + (color === c ? ' is-active' : '')}
              style={{ background: c, color: c }} onClick={() => setColor(c)}>
              {color === c && <Icon name="check" size={18} stroke={3} style={{ color: '#fff' }} />}
            </div>
          ))}
        </div>

        {editing && (
          <button className="sheet__opt is-danger" style={{ marginTop: 22 }}
            onClick={() => onDelete(initial.id)}>
            <Icon name="trash-2" size={20} /> Excluir categoria
          </button>
        )}
      </div>

      <div className="footer">
        <button className="btn" disabled={!valid}
          style={valid ? { background: color } : null}
          onClick={() => onSave({ id: initial ? initial.id : newId(), type, name: name.trim(), icon, color })}>
          {editing ? 'Salvar alterações' : 'Criar categoria'}
        </button>
      </div>

      {showIcons && (
        <IconPicker
          value={icon} color={color}
          onPick={(n) => { setIcon(n); setShowIcons(false); }}
          onClose={() => setShowIcons(false)}
        />
      )}

      {showColors && (
        <ColorPicker
          value={color}
          onPick={(c) => { setColor(c); setShowColors(false); }}
          onClose={() => setShowColors(false)}
        />
      )}
    </div>
  );
}

Object.assign(window, { MovimentacaoScreen, CategoriasScreen, CriarCategoriaScreen });
