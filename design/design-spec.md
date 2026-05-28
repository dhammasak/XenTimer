# XenTimer — Design Spec

> Visual language: **calm · premium · minimal**. The app should feel like a quiet workshop, not a productivity dashboard.

---

## 1. Color Palette

The palette draws from the brief's mood (deep navy, warm white, soft grey, soft green, muted burgundy). Hues are desaturated and slightly warm to feel restful rather than corporate.

### Light Mode

| Role | Token | Hex | Use |
|---|---|---|---|
| Background — page | `--bg` | `#F5F1EA` | Warm off-white (light parchment) |
| Background — surface | `--surface` | `#FFFFFF` | Cards, panels |
| Background — surface alt | `--surface-2` | `#EFEAE1` | Inset areas, list rows |
| Text — primary | `--ink` | `#1C2330` | Deep navy ink |
| Text — secondary | `--ink-muted` | `#6E7587` | Labels, metadata |
| Text — tertiary | `--ink-soft` | `#A6A99F` | Hint text |
| Border | `--border` | `#E2DCD0` | Hairlines |
| Border — strong | `--border-strong` | `#CFC8B9` | Inputs, dividers |
| Accent — Focus | `--focus` | `#5C8F7B` | Soft sage — focus sessions, primary action |
| Accent — Focus deep | `--focus-deep` | `#3F6C5B` | Hover/pressed |
| Accent — Breathing | `--breath` | `#2E4259` | Deep navy — breathing mode, full-screen |
| Accent — Breathing soft | `--breath-soft` | `#7B8CA3` | Breathing UI accents |
| Accent — Reflection | `--accent-burgundy` | `#8B5A6B` | Muted burgundy — ratings, highlights |
| Success | `--success` | `#5C8F7B` | (same as Focus) |
| Warning | `--warn` | `#B68A3E` | Soft amber |

### Dark Mode

| Role | Token | Hex |
|---|---|---|
| Background — page | `--bg` | `#0F141B` |
| Background — surface | `--surface` | `#171D26` |
| Background — surface alt | `--surface-2` | `#1F2630` |
| Text — primary | `--ink` | `#EDE8DE` |
| Text — secondary | `--ink-muted` | `#9298A6` |
| Border | `--border` | `#262D38` |
| Accent — Focus | `--focus` | `#7DB199` |
| Accent — Breathing | `--breath` | `#A8B8CC` |
| Accent — Reflection | `--accent-burgundy` | `#B07989` |

### Color Usage Rules

- **Focus sessions** use sage green as primary accent — never burgundy.
- **Breathing mode** uses deep navy / soft slate — calm, immersive. Full-screen breathing background uses `--breath` directly with reduced luminance.
- **Burgundy** appears only in ratings, reflection notes, and warm accents on history pages — sparingly.
- Most chrome is in neutrals. Accent colors should feel earned.

---

## 2. Typography

System stack first; macOS gets SF Pro automatically. For breathing screens we use slightly lighter weights to feel airy.

```
--font-ui:      -apple-system, "SF Pro Text", "Inter", system-ui, sans-serif
--font-display: -apple-system, "SF Pro Display", "Inter", system-ui, sans-serif
--font-mono:    "SF Mono", ui-monospace, Menlo, monospace
```

### Type scale

| Token | Size | Line | Weight | Tracking | Use |
|---|---|---|---|---|---|
| `--t-display-xl` | 64px | 1.05 | 200 | -0.02em | Breathing circle timer, hero numbers |
| `--t-display-l` | 44px | 1.1 | 300 | -0.015em | Dashboard primary stat |
| `--t-display` | 32px | 1.15 | 300 | -0.01em | Section titles in breathing |
| `--t-h1` | 24px | 1.25 | 500 | -0.005em | Page titles |
| `--t-h2` | 18px | 1.3 | 500 | 0 | Section heads |
| `--t-h3` | 15px | 1.4 | 600 | 0 | Card titles, label emphasis |
| `--t-body` | 14px | 1.5 | 400 | 0 | Body copy |
| `--t-small` | 13px | 1.45 | 400 | 0 | Secondary copy |
| `--t-meta` | 11px | 1.3 | 500 | 0.06em (uppercase) | Tags, eyebrows |
| `--t-mono` | 14px | 1.4 | 500 | -0.01em | Time displays |

Weights stay in the 300–600 range — never bold, to keep the calm feel.

---

## 3. Spacing & Layout

```
--s-1: 4px   --s-2: 8px   --s-3: 12px  --s-4: 16px
--s-5: 20px  --s-6: 24px  --s-7: 32px  --s-8: 40px
--s-9: 48px  --s-10: 64px --s-11: 80px --s-12: 96px
```

- Main window: **fixed width 720px**, height variable per view (min 560px).
- Side padding inside window: `--s-7` (32px).
- Card padding: `--s-6` (24px).
- Full-screen breathing: edge-to-edge, content centered, max content width 480px.

### Radius

```
--r-sm: 6px   --r-md: 10px  --r-lg: 16px
--r-xl: 24px  --r-pill: 999px
```

---

## 4. Motion

- All transitions: **`cubic-bezier(0.4, 0, 0.2, 1)`** (calm ease).
- Default duration: **240ms** for UI, **400ms** for state changes.
- **Breathing circle**: each phase animation matches its duration exactly (e.g. 4s inhale uses a 4s ease-in-out expand). Never overshoot.
- No bounce, no spring physics. The app moves like a metronome — predictable, steady.

---

## 5. Iconography

- Use **SF Symbols** in app (via SwiftUI). In mockups, inline SVG with `stroke-width: 1.5`, rounded line caps.
- Icon sizes: 14, 16, 20, 24, 32.
- Icons should be outline style (not filled) to match the calm aesthetic — exceptions: status dots and active state indicators.

---

## 6. Surface Hierarchy

Three depths only:
1. **Page** — `--bg`
2. **Surface** — `--surface`, no shadow, hairline border
3. **Floating** — `--surface` with `0 1px 2px rgba(0,0,0,0.04), 0 8px 24px rgba(20, 30, 50, 0.06)` — for menus, dropdowns

We deliberately avoid stacking many elevations. Quiet hierarchy.

---

## 7. Breathing Animation Reference

Circle scales between **0.55** and **1.0** of its max size:

| Phase | Scale Target | Duration | Easing |
|---|---|---|---|
| Inhale | 0.55 → 1.0 | configurable (e.g. 4s) | ease-in-out |
| Hold (after inhale) | hold at 1.0 | configurable | linear (none) |
| Exhale | 1.0 → 0.55 | configurable (e.g. 6s) | ease-in-out |
| Rest (after exhale) | hold at 0.55 | configurable | linear (none) |

Background subtle gradient pulses ±3% luminance with the breath — almost imperceptible.

Text guide cross-fades 600ms before phase change ends.

---

## 8. Accessibility

- Minimum contrast: WCAG AA (4.5:1 for body, 3:1 for large).
- Focus rings: 2px `--focus` with 2px offset.
- Respect `prefers-reduced-motion` — breathing circle still animates (it's the point) but UI transitions become instant.
- Full keyboard navigation; no mouse-only flows.

---

## 9. Window Chrome (macOS)

- Use **`.hiddenTitleBar`** style for main window, with traffic lights overlay on a custom toolbar.
- Sidebar (if introduced later) uses macOS sidebar material.
- Full-screen breathing uses **plain window, no chrome**, ESC to exit.
