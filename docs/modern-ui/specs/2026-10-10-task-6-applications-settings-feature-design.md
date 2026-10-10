# DSM Helper Modern UI — Task 6 Applications Hub + Settings Shell Feature Design

> Status: Approved preflight basis — Batch planning authorized  
> Date: 2026-10-10  
> Task: Task 6 — Applications Hub + Settings Shell  
> Branch: `feature/t6-applications-settings`  
> Integration base: `modern-ui@1e0c74b9a85b7bd2d0c5f49fc5f7661d7f638c4c`  
> Architecture path: Thin Adapter / progressive shell migration

## 1. Purpose

Task 6 replaces the generic Modern placeholders for **应用** and **我的** with two real Material 3 root pages while preserving the mature legacy application/settings detail pages behind `LegacyPageHost`.

Task 6 is a hub/shell migration, not a migration of every application or every settings detail. It must establish stable discovery, favorites, routing and settings-entry semantics that later Tasks 10–14 can reuse without creating a second DSM application-order authority, a second authentication authority, or a second global preference architecture.

## 2. Authoritative Inputs

Task 6 inherits and must not redefine:

- `docs/modern-ui/2026-10-06-dsm-helper-modern-ui-master-plan.md`
- `docs/modern-ui/specs/2026-10-07-dsm-helper-modern-ui-spec.md`
- `docs/modern-ui/specs/2026-10-07-dsm-helper-modern-ui-visual-design.md`
- `docs/modern-ui/contracts/2026-10-07-global-interface-protocol-inventory.md`
- `docs/modern-ui/contracts/2026-10-07-global-contract-matrix.md`
- Task 3 shell / `LegacyPageHost` / context isolation
- Task 4 Server + Account / logout / reauthentication authority
- Task 5 accepted Overview and shell integration
- `APK-IDENTITY-01`
- `CI-DOCS-01`

Task 6 adds only feature-level decisions needed by Applications and Settings.

## 3. Repository Facts Confirmed by Preflight

### 3.1 Applications

Current reusable authorities:

- DSM application ordering comes from `InitDataModel.userSettings.desktop.validAppviewOrder`, falling back to `appviewOrder`.
- `ApplicationEnum` is legacy evidence for locally supported application identities, labels and icons.
- current legacy `Applications` filters DSM entries by `ApplicationEnum`.
- application detail implementations already exist as legacy pages and must continue through `LegacyPageHost`.

Confirmed defects/ambiguities that Task 6 must not inherit blindly:

1. `ApplicationEnum.logCenter` recognizes `SYNO.SDS.LogCenter.Instance`, while real DSM 7 data may expose `SYNO.SDS.LogCenter.BuiltIn`.
2. legacy `ApplicationItemWidget` mostly uses `pushNamed("/<icon>")`, while `legacyNamedRoutes` does not contain every enum destination; Log Center is a concrete mismatch.
3. Docker and Container Manager are two package identifiers for one product family and may coexist during transitions.
4. `validAppviewOrder` may be present but empty; fallback to `appviewOrder` must be based on a non-empty authoritative list, not merely nullability.
5. current legacy grid/presentation is not a Modern UI authority.

### 3.2 Favorites

No existing repository authority implements the approved Applications “常用” semantics.

There is no reusable favorites database/provider for Applications. Task 6 therefore needs a small local preference owned by the Modern Applications hub.

Existing `SpUtil.getStringList/putStringList` is already used elsewhere and is sufficient; no Drift schema migration is justified.

### 3.3 Settings

Current reusable authorities include:

- `DarkModeProvider` and persisted `dark_mode` values 0/1/2;
- Task 4 account management and logout callbacks;
- legacy detail pages such as `HelperSetting`, `UserSetting`, `About`, terminal/backup/feedback paths;
- current active-context data already available through `Api.dsm` and context-scoped `InitDataProvider`.

The legacy Settings root is presentation evidence only. Its large wallpaper/profile card, glass controls and Cupertino-heavy layout are not Modern UI authorities.

### 3.4 Shutdown / reboot gap

The current legacy Settings root renders shutdown/reboot affordances and confirmation UI, but its actual DSM power request body is commented out. `System.dart` exposes system information only, and the audited repository contains no other working shutdown/reboot authority.

Therefore Task 6 must **not** present a new Modern shutdown/reboot action as functional.

This is a confirmed capability gap, not a reason to invent an unverified DSM protocol during a shell task. The legacy source remains untouched. A future feature may implement power control only after an explicit API/permission/failure-semantics audit.

## 4. Architecture

Task 6 adds two focused feature areas:

```text
lib/new_ui/applications/**
    DSM InitData projection
    → canonical supported application catalog
    → local favorites projection
    → Modern Applications page
    → LegacyPageHost destination

lib/new_ui/settings/**
    existing local/context state
    → Modern sectioned Settings root
    → Task 4 account/logout callbacks
    → legacy detail handoffs
```

The shell continues to own:

- active DSM context;
- five independent primary-tab navigators;
- global notification entry;
- connection/authentication status;
- legacy provider wrapping;
- account switching and logout transitions.

Task 6 must not create another shell, DSM transport, application-order source, auth/session controller, or settings database.

## 5. Modern Application Catalog

### 5.1 Source order

The source list is:

1. `validAppviewOrder` when it is non-empty;
2. otherwise `appviewOrder`;
3. otherwise an empty successful list only when InitData itself is known to be loaded.

The Modern catalog filters that list to destinations DSM Helper can actually open.

Unknown DSM applications are skipped. Their existence must never create a guessed route.

### 5.2 Canonical identity

Favorites and deduplication use stable Modern canonical IDs rather than raw DSM package aliases.

Required canonical families:

- control panel;
- package center;
- resource monitor;
- storage manager;
- log center;
- security advisor;
- Xunlei;
- Docker / Container Manager;
- Download Station;
- Moments;
- Synology Photos;
- Virtual Machine Manager.

Alias rules:

- `SYNO.SDS.LogCenter.Instance` and `SYNO.SDS.LogCenter.BuiltIn` resolve to one Log Center identity.
- `SYNO.SDS.Docker.Application` and `SYNO.SDS.ContainerManager.Application` resolve to one container-management identity; if both occur, the first DSM source occurrence defines position while the actually available newer Container Manager presentation is preferred when applicable.
- duplicate aliases never produce duplicate launcher entries.

The catalog does not rewrite DSM order. It only canonicalizes aliases and removes unsupported/duplicate entries.

### 5.3 Presentation metadata

Each resolved application supplies:

- canonical ID;
- source DSM package ID;
- display label;
- existing application asset path appropriate to the resolved DSM/application;
- one legacy destination builder.

The catalog must not depend on `pushNamed("/<icon>")` being complete. Route availability is explicit and testable.

### 5.4 Navigation

Tapping an application opens its existing legacy destination through the already-established `LegacyPageHost` + current `DsmProviderScope`.

Special existing destinations such as Xunlei browser handoff remain explicit mappings rather than guessed named routes.

Back returns to the Applications tab at its previous root/scroll state. Opening an app must not reset another primary tab.

## 6. Applications Load / Empty / Offline Semantics

Task 6 does not add a second periodic InitData loader.

The current context-scoped `InitDataProvider` populated by `LegacySharedBootstrapBoundary` remains the read authority.

Classification:

- InitData known loaded + zero supported applications → genuine empty state;
- InitData not available because the shell is offline/bootstrap failed → unavailable/error state, not “没有应用”;
- unsupported DSM entries are filtered without being treated as request failures.

Applications must never show a stale list from context A after the shell switches to context B. The existing context-keyed provider scope is the lifecycle boundary and receives an explicit Task 6 relationship test.

## 7. Favorites Semantics

### 7.1 Ownership and storage

Applications favorites are an **app-local convenience preference**, independent from:

- DSM Desktop application order;
- DSM Desktop shortcut configuration used by Task 5 Overview;
- legacy `showShortcut`;
- current Dashboard widgets.

Storage uses one ordered String list in `SpUtil`:

```text
modern_ui_application_favorites_v1
```

Entries are canonical Modern application IDs.

The list is app-local/global rather than stored in DSM. Switching NAS/account does not delete it.

### 7.2 Visibility projection

For the active DSM context:

1. preserve stored favorite order;
2. retain only favorites currently resolvable/available on that DSM for display;
3. show at most the first 8 eligible favorites;
4. keep unavailable, unknown and overflow stored IDs untouched.

This permits a favorite to reappear if a later DSM context again exposes that application without mutating DSM configuration.

### 7.3 Pin / unpin

- long press on a launcher item opens a Material 3 contextual Bottom Sheet;
- an unpinned supported app offers “添加到常用”;
- a pinned app offers “从常用移除”;
- adding is rejected when the current context already displays 8 favorites;
- duplicate pin is an idempotent no-op;
- unpin removes only the selected canonical ID;
- a persistence failure must not be represented as a successful favorite mutation.

### 7.4 Reorder

The “常用” section exposes a restrained **编辑** action when reordering is meaningful.

Editing uses a dedicated Modern edit surface with a `ReorderableListView`; the normal four-column launcher grid does not expose persistent drag handles.

Reordering applies only to the currently displayed favorite IDs. Persisted unavailable/unknown/overflow IDs must not be dropped or arbitrarily moved.

Merge invariant:

Let persisted ordered list be `S`, currently displayed favorite IDs be `V`, and edited order be `E` containing exactly the same IDs as `V`.

Walk `S` in order:

- every slot whose ID belongs to `V` is replaced by the next ID from `E`;
- every other stored ID remains in the same relative position.

This is the Task 6 equivalent of a preservation merge: editing one context must not destroy favorites that are temporarily unavailable in that context.

## 8. Modern Applications Page

The formal Applications root contains:

1. compact Top App Bar with global notification action and abnormal connection text;
2. “常用” section;
3. “全部应用” section.

Visual rules:

- fixed four-column portrait-phone grid for launcher items;
- no per-application Card;
- normal launcher-sized icon;
- label below, maximum two lines;
- medium-high density using Task 2 spacing/typography;
- Light and Dark must be equally usable;
- large font may grow labels/row height but must not collapse to oversized three-column legacy presentation.

If no favorites are currently visible, “常用” remains understandable as an empty local convenience section; the complete “全部应用” section remains usable.

## 9. Modern Settings Root

### 9.1 Structure

“我的” becomes one visually continuous sectioned-management page, not a wallpaper/profile hero and not a card wall.

Required Task 6 sections:

**当前设备与账号**
- compact current DSM/account context when available;
- 服务器与账号管理 → existing Task 4 callback;
- 个人设置 → legacy `UserSetting` handoff where available;
- 退出登录 → existing Task 4 logout flow.

**外观**
- theme mode: System / Light / Dark;
- current `DarkModeProvider` is the authority;
- changing mode is presentation-only and must preserve route/session/business state.

**应用设置**
- 助手设置 → legacy `HelperSetting`;
- one low-emphasis “更多现有设置” compatibility entry may open the retained legacy Settings root so currently unported low-frequency capabilities remain reachable.

**关于**
- About → legacy `About`.

The compatibility entry is temporary migration infrastructure, not a second permanent Settings shell.

### 9.2 No Dynamic Color expansion

Dynamic Color remains optional and off by default per the global visual specification.

The current repository has no completed Dynamic Color preference/wiring. Task 6 does not add it merely because the specification permits it.

### 9.3 Network behavior

The Modern Settings root itself must not require a new DSM request to render.

It uses current local/context state. If DSM-specific metadata is absent, omit that metadata rather than blocking account management, theme, About or logout.

Legacy detail pages keep their existing network/error semantics inside the fallback boundary.

### 9.4 Power controls

Modern Settings does not expose shutdown/reboot controls in Task 6 because no verified working backend authority exists.

The design must not display a disabled decorative substitute that suggests a supported action.

This omission is explicitly scoped and non-blocking for Task 6.

## 10. Legacy Capability Preservation

Task 6 does not delete:

- `lib/pages/applications/**`;
- `lib/pages/setting/**`;
- legacy application detail pages;
- existing named routes.

The new root pages may directly hand off to specific legacy details. The retained legacy Settings root may remain reachable through the compatibility entry for low-frequency functionality not individually surfaced yet.

No Task 6 cleanup may remove a legacy destination solely because a Modern root now exists.

## 11. Context, Navigation and Notification Relationships

Task 6 inherits:

- `G-NAV-01` independent tab stacks;
- `G-NAV-03` context-switch reset;
- `G-NOTIFY-01` shell-global DSM notifications;
- `G-THEME-02` legacy theme isolation;
- `G-ANDROID-01` Android Back;
- Task 4 logout/account-switch semantics.

Required results:

- Applications and Settings open their legacy children within the correct current DSM provider scope.
- Back returns to the same primary tab.
- switching NAS/account replaces Applications source data and resets primary stacks as already defined;
- global app-local favorites persist across the switch but are re-filtered for the new DSM;
- notification entry works from both new root pages independently of Overview lifetime;
- theme changes from Settings do not reset navigation or DSM context.

## 12. Explicit Non-Goals

Task 6 does not:

- migrate Control Panel, Resource Monitor, Storage Manager, Docker, Package Center, Download Station, VMM or other application detail UIs;
- migrate every legacy Settings detail;
- invent or reverse-engineer shutdown/reboot DSM calls;
- rewrite `ApplicationEnum` or the entire legacy named-route system for cleanliness;
- modify Task 5 Overview shortcut persistence/semantics;
- make Applications favorites a DSM Desktop configuration;
- add Dynamic Color implementation;
- migrate Drift;
- rewrite auth/session/provider architecture;
- delete legacy Applications or Settings roots;
- begin Task 7 or later feature implementation.

## 13. Required Verification Classes

### Catalog / unit

Must prove:

- non-empty `validAppviewOrder` wins; empty valid list falls back to `appviewOrder`;
- unknown entries are skipped;
- Log Center aliases resolve once;
- Docker/Container Manager aliases resolve once;
- DSM order is preserved across filtering;
- every emitted catalog item has an explicit destination.

### Favorites / persistence

Must prove:

- ordered persistence and restore;
- pin/unpin idempotency;
- visible maximum eight;
- unavailable IDs survive current-context projection;
- reorder merge preserves hidden/unknown/overflow IDs and their relative order;
- failed persistence does not publish a successful mutation;
- favorites never write DSM shortcut/order state.

### Widget

Must prove:

- fixed four-column All applications grid;
- Common empty/nonempty states;
- long labels and large font do not overflow;
- Light/Dark render with Task 2 components;
- Settings uses one continuous sectioned page;
- theme mode control exposes System/Light/Dark;
- no Modern shutdown/reboot action exists.

### Relationship / integration

Must prove:

- app tap → `LegacyPageHost` → correct destination → Back returns to Applications;
- legacy Settings detail → Back returns to My;
- account management/logout use Task 4 callbacks, not duplicate controllers;
- theme switch preserves tab/route/context;
- context A → B never displays A application catalog under B;
- global favorites re-filter for B without being deleted;
- global notification action works from Applications and Settings.

### CI / real device

Final Task 6 gate requires:

- full Flutter tests;
- targeted `flutter analyze lib/new_ui test/new_ui`;
- beta debug APK build;
- stable package/signing identity;
- overlay installation over the accepted Task 5 APK;
- real-device visual/use verification of both root pages;
- at least one real application legacy handoff and return;
- favorite pin/reorder persistence across app restart;
- theme mode change and persistence;
- server/account-management entry and logout path remain usable.

The final Task 6 device gate does not claim power-control testing because Task 6 exposes no Modern power action.

## 14. Preflight Resolutions

Preflight resolves the identified gaps as follows:

1. **Application order authority:** DSM `validAppviewOrder`, non-empty fallback to `appviewOrder`.
2. **Route mismatch:** Modern catalog owns explicit destination mapping; it does not infer completeness from named routes.
3. **Log Center alias:** Instance/BuiltIn canonicalize to one identity.
4. **Docker rename/alias:** Docker/Container Manager canonicalize to one product-family identity.
5. **Favorites authority:** local `SpUtil` ordered canonical-ID list; independent from DSM shortcuts/order.
6. **Favorites cross-context safety:** filter for display, preserve unavailable IDs, max eight visible, preservation merge on reorder.
7. **Settings authority:** reuse Task 4 account/logout and existing preference/detail authorities; no second settings backend.
8. **Power controls:** confirmed non-working legacy request path is not promoted; Modern power actions are deferred.
9. **Dynamic Color:** optional global design allowance remains unimplemented and outside Task 6.
10. **Fallback:** detail migration remains progressive; legacy Applications/Settings source stays present.

No unresolved **blocking** Task 6 Contract Gap remains.

## 15. Preflight Exit Gate

Task 6 may proceed to Batch planning when:

- this Feature Design and the Task 6 Contract Matrix agree on all authorities and owned state;
- no TODO/TBD/open product decision remains;
- favorites do not overlap Task 5 shortcut persistence;
- the power-control gap is explicitly excluded from Task 6 rather than guessed;
- no production/test code has changed;
- the Master Plan points to the Task 6 Preflight authorities.

Under `CI-DOCS-01`, this documentation-only Preflight does not require Android CI.
