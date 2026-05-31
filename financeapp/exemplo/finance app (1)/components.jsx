/* components.jsx — shared UI primitives (depend on Icon, rgba) */

// ---- long-press hook: fires onLong after 480ms hold, suppresses the click ----
function useLongPress(onLong, onTap, ms = 480){
  const t = React.useRef(null);
  const longFired = React.useRef(false);
  const start = (e) => {
    longFired.current = false;
    t.current = setTimeout(() => { longFired.current = true; onLong && onLong(); }, ms);
  };
  const clear = () => { if (t.current){ clearTimeout(t.current); t.current = null; } };
  const click = () => {
    if (longFired.current){ longFired.current = false; return; }
    onTap && onTap();
  };
  return {
    onPointerDown: start,
    onPointerUp: clear,
    onPointerLeave: clear,
    onPointerCancel: clear,
    onClick: click,
    onContextMenu: (e) => e.preventDefault(),
  };
}

// ---- top app bar ----
function AppBar({ title, onBack, action, actionLabel, actionMuted, leading }){
  return (
    <div className="appbar">
      {onBack
        ? <button className="iconbtn" onClick={onBack} aria-label="Voltar">
            <Icon name="arrow-left" size={22} />
          </button>
        : (leading || <span style={{ width: 38 }} />)}
      <div className="appbar__title">{title}</div>
      {action
        ? <button className={'appbar__action' + (actionMuted ? ' appbar__action--muted' : '')} onClick={action}>{actionLabel}</button>
        : <span style={{ width: 38 }} />}
    </div>
  );
}

// ---- segmented type switcher ----
function Segmented({ value, onChange }){
  return (
    <div className="segmented" role="tablist">
      {TYPES.map(t => (
        <button
          key={t.key}
          className={'segmented__item' + (value === t.key ? ' is-active' : '')}
          onClick={() => onChange(t.key)}
        >{t.single}</button>
      ))}
    </div>
  );
}

// ---- category pill ----
function Chip({ cat, selected, colorMode = 'select', selectMode = false, checked = false, onTap, onLong }){
  const handlers = useLongPress(onLong, onTap);
  const cls = ['chip'];
  if (selectMode && checked) cls.push('is-checked');
  else if (selected && !selectMode) cls.push('is-sel');
  else if (colorMode === 'always') cls.push('is-color');

  return (
    <div className={cls.join(' ')} style={{ '--c': cat.color }} {...handlers}>
      <Icon name={cat.icon} size={16} />
      <span>{cat.name}</span>
      {selectMode && (
        <span className="chip__check">
          {checked && <Icon name="check" size={11} stroke={3} />}
        </span>
      )}
    </div>
  );
}

// ---- grid cell (Grade layout) ----
function GridCell({ cat, selected, selectMode, checked, onTap, onLong }){
  const handlers = useLongPress(onLong, onTap);
  const active = (selected && !selectMode) || (selectMode && checked);
  const cls = ['gcell'];
  if (selected && !selectMode) cls.push('is-sel');
  if (active) cls.push('is-active');
  if (selectMode && checked) cls.push('is-checked');
  return (
    <div className={cls.join(' ')} style={{ '--c': cat.color }} {...handlers}>
      <div className="gcell__tile" style={{ background: rgba(cat.color, active ? 0.24 : 0.13), color: cat.color }}>
        <Icon name={cat.icon} size={24} />
      </div>
      <div className="gcell__name">{cat.name}</div>
      {selectMode && (
        <span className="gcell__check">
          {checked && <Icon name="check" size={11} stroke={3} />}
        </span>
      )}
    </div>
  );
}

// ---- bottom sheet ----
function BottomSheet({ onClose, children }){
  return (
    <div className="scrim" onClick={onClose}>
      <div className="sheet" onClick={e => e.stopPropagation()}>
        <div className="sheet__grip" />
        {children}
      </div>
    </div>
  );
}

// ---- confirm dialog ----
function ConfirmDialog({ title, message, confirmLabel = 'Excluir', onConfirm, onCancel }){
  return (
    <div className="scrim scrim--center" onClick={onCancel}>
      <div className="dialog" onClick={e => e.stopPropagation()}>
        <div className="dialog__icon"><Icon name="trash-2" size={24} /></div>
        <div className="dialog__title">{title}</div>
        <div className="dialog__msg">{message}</div>
        <div className="dialog__row">
          <button className="btn btn--ghost" onClick={onCancel}>Cancelar</button>
          <button className="btn" style={{ background: '#E5484D' }} onClick={onConfirm}>{confirmLabel}</button>
        </div>
      </div>
    </div>
  );
}

// ---- full-screen icon library (searchable, grouped) ----
function IconPicker({ value, color, onPick, onClose }){
  const [q, setQ] = React.useState('');
  const query = q.trim().toLowerCase();
  const groups = ICON_GROUPS
    .map(g => ({ label: g.label, icons: query ? g.icons.filter(n => n.includes(query)) : g.icons }))
    .filter(g => g.icons.length);
  const empty = groups.length === 0;

  return (
    <div className="icon-picker">
      <AppBar title="Escolher ícone" onBack={onClose} />
      <div className="icon-picker__search">
        <Icon name="search" size={18} />
        <input autoFocus value={q} onChange={e => setQ(e.target.value)}
          placeholder="Buscar ícone…" spellCheck={false} />
        {q && (
          <button className="icon-picker__clear" onClick={() => setQ('')} aria-label="Limpar">
            <Icon name="x" size={16} />
          </button>
        )}
      </div>
      <div className="icon-picker__body">
        {empty ? (
          <div className="icon-picker__empty">
            <Icon name="search-x" size={30} />
            <p>Nenhum ícone encontrado</p>
          </div>
        ) : groups.map(g => (
          <div className="icon-cat" key={g.label}>
            <div className="icon-cat__label">{g.label}</div>
            <div className="icon-grid">
              {g.icons.map(n => (
                <div key={n + (value === n ? '#on' : '')}
                  className={'icon-opt' + (value === n ? ' is-sel' : '')}
                  style={value === n ? { '--c': color } : undefined}
                  onClick={() => onPick(n)}>
                  <Icon name={n} size={22} />
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ---- full-screen color library (grouped by hue) ----
function ColorPicker({ value, onPick, onClose }){
  return (
    <div className="icon-picker">
      <AppBar title="Escolher cor" onBack={onClose} />
      <div className="icon-picker__body">
        {PALETTE_GROUPS.map(g => (
          <div className="icon-cat" key={g.label}>
            <div className="icon-cat__label">{g.label}</div>
            <div className="color-grid">
              {g.colors.map(c => (
                <div key={c + (value === c ? '#on' : '')}
                  className={'color-opt' + (value === c ? ' is-active' : '')}
                  style={{ background: c, color: c }} onClick={() => onPick(c)}>
                  {value === c && <Icon name="check" size={18} stroke={3} style={{ color: '#fff' }} />}
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

Object.assign(window, { useLongPress, AppBar, Segmented, Chip, GridCell, BottomSheet, ConfirmDialog, IconPicker, ColorPicker });
