# DSM Helper Modern UI — Project Specification

> Status: Review Candidate
> Date: 2026-10-07
> Repository: qyxx2/dsm_helper
> Integration branch: modern-ui
> Task branch: feature/t1-spec-contracts
> Legacy baseline: dev@8c104e9a783a1acaf366a250e5fcd1d623f14eb2
> Authority level: Product-level specification for the Modern UI project

## 1. Purpose

DSM Helper Modern UI is an Android-first, portrait-phone NAS management interface built on the existing DSM Helper implementation.

The project replaces the presentation layer progressively with a consistent Material 3 UI while preserving mature DSM behavior and minimizing risk to existing API, model, provider, database, utility, session, and feature logic.

The project is not a rewrite of the DSM client stack. Its central rule is:

Capability parity, not UI parity.

Existing legacy business capabilities that remain valid should continue to exist in the Modern UI. Their layout, interaction pattern, visual presentation, and navigation placement may be redesigned.

## 2. Product Goals

The Modern UI must provide:

- a unified Material 3 management interface;
- medium-high information density appropriate for NAS administration;
- first-class Light and Dark themes;
- predictable Android navigation and lifecycle behavior;
- clear separation between network connectivity and authentication state;
- stable presentation of the last valid data during refresh or temporary connection loss;
- progressive migration from legacy pages without breaking unported features;
- direct reuse of mature legacy implementation wherever possible;
- explicit global contracts that later feature work must inherit;
- an implementation path that remains buildable, testable, reversible, and suitable for real-device validation after each feature migration.

## 3. Non-Goals

This project does not, by default:

- rewrite the DSM SDK or API layer;
- replace the existing provider/state-management architecture;
- refactor the Drift database;
- redesign all legacy models;
- clean unrelated legacy warnings or formatting;
- modernize legacy pages that are still used only as fallback;
- reproduce DSM Web desktop UI;
- preserve legacy visual layout one-to-one;
- support tablet, landscape, foldable, desktop, or NavigationRail layouts in the current scope;
- define every future feature's detailed UI in Task 1;
- freeze exact colors, typography values, spacing, radius, elevation, icon size, or animation duration in Task 1.

Pixel-level visual tokens belong to Task 2 — Visual Design Specification.

## 4. Platform Scope

### 4.1 Supported presentation target

The current product scope is:

- Android;
- phone;
- portrait orientation only.

The Android app should lock the Modern UI experience to portrait for the current project scope.

No alternative layout is required for landscape, tablet, foldable, or desktop-class screens. Future support for those form factors is a separate scope decision.

### 4.2 Existing Flutter/Android baseline

The Modern UI builds on the verified Task 0 baseline. Task 1 does not introduce a new Flutter, Java, Android Gradle, Kotlin, compileSdk, targetSdk, or signing migration unless a later verified blocker requires it.

## 5. Legacy-First Reuse Policy

Modern UI work follows this order:

1. Directly reuse the existing legacy implementation.
2. If direct reuse is insufficient, add the smallest adapter necessary.
3. Modify legacy implementation only when a real blocker remains.

A legacy file being large, old, stylistically inconsistent, or architecturally unattractive is not sufficient reason to rewrite it.

Legacy areas remain frozen by default unless one of the following is true:

- the New UI cannot use the required capability through a smaller integration point;
- a real build blocker exists;
- a real bug blocks the active feature;
- a new feature requires a minimal legacy-facing entry point;
- a compatibility or safety issue prevents continued use.

Any legacy modification must stay minimal, be explained by a concrete blocker, and include appropriate regression validation.

## 6. Migration Architecture

### 6.1 New shell, progressive feature replacement

The project uses:

New UI Shell + Legacy fallback + progressive feature migration.

The New UI Shell owns the top-level product experience from the beginning. Individual features then migrate one at a time.

For a migrated feature:

New UI Shell → New Feature UI → reused legacy API/provider/model/business capability where applicable.

For a not-yet-migrated feature:

New UI Shell → LegacyPageHost → existing Legacy Feature.

There must not be two competing top-level application shells.

### 6.2 LegacyPageHost boundary

LegacyPageHost is an integration boundary, not a visual restyling layer.

It may coordinate only what is necessary for coexistence, such as:

- Android/system-bar integration;
- Back navigation handoff;
- navigation context;
- theme isolation;
- other minimal shell-to-legacy boundary concerns proven necessary by implementation.

It must not:

- place a second New UI App Bar around legacy pages;
- restyle legacy padding, cards, or internal layout merely for appearance;
- force Material 3 components into legacy page internals;
- change legacy behavior without a feature-specific reason.

Legacy fallback exists for behavior compatibility, not visual camouflage.

### 6.3 Removal gate

A legacy page must not be removed merely because a new page exists.

The expected lifecycle is:

Legacy available → New UI feature implemented → automated contract/regression validation → real Android device acceptance when required → New UI becomes the formal entry → fallback removal considered separately.

## 7. Top-Level Information Architecture

The Modern UI has five primary destinations:

1. 概览
2. 文件
3. 应用
4. 任务
5. 我的

The primary navigation uses a compact Material 3 NavigationBar.

All five destinations always show icon and label. The selected state uses a restrained Material 3 tonal indicator rather than an oversized pill.

Normal tab switching preserves an independent navigation stack for each primary tab.

## 8. Startup, Resume, and Device-Switch Navigation

### 8.1 Cold start

When the existing launcher-selection setting is disabled and a usable saved login/session can be restored:

Cold start → restore current account/session → 概览 root.

The app does not restore an old deep page such as a File Station directory, container detail, settings page, task subview, or legacy detail screen after a cold start.

### 8.2 Launcher-selection setting

The existing setting that chooses whether startup first shows server/account selection remains supported and is off by default.

When enabled:

Cold start → server/account selection → selected device/account → main shell.

### 8.3 Background resume

A normal Android background-to-foreground lifecycle transition preserves the current tab, current page, and normal navigation context.

Resume may trigger refresh according to data freshness, but it does not reset navigation merely because the app became active again.

### 8.4 Device/account switch

The current release does not treat multi-NAS use as a complex workspace system.

Existing multi-device capability is retained in the simplest form.

After a successful device/account switch:

- current NAS-specific UI state is cleared;
- old NAS file paths, details, task views, and other NAS-specific navigation state are not retained;
- the app returns to 概览 root for the newly selected context.

The project does not maintain independent navigation workspaces per NAS.

## 9. App Bar Contract

The five primary pages use a compact Material 3 Top App Bar.

No Large TopAppBar is used for the main shell.

### 9.1 Information priority

When horizontal space is constrained, the priority is:

1. page title;
2. abnormal connection/authentication state;
3. global notification entry;
4. NAS name/context;
5. page-specific auxiliary action.

The NAS name is weak context and may be truncated or omitted when space or large system font scaling requires it. It must not make the page title unreadable.

### 9.2 Action budget

A normal primary-page App Bar has a strict action budget:

- one global DSM notification entry;
- at most one page-specific high-frequency direct action.

A page does not add controls merely because an action slot is available.

Additional actions use overflow, menu, Bottom Sheet, or a dedicated mode.

Search, selection, edit, and other temporary modes may replace the normal App Bar. They do not have to preserve every global action while active.

### 9.3 Connection status

Normal connected state should not create persistent green status noise.

When needed, the App Bar may show concise abnormal context such as:

- 离线
- 重连中…
- 需要重新登录

Authentication failure and connection failure are not interchangeable states.

## 10. Global DSM Notifications

DSM notifications are a global shell capability.

The stable entry is the App Bar notification icon.

Rules:

- unread state may use a restrained badge;
- no badge is shown merely to indicate normal state;
- the notification entry remains globally understandable rather than belonging to a single primary tab;
- important actionable notifications may also be surfaced in the Overview abnormal-summary area;
- ordinary notifications do not fill the Overview page.

The legacy notification source and reading logic should be reused whenever practical.

## 11. Overview

The Overview answers four questions:

- Which NAS context am I looking at?
- What is its current resource state?
- Is anything important wrong?
- Where are my highest-frequency entry points?

It is not a dumping ground for all DSM information.

The preferred order is:

1. compact device summary;
2. core resource rows;
3. abnormal summary, only when needed;
4. shortcuts;
5. configurable extension widgets.

### 11.1 Device summary

The device summary is a low-height horizontal summary strip, not a hero card.

It displays only:

- left: device name;
- right: uptime.

It does not normally display model, DSM version, IP address, background image, or a large health hero.

Connection problems continue to use the App Bar state rather than turning this strip into a duplicate warning panel.

### 11.2 Core resource area

CPU, memory, and storage use one consistent row-oriented visual language. They are not three independent large cards.

Information examples are guidance only and are conditional on real data exposed by the current DSM/legacy implementation.

CPU may display:

- current usage;
- 1-minute / 5-minute / 10-minute load when available;
- temperature when available.

Memory may display:

- current usage;
- used memory;
- remaining memory.

Storage may display:

- volume/storage name;
- disk/storage type;
- temperature;
- other concise capacity information when supported and useful.

If multiple storage objects exist, the same presentation pattern repeats for each object.

No field is mandatory merely to preserve symmetry. Missing data is omitted rather than filled with fabricated, inferred, zeroed, or misleading placeholders.

The exact data authority for each field is determined by the Task 1 legacy inventory and later feature contract work.

### 11.3 Abnormal summary

The Overview does not permanently show an “everything is healthy” card.

The abnormal-summary area exists only when there is a real issue that is actionable or meaningfully informative.

Examples include:

- storage capacity risk;
- an important container failure;
- an important DSM notification.

Entries are ordered by severity/importance rather than by data-source grouping and should navigate to the actual source feature.

Ordinary logs do not become warnings merely to populate this section.

Offline/reconnecting state remains a shell/App Bar concern and is not duplicated here.

### 11.4 Shortcuts

The Overview contains a fixed shortcut region whose content is user-configurable.

On phone portrait it supports up to four shortcuts in one row.

Shortcut content:

- includes only capabilities that are actually available on the current DSM and supported by DSM Helper;
- is configured independently from the Applications “常用” section;
- does not reorder itself automatically based on usage frequency.

The shortcut region itself is part of the core Overview structure and is not removed entirely.

### 11.5 Extension widgets

The Overview uses:

fixed core summary + configurable extension widgets.

Core summary cannot be removed.

Extension widgets are edited through an explicit “编辑概览” mode.

That mode may support:

- show/hide;
- drag reordering;
- adding currently supported modules.

Normal Overview browsing does not expose drag handles or deletion affordances.

The implementation must reuse existing widget/settings semantics when possible and add only the minimum adapter required after contract audit.

## 12. File Station

File Station is a first-class Modern UI feature.

### 12.1 View modes

Default view:

medium-high-density list.

The user may switch between list and grid.

Both modes must preserve the same fundamental browsing, selection, sorting, and file-operation capability. Grid is not a reduced read-only mode.

Grid is especially useful for image/video-oriented directories.

### 12.2 Path navigation

File navigation uses:

compact breadcrumb + Android Back.

Breadcrumbs provide path context and clickable ancestors. Older ancestors may collapse behind an ellipsis.

Breadcrumbs do not replace Android Back semantics.

### 12.3 Tool placement

Search is the primary candidate for File Station's single direct App Bar action.

Other browsing tools such as sorting, filtering, list/grid switching, refresh, and secondary controls belong in a unified menu or Bottom Sheet rather than a permanent toolbar.

### 12.4 Normal item interaction

In normal mode:

- tap opens a file or enters a directory;
- swipe left or right enters selection mode and selects that item;
- long press opens that item's secondary/context operation menu.

There is no permanent per-file overflow button.

### 12.5 Selection mode

After selection mode begins:

- tap toggles item selection;
- additional swipes are not required;
- Back exits selection mode before navigating away;
- the selection header shows a clear exit action, selected count, and select-all action;
- a bottom batch-action area exposes high-frequency operations such as copy, move, download, and more.

Long-pressing a selected item in selection mode opens the operation menu for the current selected set.

Available operations remain capability-driven by the legacy implementation. Examples may include copy, move, delete, download, properties, share, and rename.

Invalid operations for the current selection are hidden or disabled according to feature contract semantics.

### 12.6 Selection visuals and identity

Selection uses a restrained tonal highlight across the full list row or full grid tile.

The layout must not reserve a permanent empty checkbox gutter, and entering selection must not make file content jump horizontally.

List/grid switching preserves selection.

Sorting preserves selection by object identity, not by list index.

Selection does not persist across directories by default.

### 12.7 File row density

Default list presentation prioritizes:

- first line: file/folder name;
- second line: one compact metadata line composed from useful available attributes such as size, type, or modified time.

A third line is not added by default merely to expose more metadata.

## 13. Applications

The Applications page contains:

- 常用;
- 全部应用.

### 13.1 Application source

All applications are derived from DSM's actual available application set and filtered to capabilities DSM Helper supports.

The existing DSM application order should be inherited as far as practical.

The Modern UI does not create a second competing global application-order authority.

### 13.2 All applications

Phone portrait uses a fixed four-column launcher grid.

Each application uses:

- an icon sized close to a normal Android launcher icon;
- a label beneath the icon, up to two lines when required.

Applications are not individually wrapped in cards.

The grid avoids the legacy pattern of three oversized icons with excessive whitespace.

### 13.3 Favorites

The “常用” section is a local convenience layer.

Users may pin and reorder favorites manually.

The intended visible maximum is eight applications, or two rows at four columns.

Favorites do not change the DSM base order.

Applications unavailable on the current NAS are not shown as active shortcuts.

## 14. Tasks

The primary “任务” destination refers only to DSM Helper's own:

- 下载;
- 上传;
- 备份.

DSM Download Station remains an application and is not merged into this task center.

The Tasks page retains three compact internal tabs for these sources.

Task lists prioritize active, waiting, failed, and recently relevant work.

Progress is displayed only when real underlying information exists.

A row may expose one genuinely high-frequency direct action. Secondary operations use context actions.

Normal running work is not treated as an error badge. Failure or user-attention states may use abnormal semantics.

## 15. My / Settings

“我的” is the low-frequency global management area, not a social/profile page.

It uses one visually continuous sectioned-management page rather than a collection of unrelated large cards.

Expected sections include, when supported by existing capabilities:

- account/device management;
- current device/account switching;
- Synology shutdown/restart controls;
- existing “助手设置”;
- appearance/theme controls;
- other low-frequency app/account settings;
- About.

Sections are separated through headings, spacing, and restrained dividers while keeping one unified background, typography, icon, and row system.

Dangerous operations use semantic emphasis but do not become oversized red panels.

## 16. Server / Account Selection and Management

The server/account page uses large device cards as an intentional exception to the list-first rule.

Each device card remains visually simple and displays only:

- device name;
- IP/address;
- user.

The card does not contain CPU gauges, memory gauges, storage dashboards, or DSM login background imagery.

Interaction:

- tapping anywhere in the card body enters that device;
- long press opens secondary actions;
- secondary actions include edit and delete.

A permanent per-card overflow button is not required.

The exact mapping when one server has multiple saved accounts remains governed by existing database/legacy semantics and must be resolved in the Task 1 inventory/contract work rather than invented in this product specification.

## 17. Login and Authentication UI

### 17.1 Login presentation

The Modern UI uses a unified Material 3 login flow.

Authentication capability must remain equivalent to valid legacy behavior, including:

- account;
- password;
- default-account semantics;
- OTP / 2FA;
- email verification when returned by DSM;
- actual DSM authentication errors.

DSM identity information may be selectively shown, including:

- hostname;
- useful welcome text;
- a reasonably sized logo when appropriate.

The Modern UI does not use the DSM custom login background as the controlling full-screen visual identity.

Decorative DSM Web presentation is not itself a required capability.

### 17.2 OTP / 2FA flow

Authentication is a continuous staged flow.

Stage 1: account/password.

If DSM requires additional verification, the same authentication experience proceeds to Stage 2 for OTP or email verification.

Rules:

- Stage 2 does not force the user to re-enter account/password;
- OTP errors keep the user in the verification stage;
- the user can return to the credential stage;
- network errors and verification errors remain distinct;
- the existing authentication protocol and error semantics remain the authority.

## 18. Data-State Semantics

The Modern UI uses:

last valid data + localized state feedback.

### 18.1 Initial state

When a page has no data yet:

- show loading or an appropriate skeleton.

### 18.2 Refresh with existing data

When valid data already exists:

- keep that data visible;
- indicate refreshing lightly;
- replace it only when a newer valid result arrives.

Refreshing must not clear the page merely to create a loading state.

### 18.3 Empty state

Empty means the request succeeded and the real result is empty.

It is not used as a substitute for loading, error, or offline state.

### 18.4 Partial failure

A failed widget, region, or data source should affect only the relevant region when the rest of the page remains usable.

One failed subrequest must not automatically replace an otherwise usable page with a full-screen error.

### 18.5 Offline state

On connection loss:

- preserve the last valid data where available;
- make it clear the data is stale/offline rather than real-time;
- keep the user in the current product context when possible.

Old data may remain visible, but it must never pretend to be live data.

## 19. Refresh Contract

The existing legacy refresh-period setting remains the authority for automatic refresh cadence unless later audit proves a blocker.

The Modern UI also provides a consistent explicit manual refresh gesture, normally pull-to-refresh, for refreshable primary content.

Rules:

- automatic refresh preserves last valid data;
- manual refresh preserves last valid data;
- an operation that changes data should refresh the affected region proactively;
- the App Bar does not permanently consume a refresh action slot when pull-to-refresh is appropriate;
- offline manual refresh may attempt reconnection/request again, but failure retains old data and remains offline rather than returning to login.

## 20. Network and Authentication Separation

This is a global product contract.

Network/DSM connection failure is not authentication invalidation.

Connection failures include conditions such as:

- NAS powered off;
- Wi-Fi interruption;
- timeout;
- DNS/IP reachability failure;
- temporarily unreachable DSM.

Expected UI behavior:

- retain the current page/context;
- retain last valid data when available;
- show offline or reconnecting state;
- allow recovery when the connection returns.

A connection problem must not automatically clear credentials/session state or send the user to Login.

Only a real session/authentication invalidation enters the reauthentication flow and may show “需要重新登录”.

## 21. Short-Term Feedback and Decisions

New UI uses Snackbar as the primary transient feedback mechanism.

Examples:

- completed action with no further decision → Snackbar;
- reversible action → Snackbar with Undo;
- retryable failure → Snackbar with Retry;
- user decision/risk confirmation → Dialog;
- sustained state such as offline, reconnecting, running task, loading, or empty → inline/page state, not repeated Snackbar.

Duplicate identical errors should be suppressed or deduplicated so they do not repeatedly flood the user.

Legacy pages may retain their existing Toast behavior while they remain legacy fallback pages.

## 22. Dangerous Operations

Confirmation is risk-tiered.

### 22.1 Low risk / reversible

Execute directly when appropriate and provide Undo where meaningful.

### 22.2 Medium risk

Use a standard confirmation for operations such as an ordinary single-file delete, stopping a container, or clearing task history when the feature contract considers confirmation appropriate.

### 22.3 High risk

High-impact actions such as batch deletion, container deletion, NAS shutdown, or NAS restart require a clear confirmation that identifies:

- the actual object/device;
- the consequence.

For NAS power actions, the current NAS name must be visible in the confirmation.

Avoid vague confirmation text such as “确定吗？”.

Do not add typed device-name confirmation, password re-entry, or other ceremony unless the existing DSM/legacy contract requires it.

## 23. Android Navigation and System Interaction

New UI follows Android-native navigation semantics while legacy pages preserve compatibility behavior behind their boundary.

Back handling priority is:

1. keyboard / popup / Bottom Sheet / Dialog;
2. temporary mode such as selection, search, or edit;
3. current secondary page;
4. current tab root;
5. app/system exit behavior.

File selection mode exits before directory/page navigation.

The Modern UI should not force immersive mode.

Existing Android intents and integrations, such as supported external-file or torrent flows, remain capability requirements when their corresponding feature is migrated.

## 24. Theme and Visual Direction

### 24.1 Overall expression

The Modern UI is a restrained Material 3 management interface.

Information hierarchy is created primarily through:

- typography;
- spacing;
- surfaces;
- grouping;
- semantic state.

The design avoids excessive:

- colorful cards;
- deep shadows;
- gradients;
- decorative blur;
- background animation;
- consumer-style oversized empty space.

### 24.2 Theme modes

Supported modes:

- System;
- Light;
- Dark.

Default: System.

Light and Dark are equal product requirements.

Changing theme affects presentation only. It must not reset business state, navigation, selection, or trigger unrelated data refresh.

### 24.3 Color source

DSM Helper defines its own default Material 3 ColorScheme.

Android Material You / Dynamic Color may be an optional color source.

Dynamic color must not redefine semantic error, warning, success, or similar state meaning.

### 24.4 Density and grouping

The product uses medium-high density.

Touchability and readability take priority over forcing a fixed compact height.

The general organization rule is:

List/Section first; cards only when they add meaningful hierarchy.

Cards are suitable for summary/grouped information and the explicit server-device selector exception.

They are not the default unit for every file, setting, task, container, package, log, or application row.

## 25. Application-Wide Interaction Consistency

General list behavior is:

- item body → detail or primary behavior;
- at most one direct high-frequency trailing action where justified;
- secondary actions → context menu or Bottom Sheet.

A page must not expose a row full of Edit/Delete/Start/Stop/More actions by default.

File Station intentionally has its own frozen interaction model described earlier.

## 26. Bottom Sheet, Menu, Dialog, and Empty-State Roles

Bottom Sheet is preferred for multiple contextual actions or operations needing more space without deserving a new page.

Popup/menu is suitable for a small number of light actions.

Dialog is for decisions, confirmations, and concise input where appropriate.

Not every action becomes a Dialog.

Empty states stay restrained:

- concise icon when useful;
- short explanation;
- one meaningful action when one exists.

Large decorative empty-state illustration walls are not a product requirement.

## 27. Font Scaling and Accessibility

The Modern UI respects Android system font scaling.

The app must not globally force textScale to 1.0 merely to preserve compact layout.

At larger system font sizes:

- secondary content may wrap;
- low-priority secondary fields may be omitted;
- rows may grow in height;
- primary labels and controls remain readable and usable.

A local cap is acceptable only for a narrowly constrained element where unconstrained scaling is technically impossible; global disabling is not acceptable.

## 28. Motion

Motion is restrained and functional.

Appropriate uses include:

- navigation transitions;
- Bottom Sheet appearance;
- selection-mode transitions;
- refresh feedback;
- connection-state changes;
- list state changes.

Avoid decorative hero motion, exaggerated bounce, or continuous background animation.

Respect reduced-motion/system animation settings where the platform exposes them.

Exact durations and easing belong to Task 2.

## 29. Visual Specification Boundary

Task 1 freezes product-level visual behavior, not pixel tokens.

Task 2 must define the single authoritative Visual Design Specification for:

- ColorScheme values;
- typography scale;
- spacing scale;
- radius;
- elevation/surface;
- icon policy;
- component density;
- NavigationBar details;
- TopAppBar details;
- cards;
- forms;
- dialogs;
- Bottom Sheets;
- loading/empty/error visuals;
- system bars;
- detailed light/dark behavior;
- exact system-font scaling rules;
- motion durations/easing;
- page/component visual references where required.

Task 2 must remain consistent with this Project Specification and may not silently redefine its product semantics.

## 30. Global Product Invariants for Contract Matrix

Task 1 Global Contract Matrix must encode and mechanically validate, where practical, at least the following product-level invariants.

### 30.1 Navigation

- primary-tab switching preserves independent tab navigation stacks;
- cold start with restored login lands on 概览 root unless launcher-selection mode is enabled;
- normal background resume preserves current navigation;
- device/account switch clears old NAS-specific UI context and lands on 概览 root.

### 30.2 Network/authentication

- connection failure does not equal session invalidation;
- temporary offline state does not force Login;
- real authentication invalidation enters reauthentication.

### 30.3 Theme

- New UI Material 3 theme does not unintentionally alter legacy fallback presentation;
- theme switching changes presentation only and preserves business/navigation state.

### 30.4 Refresh

- refresh does not clear last-valid data before the new result is known;
- stale data is visually distinguishable from live data.

### 30.5 Legacy handoff

- New UI Shell remains the only primary shell;
- unmigrated routes can reach legacy pages through the defined fallback boundary;
- legacy pages remain usable until their replacement passes the required gate.

### 30.6 File selection

- sorting preserves selection by object identity;
- list/grid switching preserves selection by object identity;
- Back exits selection mode before normal navigation;
- selection does not silently leak across directories.

These are product-level invariants. Feature tasks may refine them but may not redefine them.

## 31. Legacy Interface / Protocol Inventory Requirements

Task 1 must inspect real current code before claiming a reusable interface.

At minimum the inventory covers:

- lib/apis/**;
- lib/models/**;
- lib/providers/**;
- lib/database/**;
- login/auth/session code;
- server/account persistence and selection;
- home/dashboard and resource/status sources;
- notifications;
- file operations and transfer paths;
- applications discovery/order;
- navigation and startup;
- theme boundaries;
- Android intent/platform integration used by current features.

Each relevant capability should be classified with a reuse disposition such as:

- Direct reuse;
- Minimal adapter;
- Feature-specific audit required;
- Real blocker;
- Legacy-only presentation.

The inventory freezes capability/behavior boundaries, not accidental private method names.

## 32. Contract Gap Policy

If actual code and product specification do not provide one unambiguous contract, the gap must be explicit.

Two categories are distinguished:

Product semantic gap:
- the intended user-visible behavior itself is not decided;
- requires a product decision before implementation may guess.

Technical interface gap:
- intended behavior is already clear;
- the existing code does not expose a safe interface/lifecycle needed to implement it;
- must be recorded as a technical blocker and resolved explicitly rather than bypassed through fragile private-state coupling.

Only gaps that block the active task must be resolved immediately. Non-blocking feature-specific gaps may remain for the corresponding feature audit.

## 33. Testing and Acceptance Strategy

Modern UI validation is contract-driven rather than implementation-detail-driven.

### 33.1 Unit / pure logic

Use for state transformation, filtering, ordering, selection identity, view-model logic, and connection/authentication classification.

### 33.2 Widget / component

Use for presentation contracts such as:

- loading/stale/empty/error;
- App Bar overflow/action budget;
- selection mode;
- theme;
- large font;
- Snackbar/Dialog behavior;
- NavigationBar state.

### 33.3 Relationship / integration

Explicitly test cross-module invariants, for example:

- device switch → data-source authority changes → old NAS UI state cleared → navigation resets;
- network timeout → offline → not logout;
- theme change → current navigation preserved;
- New Shell → LegacyPageHost → legacy feature remains usable.

Passing isolated module tests is not sufficient proof of a cross-module contract.

### 33.4 Real Android device gate

Real-device validation is required when a migrated feature depends on actual Android/DSM behavior.

Relevant checks include:

- portrait layout;
- Android Back;
- keyboard;
- system bars;
- background/resume;
- App Bar overlap at real widths;
- touch targets;
- scrolling;
- Light/Dark;
- system font scaling;
- real DSM connection;
- login and OTP where available;
- network interruption/recovery;
- Legacy fallback;
- file/intent behavior;
- visual density and interaction feel.

Real-device testing is a feature/replacement gate, not a requirement to manually re-run the entire product after every small commit.

## 34. Compatibility and Extension Boundaries

New UI success must not depend on breaking legacy consumers.

During coexistence:

- migrated entries use New UI;
- unmigrated entries remain usable through fallback;
- shared legacy changes must consider both old and new consumers;
- no second conflicting authority is introduced for a mature capability without a proven need;
- fallback is retained until replacement acceptance.

Future features inherit global contracts from this specification and the Task 1 matrix.

A feature may define its own operations, UI, state, and error semantics only where those details are feature-specific.

A feature must not independently redefine global rules such as:

- offline versus logout;
- theme effects;
- device-switch reset semantics;
- primary App Bar action budget;
- top-level navigation structure.

## 35. Task 1 Deliverables and Boundaries

Task 1 consists of three coordinated authoritative outputs:

1. this Project Specification — what the Modern UI product is;
2. Global Interface / Protocol Inventory — which real legacy capabilities exist and how the New UI may depend on them;
3. Global Contract Matrix — which cross-module behaviors must remain invariant and how they are validated.

This specification intentionally does not define:

- every future feature's complete UI;
- every feature's batch plan;
- exact visual design tokens;
- a rewritten DSM response model;
- speculative abstractions not justified by real code;
- detailed semantics of feature operations that have not yet been audited.

## 36. Task 1 Exit Criteria

Task 1 is ready to exit only when:

- the Project Specification is approved;
- the Global Interface / Protocol Inventory is based on actual repository code;
- the Global Contract Matrix is complete enough to support Task 2 and Task 3;
- blocking global Contract Gaps are resolved or explicitly handled;
- New UI/legacy theme and navigation isolation are defined;
- no large legacy refactor was introduced merely to complete documentation.

After Task 1, later work should be able to answer without guessing:

1. What product is DSM Helper Modern UI?
2. How do New UI and legacy UI coexist and migrate?
3. What must be reused, and when may legacy code be changed?
4. Which cross-module behaviors are global non-negotiable contracts?
5. Which details belong to later feature-specific design rather than Task 1?

## 37. Approved Design Principles

The approved design can be summarized as:

- Shell is new from the beginning; features migrate one by one.
- Mature legacy capability is reused unless a real blocker proves otherwise.
- Capability parity, not UI parity.
- Legacy fallback preserves behavior; it is not visually disguised as New UI.
- Medium-high-density Material 3, with restrained management-oriented presentation.
- List first; cards only where hierarchy benefits from them.
- Old data may remain visible, but it must never masquerade as live data.
- Network state, authentication state, navigation state, and page-data state are distinct.
- The five-tab information architecture is the stable product shell.
- Task 1 freezes product semantics; Task 2 freezes visual tokens; feature tasks freeze feature-specific contracts.
