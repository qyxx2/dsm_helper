# DSM Helper Modern UI — Visual Design Specification

> Status: Authoritative for Task 3 and later New UI work  
> Date: 2026-10-07  
> Repository: `qyxx2/dsm_helper`  
> Integration branch: `modern-ui`  
> Task: Task 2 — Visual Design Specification  
> Task branch: `feature/t2-visual-design`  
> Product specification authority: `docs/modern-ui/specs/2026-10-07-dsm-helper-modern-ui-spec.md`

## 1. Purpose and authority

This document is the single authoritative visual specification for DSM Helper Modern UI.

It freezes the cross-page visual system that every New UI feature must inherit. It does not redefine product semantics already frozen by Task 1, and it does not define feature-specific business interactions.

The governing principle is:

> Material 3 defines semantics; DSM Helper tokens define density.

The resulting product is an Android-first, portrait-phone-priority NAS management interface with medium-high information density. It uses Material 3 semantics and interaction models without inheriting consumer-style oversized spacing, decorative glass, large hero layouts, or deep card stacks.

After this document, a feature may choose content-appropriate composition, but it must not invent another base font scale, spacing scale, color system, radius system, elevation hierarchy, list density, or system-bar policy.

## 2. Inherited immutable product contracts

This specification inherits Task 1 without modification.

In particular, it does not redefine:

- startup and resume semantics;
- five-destination primary navigation semantics;
- Server + Account identity;
- default-account restore;
- network failure versus authentication invalidation;
- DSM session authority;
- refresh and last-valid-data semantics;
- LegacyPageHost / fallback behavior;
- Material 3 versus legacy theme isolation;
- global DSM notification entry;
- Android Back, lifecycle, and intent behavior;
- File Station selection identity;
- Snackbar versus decision-confirmation product semantics;
- risk-tiered destructive-operation semantics.

Any conflict between a future feature design and a Task 1 global contract is resolved in favor of Task 1 unless that contract is explicitly amended through its own product decision process.

## 3. Immutable visual rules

### 3.1 Visual character

New UI is a restrained Material 3 management interface.

Information hierarchy is created primarily through:

1. typography;
2. spacing;
3. tonal surfaces;
4. grouping;
5. semantic state.

The following are not default New UI visual authorities:

- legacy glass / blur widgets;
- legacy gradients;
- deep shadows;
- large decorative hero regions;
- oversized cards;
- full-screen decorative backgrounds;
- the DSM Web visual language;
- legacy DSM Helper Material 2 / Cupertino mixtures.

Legacy visuals remain valid only inside the legacy fallback boundary.

### 3.2 Brand and color-source policy

Theme modes are System / Light / Dark, with System as the default. Theme mode and color source are independent settings.

DSM Helper default brand/accent seed is:

`#00A6FF`

This replaces legacy `#2A82E4` as the New UI visual authority. `#2A82E4` remains only a legacy fact.

The default color source is the DSM Helper scheme defined in this document.

Dynamic Color is:

- optional;
- off by default;
- enabled only by explicit user choice;
- independent from System / Light / Dark theme mode.

Dynamic Color may replace primary/secondary/tertiary and neutral Material palettes, but it must not change the meaning of success, warning, error, destructive, stale, offline, or reconnecting states.

### 3.3 Default Light ColorScheme roles

The following roles are the required default DSM Helper Light scheme.

| Role | Value |
|---|---|
| primary | `#00A6FF` |
| onPrimary | `#001E2B` |
| primaryContainer | `#CDEBFF` |
| onPrimaryContainer | `#00344F` |
| secondary | `#526A78` |
| onSecondary | `#FFFFFF` |
| secondaryContainer | `#D6E6EE` |
| onSecondaryContainer | `#273741` |
| tertiary | `#5E6670` |
| onTertiary | `#FFFFFF` |
| tertiaryContainer | `#E0E5EA` |
| onTertiaryContainer | `#30363C` |
| error | `#B3261E` |
| onError | `#FFFFFF` |
| errorContainer | `#F9DEDC` |
| onErrorContainer | `#410E0B` |
| surface | `#F6F9FB` |
| surfaceContainerLowest | `#FFFFFF` |
| surfaceContainerLow | `#F0F5F8` |
| surfaceContainer | `#EAF1F5` |
| surfaceContainerHigh | `#E4ECF1` |
| surfaceContainerHighest | `#DDE6EC` |
| onSurface | `#172126` |
| onSurfaceVariant | `#44515A` |
| outline | `#73818A` |
| outlineVariant | `#C3CED5` |
| inverseSurface | `#2C3134` |
| onInverseSurface | `#F0F3F5` |
| inversePrimary | `#6CC5FF` |
| scrim | `#000000` |
| surfaceTint | `#00A6FF` |

The surface family is deliberately low-chroma grey-blue. A normal page should read first as a neutral management surface with a cool blue bias, not as a pale-blue branded canvas.

### 3.4 Default Dark ColorScheme roles

The following roles are the required default DSM Helper Dark scheme.

| Role | Value |
|---|---|
| primary | `#00A6FF` |
| onPrimary | `#001E2B` |
| primaryContainer | `#004D73` |
| onPrimaryContainer | `#CDEBFF` |
| secondary | `#B7CBD7` |
| onSecondary | `#22333C` |
| secondaryContainer | `#394D58` |
| onSecondaryContainer | `#D6E6EE` |
| tertiary | `#C2C9D0` |
| onTertiary | `#2B3136` |
| tertiaryContainer | `#42494F` |
| onTertiaryContainer | `#E0E5EA` |
| error | `#FFB4AB` |
| onError | `#690005` |
| errorContainer | `#8C1D18` |
| onErrorContainer | `#F9DEDC` |
| surface | `#0F1418` |
| surfaceContainerLowest | `#0A0F12` |
| surfaceContainerLow | `#151B20` |
| surfaceContainer | `#1A2228` |
| surfaceContainerHigh | `#202A31` |
| surfaceContainerHighest | `#28343C` |
| onSurface | `#E5EBEF` |
| onSurfaceVariant | `#BCC8CF` |
| outline | `#89979F` |
| outlineVariant | `#3D4A52` |
| inverseSurface | `#E5EBEF` |
| onInverseSurface | `#263036` |
| inversePrimary | `#006A9F` |
| scrim | `#000000` |
| surfaceTint | `#00A6FF` |

Dark mode is low-saturation deep grey-blue, not pure black plus saturated blue. Tonal surface differences carry most depth.

### 3.5 Brand-primary contrast rule

`#00A6FF` must not automatically receive white foreground content.

For controls or containers using the exact brand primary as background, the default foreground is `#001E2B`. This pairing provides sufficient text/icon contrast while preserving the requested high-energy cyan-blue accent.

A feature must not override this with white merely for aesthetic familiarity.

### 3.6 Semantic state colors

Success and warning are custom semantic tokens outside the base Material ColorScheme where necessary.

#### Light

| Semantic role | Foreground | Container | On container |
|---|---|---|---|
| success | `#247A4B` | `#D1F6DE` | `#0C3B22` |
| warning | `#8A5A00` | `#FFE0A3` | `#3D2A00` |
| error/destructive | `#B3261E` | `#F9DEDC` | `#410E0B` |

#### Dark

| Semantic role | Foreground | Container | On container |
|---|---|---|---|
| success | `#65D99A` | `#154F31` | `#B8F1CF` |
| warning | `#F2C15C` | `#624300` | `#FFE0A3` |
| error/destructive | `#FFB4AB` | `#8C1D18` | `#F9DEDC` |

Rules:

- healthy/online/completed does not automatically mean a large green surface;
- warning and error increase visual emphasis progressively;
- offline and stale are not errors by definition;
- stop/stopped is not automatically destructive red;
- a status may never rely on color alone.

### 3.7 Typography tokens

Chinese-first UI uses the platform/system font stack. No custom font dependency is required by this specification.

| Token | Size | Weight / use |
|---|---:|---|
| appBarTitle | 20sp | 500 |
| pageTitle | 22sp | 600; use only when a page genuinely needs a page-level title below the App Bar |
| sectionTitle | 16sp | 600 |
| listTitle | 15sp | 500 |
| body | 14sp | 400 |
| formValue | 14sp | 400 |
| metadata | 12sp | 400 |
| badge | 12sp | 500; short labels only |
| captionCompact | 11sp | 400; non-interactive tertiary/chart labels only |
| metricSmall | 20sp | 600 |
| metricMedium | 24sp | 600 |
| metricLarge | 28sp | 600; maximum default metric emphasis |

There is no global oversized hero typography.

Technical text policy:

- IP addresses, percentages, capacity values, ports and timestamps remain in the normal UI font by default;
- use tabular figures where the platform/font support makes them practical;
- paths, logs, commands and terminal-like content may use local monospace;
- monospace is never a global app font.

System font scaling is respected. Global `textScaleFactor = 1.0` or equivalent suppression is prohibited.

### 3.8 Spacing tokens

The global spacing scale is:

`2 / 4 / 8 / 12 / 16 / 24 / 32dp`

Rules:

- 2dp is micro-adjustment only;
- default portrait-phone page horizontal content padding: 16dp;
- compact internal gap: 8dp;
- normal component gap: 12dp;
- major spacing within one section: 16dp;
- between sections: 24dp;
- major structural separation: 32dp.

Full-width list/table surfaces may extend edge-to-edge, but text and primary interactive content still align to the 16dp content baseline unless a system component has its own defined inset.

A feature may not invent 10/18/20dp page margins as an independent visual system.

### 3.9 Radius tokens

| Token | Radius |
|---|---:|
| small | 6dp |
| medium | 10dp |
| large | 14dp |
| extraLarge | 20dp |

Default mappings:

- small status container / compact highlight: 6dp;
- Button and TextField: 10dp;
- Card: 14dp;
- Dialog and modal Bottom Sheet top corners: 20dp.

Pill / fully rounded shapes are reserved for components whose semantics justify them, such as badge, chip, segmented selection, or a Material indicator. Ordinary Cards do not become pills.

### 3.10 Surface and elevation hierarchy

Color/tonal hierarchy is preferred over shadow hierarchy.

| Surface | Default visual role |
|---|---|
| surface | page foundation |
| surfaceContainerLow | light grouping / ordinary card |
| surfaceContainer | stronger grouped content |
| surfaceContainerHigh | elevated or selected grouped region |
| surfaceContainerHighest | strongest non-modal surface separation |

Elevation guidance:

- ordinary Card: 0–1dp;
- Top App Bar at rest: 0dp;
- scrolled-under App Bar: only a subtle Material tonal/elevation cue;
- popup/menu: approximately 2–3dp;
- Dialog / modal Bottom Sheet: approximately 3dp.

Dark mode must not substitute deep shadows for tonal differentiation.

## 4. Core component rules

### 4.1 Information density and touch targets

DSM Helper uses medium-high density without fixed-height compression.

Baseline row heights:

- single-line information row: approximately 52dp;
- normal two-line row: approximately 64dp;
- third-line or complex rows: grow naturally with content.

These are baseline layout targets, not hard clipping heights.

All primary interactive targets are at least 48×48dp. A visual icon may be smaller; its hit target may not.

Density is achieved through consistent spacing and information hierarchy, not by shrinking text or touch targets below accessibility limits.

### 4.2 Top App Bar

Default New UI Top App Bar:

- small/compact form;
- body height: 56dp, excluding the actual status-bar inset;
- title: 20sp;
- title alignment: left;
- normal App Bar titles are one line with ellipsis when space is exhausted; a feature needing a longer readable heading places that heading in page content rather than increasing the global App Bar height;
- icon size: 24dp;
- each action hit target: at least 48×48dp;
- elevation at rest: 0dp;
- no glass/blur/gradient.

Action budget:

- maximum two direct actions;
- Back/leading does not consume the two-action budget;
- third and subsequent actions enter overflow;
- when title space becomes insufficient because of a narrow screen, long title or large font, the second direct action moves into overflow;
- icons or title text must not be shrunk to keep a second action visible;
- refresh does not permanently occupy an action slot where pull-to-refresh already provides the primary refresh affordance;
- destructive actions are not persistent direct actions by default.

Long titles prioritize readable identity over visual symmetry. The App Bar does not use center-title behavior.

### 4.3 NavigationBar

Primary navigation contains the five Task 1 destinations and always shows icon + label.

Baseline:

- body height: 72dp baseline, excluding only real system UI insets that cannot safely contain app interactions; it may grow when system font scaling requires it;
- icon: 24dp;
- label: 12sp;
- equal destination widths;
- selected destination: tonal indicator plus the filled form of the corresponding icon when available;
- unselected destinations: outlined icons.

Labels do not disappear for unselected destinations.

No fixed artificial bottom padding is reserved for a gesture handle that is not reported by the system.

If Android reports a real bottom system-bar or gesture exclusion inset, the NavigationBar background may extend behind it for visual continuity, but tappable app content must remain outside unsafe system interaction regions.

### 4.4 Lists and rows

List/Section is the default organization model.

A normal row may contain:

- one leading visual;
- one primary text hierarchy;
- supporting metadata;
- at most one directly exposed high-frequency trailing action where justified.

Additional secondary actions use Menu or Bottom Sheet.

Long names:

- NAS/server/account names may wrap where the context benefits;
- normal file/list titles allow up to two lines;
- metadata does not compete with the primary title for the first line;
- long technical paths may use middle/tail truncation in summary surfaces while full values remain available in detail/context views.

A row is not wrapped in a Card merely because it is clickable.

### 4.5 Divider policy

Dividers are density-dependent, not universal.

- simple lists do not require a divider between every row;
- dense technical lists may use a low-emphasis divider;
- target visual thickness: one physical pixel where practical, never a heavy structural line;
- with a leading icon/avatar, default inset begins at the text/content baseline;
- section boundaries use spacing and tonal surface changes before using thick lines;
- Dark mode dividers use low-contrast outline/surface roles and must not appear luminous.

### 4.6 Cards

Cards are reserved for meaningful grouped hierarchy, including:

- Dashboard summaries;
- Server + Account/device selector presentation;
- a coherent metric group;
- an independently meaningful status group.

Default:

- radius: 14dp;
- elevation: 0–1dp;
- internal padding: 16dp;
- compact approved Card variant: 12dp internal padding;
- internal gaps: 8–12dp.

A feature must not make every file, setting, package, container, task or log entry a Card.

### 4.7 Buttons

Hierarchy:

- Filled Button: the one primary positive action in a visual region;
- Filled Tonal Button: important but non-primary action;
- Outlined Button: parallel secondary action;
- Text Button: low-emphasis action and common Dialog secondary action.

Rules:

- normal minimum height: 48dp;
- radius: 10dp;
- one visual region normally contains only one Filled primary action;
- full-width buttons are reserved for flows that genuinely benefit, such as Login or a final form submit;
- ordinary inline management actions do not become full-width banners;
- destructive styling is reserved for destructive consequences, not generic stop/disable states.

### 4.8 Icon policy and IconButton

New UI default icon language:

- outlined icon for ordinary navigation/action;
- filled variant for selected/strong emphasis where a matching pair exists;
- Material Symbols / Material Icons style is the default visual authority;
- legacy PNG/icon assets do not become the default New UI system.

Sizes:

- normal App Bar / action icon: 24dp;
- compact inline icon: 18–20dp;
- metadata/status icon: 16–18dp;
- all important IconButton hit targets: at least 48×48dp.

A feature may not reduce icon/action size to exceed the global action budget.

### 4.9 TextField and forms

Default field style is filled tonal Material 3.

Baseline:

- radius: 10dp;
- normal minimum interactive height: 52dp baseline, growing with multiline/helper/error content;
- field-to-field gap: 12–16dp;
- multiline fields grow naturally;
- focus uses primary emphasis;
- error uses field-level semantic feedback;
- helper and validation text live with the field rather than being replaced by transient Snackbar messages.

IP, port, OTP, password and path fields remain part of the same visual system. Technical fields may alter keyboard/input behavior and local text presentation, not create another TextField design.

Forms containing fields that can be covered by IME must be scrollable or otherwise able to reveal the active field.

### 4.10 Switch, Checkbox, Radio and selection controls

Use standard Material 3 semantics and basic shape/dimensions rather than a DSM-specific reimplementation.

- Switch: immediately applicable binary state;
- Checkbox: multi-selection;
- Radio: mutually exclusive choices;
- SegmentedButton: small mode/view selection.

A Switch is not used as a disguised navigation row into another settings page.

The interactive region remains at least 48dp even where the visual control is smaller.

### 4.11 Tabs

Roles are distinct:

- NavigationBar: primary five-destination navigation;
- TabBar: page-level peer content categories;
- SegmentedButton: small mode/view selection.

Default TabBar uses restrained Material 3 line/indicator treatment, not large pill tabs.

Few short tabs may divide available width equally. Many or long tabs may scroll horizontally.

### 4.12 Menus

Popup/Menu is appropriate for approximately 2–5 lightweight actions that:

- have short labels;
- do not need explanatory paragraphs;
- do not constitute a full decision workflow.

Menu item interaction height is at least 48dp.

### 4.13 Bottom Sheets

Bottom Sheet is the preferred mobile surface for:

- multiple contextual actions;
- action collections needing icon + text;
- operations requiring more space than a popup but not a new page.

Rules:

- top corners approximately 20dp;
- action rows at least 48dp;
- long content scrolls;
- the sheet is not automatically full-screen;
- a destructive action may originate in the sheet, but a high-risk irreversible confirmation still resolves through Dialog.

Bottom Sheet is not a substitute for normal page architecture.

### 4.14 Dialogs

Dialogs are for:

- explicit decisions;
- destructive/risk confirmation;
- concise blocking input;
- flows that require a choice before continuation.

Rules:

- clearly identify the affected object and consequence;
- do not use vague destructive confirmation text such as “确定吗？”;
- long content scrolls inside a constrained Dialog instead of growing beyond the useful portrait viewport;
- primary/destructive and secondary actions have distinct hierarchy;
- Text Button is suitable for low-emphasis secondary decisions.

### 4.15 Snackbar

Default transient feedback is a floating Snackbar.

Portrait-phone baseline:

- horizontal margin: 16dp;
- visual gap above NavigationBar: 8–12dp;
- one line preferred, two lines allowed when required;
- maximum one action, normally Undo or Retry.

Snackbar does not carry sustained offline, reconnecting, loading or running-task state.

## 5. State presentation rules

### 5.1 Loading

When no valid data exists:

- default to Material progress indication;
- use Skeleton only when the final layout structure is stable and accurately known;
- do not create a custom Skeleton family merely for decorative modernity.

When valid data already exists:

- keep it visible during refresh;
- never replace it with a full-page Skeleton merely because a refresh started;
- use pull-to-refresh, local progress, or a light refresh-state indicator.

Long-running work:

- determinate progress when a meaningful percentage exists;
- indeterminate progress plus explicit task-state text when the percentage is unknowable;
- an infinite spinner alone does not communicate a sustained task state.

Legacy four-rotating-dots loading is not a New UI default.

### 5.2 Empty

Empty means a successful request returned a genuinely empty result.

Default composition:

- restrained icon when useful;
- short title;
- one short explanation when necessary;
- at most one meaningful action.

Do not use a large decorative illustration wall or excessive empty vertical space.

Empty is never a substitute for Loading, Error, Offline or Unknown.

### 5.3 Error

Three scopes are distinguished.

Local error:
- lives in the failed widget/section;
- preserves other valid page content.

Page error:
- only when no usable core page data exists;
- includes concise cause and Retry where meaningful.

Operation error:
- uses field-level, inline or Snackbar feedback as appropriate;
- does not replace a usable page with a full-screen error.

Error red is reserved for real errors/destructive consequences.

### 5.4 Offline, stale and reconnecting

These states are visually and semantically different.

Offline:
- DSM/network is currently unreachable;
- last-valid-data stays visible when available;
- real-time confidence is visibly reduced;
- use neutral/low-emphasis state treatment rather than a full red page.

Stale:
- displayed data is known or suspected to be out of date;
- show explicit text/status, optionally a last-updated timestamp;
- never rely only on a grey color shift.

Reconnecting:
- show lightweight progress plus explicit reconnecting state;
- do not repeatedly enqueue Snackbars;
- do not redirect to Login unless Task 1 authentication semantics classify the session as actually invalid.

### 5.5 Disabled, loading, stale and unavailable

These states must not collapse into the same low-opacity appearance.

Disabled control:
- action is known but currently cannot be invoked;
- use Material disabled foreground/container treatment;
- base guidance: approximately 38% on-surface foreground and approximately 12% disabled container where the component model uses a disabled container.

Loading control:
- operation is in progress;
- interaction is blocked as needed;
- progress is shown;
- label/semantic purpose remains identifiable.

Stale content:
- data remains readable;
- add explicit stale status;
- do not reduce content opacity so far that it resembles disabled UI.

Unavailable capability:
- feature/data is not available in current DSM/context;
- use normal readable secondary text with explicit “不可用”/reason semantics;
- unavailable is not the same as a temporarily disabled action.

### 5.6 Badges and status indicators

Status components prefer:

- concise text;
- a small icon or dot where useful;
- semantic foreground;
- low-saturation tonal container.

Normal healthy status is low emphasis. Warning and Error increase emphasis only as severity increases.

Color is never the only status carrier.

### 5.7 Progress and capacity

Default thickness:

- generic linear progress: 4dp;
- capacity/usage bar: 6dp.

Circular progress baseline:

- inline/control progress: 20–24dp visual size inside a compliant hit/layout region;
- section/page loading progress: 32dp visual size when a larger indicator is needed.

Rules:

- normal progress uses primary or neutral treatment;
- green is not a universal “normal value” color;
- warning/error appears near meaningful risk thresholds defined by the feature contract;
- value/percentage/capacity text remains independently readable;
- bar length/color alone is insufficient.

## 6. Charts and metrics

### 6.1 Time-series baseline

Default monitoring language:

- line width: 1.5–2dp;
- markers hidden by default;
- marker appears for selected/interactive sample when useful;
- area fill only at low opacity;
- no obvious decorative gradient fill;
- grid and axes kept minimal;
- current value/unit placed outside or above the chart where practical.

Multi-series charts must use more than color alone where simultaneous identification matters.

### 6.2 Portrait-phone chart sizing

Normal inline chart height:

- approximately 140–180dp.

This is a baseline range, not a requirement that every chart use identical height.

At approximately 360dp-class width:

- reduce tick/label density before shrinking labels below readable size;
- prevent overlapping axis labels;
- prefer fewer meaningful labels.

No-data charts use Empty semantics. They must not draw a zero-value series that could be interpreted as measured data.

A stale chart stays visible but must be explicitly marked stale rather than appearing to update live.

### 6.3 Feature-level chart freedom

Task 2 does not dictate which data requires line, bar, donut, capacity or another chart.

Feature design may choose chart type based on data semantics, while inheriting the visual rules in this section.

## 7. Adaptive and portrait rules

### 7.1 Formal design target

The formal Task 2 visual target is Android phone portrait.

Primary visual acceptance is for common approximately 360dp-and-up portrait phone widths.

Task 2 does not establish a separate tablet, foldable or landscape design system.

Non-primary window shapes must avoid catastrophic overflow/crash where reasonably possible, but they are not a Task 2 visual acceptance target.

### 7.2 Future wider windows

No NavigationRail breakpoint is frozen in Task 2.

If wider-window support is intentionally expanded later:

- the same five primary destinations and navigation semantics remain;
- a NavigationRail may replace NavigationBar as presentation only;
- that future work must not change Task 1 navigation meaning.

Task 3 must not add wide-screen shell complexity solely in anticipation of this future possibility.

### 7.3 Large system fonts

Primary information remains visible:

- primary title/identity;
- core values;
- primary status;
- primary action.

Adaptation order:

1. allow row/component height to grow;
2. wrap primary/secondary text;
3. move tertiary metadata to another line;
4. move low-priority metadata out of the summary surface when necessary while keeping it available in detail/context;
5. demote the second App Bar direct action to overflow;
6. for table-like data, prefer stacked key-value presentation on narrow/large-font layouts rather than compressing columns.

Do not globally reduce or cap system font scaling to preserve density.

## 8. Android system integration

### 8.1 Edge-to-edge

New UI uses edge-to-edge presentation.

This means:

- background/scroll surfaces may extend behind system bars;
- status/navigation bar presentation remains visually continuous with the app;
- app interaction targets must respect actual unsafe system insets;
- immersive mode is not used;
- system bars remain visible.

No fixed extra “gesture handle” padding is added when Android reports no such unsafe area.

If a real system navigation region exists, the visual NavigationBar background may extend behind it, but app tap targets must remain outside unsafe system interaction zones.

### 8.2 Status bar

Status-bar icon brightness follows the effective Light/Dark surface.

Do not hard-code light icons on light surfaces or dark icons on dark surfaces.

A sticky/scrolled App Bar must not stack multiple competing status-bar protection treatments.

### 8.3 Keyboard / IME

The current product outcome of resize-aware keyboard handling is preserved.

Requirements:

- active form field remains reachable/visible when the IME appears;
- input pages scroll when needed;
- Bottom Sheet input also avoids IME obstruction;
- opening/closing IME does not reset navigation, business state, session state or form state;
- do not disable resize merely to make a screenshot look stable.

## 9. Motion and reduced motion

Motion is fast, functional and restrained.

Baseline durations:

| Motion | Duration |
|---|---:|
| selection/icon/small state | 100–150ms |
| normal component transition | 180–220ms |
| route/Dialog/Bottom Sheet | 220–280ms |

Use standard Material easing unless a component’s platform behavior provides a stronger reason.

Prohibited default motion:

- decorative bounce;
- exaggerated overshoot;
- playful spring chains;
- continuous background animation;
- animation as the only carrier of semantic state.

Reduced motion/system animation reduction:

- remove or make non-essential transitions effectively immediate;
- preserve necessary progress/state indication;
- all meaning remains available without motion.

## 10. Accessibility rules

### 10.1 Touch

Primary touch target minimum:

`48 × 48dp`

A 16/20/24dp icon is visually smaller but remains inside a compliant interactive target.

### 10.2 Contrast and semantic redundancy

Light and Dark are equal product requirements.

Requirements:

- primary text and controls use sufficient contrast;
- low-emphasis metadata remains readable in both modes;
- brand primary `#00A6FF` uses dark `onPrimary` when it directly carries text/icon content;
- status, warning and error never rely on hue alone;
- important icon-only actions require an accessible label/semantic description in implementation.

### 10.3 System scaling

Android system font scaling is respected.

A narrowly constrained element may use a local technical limit only when truly necessary and justified; Task 2 does not authorize a global scale cap.

## 11. Legacy fallback visual isolation

New UI and legacy UI intentionally remain visually distinct during migration.

Rules:

- New UI uses this Material 3 specification;
- legacy fallback pages retain existing legacy ThemeData/presentation;
- New UI `#00A6FF`, grey-blue surfaces, typography, radius and component overrides are not globally injected into legacy pages;
- legacy glass/blur/gradient components are not restyled by Task 2;
- Task 2 does not fix legacy Dark theme;
- Task 2 does not modify legacy production widgets;
- hosted legacy pages must not receive a duplicate New UI App Bar;
- returning from legacy restores the New UI visual environment intact.

Some visual discontinuity at the fallback boundary is acceptable. The goal is controlled isolation and stable behavior, not disguising legacy pages as Material 3.

## 12. Feature freedom boundary

### 12.1 Feature may choose locally

A feature may choose, according to content semantics:

- List versus Section versus an approved Card composition;
- single-line, two-line or naturally growing row;
- chart type;
- presence of a leading icon;
- whether one high-frequency trailing action is justified;
- whether a coherent information group deserves a Card;
- which metadata is secondary versus tertiary;
- wrap, ellipsis, detail view or horizontal scrolling for long content;
- Menu versus Bottom Sheet versus Dialog according to the already-frozen role boundaries;
- local metric emphasis from the approved 20/24/28sp metric tokens.

### 12.2 Feature may not redefine

A feature may not independently redefine:

- brand/default ColorScheme;
- semantic color meaning;
- base font sizes;
- system font scaling policy;
- page horizontal padding;
- spacing scale;
- radius scale;
- elevation hierarchy;
- 52/64dp row-density baseline;
- 48dp touch target;
- 56dp Top App Bar baseline;
- 72dp NavigationBar baseline;
- icon style;
- Button hierarchy;
- TextField baseline;
- Tabs baseline;
- Dialog/Sheet/Menu role boundary;
- Loading/Empty/Error/Offline/Stale/Reconnecting visual language;
- Snackbar baseline;
- chart visual baseline;
- motion timing system;
- edge-to-edge/system-inset principles;
- legacy visual isolation.

If a feature genuinely cannot satisfy its content requirements with these rules, the exception must be documented in that feature’s contract/design with the concrete content constraint. “It looks better” is not an exception criterion.

## 13. Component summary tokens

| Category | Frozen baseline |
|---|---|
| Brand primary | `#00A6FF` |
| Default color source | DSM Helper scheme |
| Dynamic Color | Optional, off by default |
| Page horizontal padding | 16dp |
| Spacing | 2/4/8/12/16/24/32dp |
| Radius | 6/10/14/20dp |
| Single-line row | ~52dp |
| Two-line row | ~64dp |
| Touch target | ≥48×48dp |
| Top App Bar | 56dp |
| Top App Bar title | 20sp, left aligned |
| Direct App Bar actions | max 2, second may overflow |
| NavigationBar | ~72dp body |
| Navigation icon | 24dp |
| Navigation label | 12sp, always visible |
| Card radius | 14dp |
| Card padding | 16dp; compact variant 12dp |
| Card elevation | 0–1dp |
| Button minimum height | 48dp |
| TextField minimum | ~52dp |
| TextField style | filled tonal |
| Chart line | 1.5–2dp |
| Inline chart height | ~140–180dp |
| Linear progress / capacity bar | 4dp / 6dp |
| Snackbar | floating, 16dp side margin |
| Motion | 100–150 / 180–220 / 220–280ms |

## 14. Design-gap status

All Task 2 global visual design gaps required to unblock Task 3 are resolved.

Explicit user decisions frozen in this Task include:

1. DSM Helper-owned Material 3 scheme rather than Dynamic Color by default.
2. Dynamic Color remains opt-in.
3. Top App Bar titles are left-aligned.
4. Medium-high density uses flexible 52/64dp row baselines.
5. Compact Material 3 typography scale.
6. Restrained 6/10/14/20dp radius system.
7. 4dp-family spacing system with 16dp phone content padding.
8. Tonal surfaces over shadow depth.
9. Five NavigationBar labels remain visible.
10. Semantic colors are restrained; normal state is not saturated.
11. Outlined icons by default, filled for selection/emphasis.
12. Up to two direct App Bar actions with width-driven demotion.
13. Filled tonal TextField baseline.
14. Thin-line chart language.
15. Density-dependent inset divider policy.
16. Material 3 button hierarchy.
17. Edge-to-edge with actual system insets only.
18. Large-font progressive metadata degradation.
19. TabBar for peer content categories.
20. Portrait phone only as the current formal adaptive target; no premature NavigationRail implementation.
21. Decision Dialog / contextual Bottom Sheet boundary.
22. Progress-first Loading with Skeleton only where structural accuracy justifies it.
23. Approximately 72dp compact NavigationBar without artificial gesture-handle padding.
24. Floating Snackbar.
25. 56dp compact Top App Bar.
26. Fast functional motion.
27. Material 3 semantic system + DSM Helper compact density tokens.
28. Final brand accent changed from the legacy blue to `#00A6FF`, with low-saturation grey-blue daily surfaces.

No unresolved visual semantic gap remains that requires a user product decision before Task 3.

## 15. Task 2 boundaries

Task 2 does not:

- implement ThemeData;
- implement Dynamic Color;
- create `lib/new_ui/**`;
- implement New Shell;
- implement LegacyPageHost;
- modify legacy production UI;
- fix legacy Dark theme;
- create feature pages;
- define detailed feature business operations;
- change Task 1 global contracts;
- enter Task 3.

## 16. Task 2 Exit Gate criteria

Task 2 is ready to exit when all of the following are true:

- this remains the only authoritative global Visual Design Specification;
- default Light/Dark ColorScheme roles are frozen;
- typography is frozen;
- spacing/radius/surface hierarchy is frozen;
- NavigationBar and Top App Bar baselines are frozen;
- list/card/button/form/control/tab/dialog/sheet/menu/Snackbar rules are frozen;
- Loading/Empty/Error/Offline/Stale/Reconnecting are distinct and frozen;
- chart/metric visual language is frozen;
- Android system bars, edge-to-edge, actual safe insets and IME behavior are frozen;
- portrait-phone adaptive boundary and font-scaling behavior are frozen;
- accessibility/touch rules are frozen;
- Material 3 and legacy visual isolation is explicit;
- feature freedom and prohibition boundaries are explicit;
- no Task 3-blocking Design Gap remains;
- no production code is changed by Task 2.

## 17. Compact governing summary

The approved visual system can be summarized as:

> Material 3 defines semantics; DSM Helper tokens define density.  
> `#00A6FF` carries brand emphasis; low-saturation grey-blue surfaces carry daily UI.  
> Lists carry density; Cards carry grouping; color carries semantics; shadow does not carry structure.  
> Portrait phone is the current target; unused display classes do not justify premature shell complexity.  
> Last-valid context stays visible through transient failure; state meaning is explicit and never color-only.  
> Legacy fallback stays visually legacy and isolated until each feature is intentionally replaced.
