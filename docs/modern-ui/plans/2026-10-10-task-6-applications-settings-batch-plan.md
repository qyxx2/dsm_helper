# Task 6 Applications Hub + Settings Shell Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the generic Modern `应用` and `我的` placeholders with a canonical DSM application hub, local ordered favorites, and a sectioned Modern Settings root while keeping unported feature details behind the established legacy boundary.

**Architecture:** Task 6 adds focused `lib/new_ui/applications/**` and `lib/new_ui/settings/**` layers above existing InitData, preference, Task 4 auth/account, shell and legacy-page authorities. Applications resolves DSM order into canonical launchable destinations and projects a separate local favorites preference; Settings is a root-level navigation/presentation shell that reuses existing account/logout/theme/detail capabilities. Formal shell cutover happens only after the independent catalog, favorites and UI batches pass.

**Tech Stack:** Flutter 3.22.3, Dart, Material 3, Provider/ChangeNotifier already present in the app, `SpUtil`, existing Synology DSM models/pages, Task 3–5 Modern shell/session infrastructure, GitHub Actions Android CI.

**Spec:** `docs/modern-ui/specs/2026-10-10-task-6-applications-settings-feature-design.md`  
**Contracts:** `docs/modern-ui/contracts/2026-10-10-task-6-applications-settings-contract-matrix.md`

## Global Constraints

- Integration branch: `modern-ui`.
- Task branch: `feature/t6-applications-settings`.
- Preflight commit: `bef43e35b320b72b9ea16b358d2be0e316c0ae96`.
- GitHub is the formal code source of truth.
- Implementation order is B1 → B2 → B3 → B4 → B5. Do not skip a Batch because a later Batch touches adjacent wiring.
- New Task 6 feature code belongs under `lib/new_ui/applications/**` or `lib/new_ui/settings/**` except the minimum final shell wiring.
- DSM application order remains `validAppviewOrder` when non-empty, otherwise `appviewOrder`; Task 6 does not create another DSM application-order authority.
- Unsupported or unrouteable DSM applications are omitted; no route is guessed from an icon or package string.
- Log Center Instance/BuiltIn is one canonical app; Docker/Container Manager is one canonical product-family app.
- Applications favorites use `SpUtil` key `modern_ui_application_favorites_v1`, contain canonical IDs, and never write DSM desktop order/shortcuts or Task 5 Overview shortcut configuration.
- At most 8 eligible favorites are visible in the current context. Unavailable/unknown/overflow stored IDs are preserved.
- Favorites reorder uses the preservation merge frozen in the Feature Design / Contract Matrix.
- Application and Settings legacy detail handoffs use `LegacyPageHost` plus the existing current-context provider wrapper.
- Settings reuses Task 4 account-management/logout flows and current `DarkModeProvider`; it must not create another auth/session/settings backend.
- Task 6 does not expose a Modern shutdown/reboot action because no working audited backend exists.
- Task 6 does not implement Dynamic Color.
- Legacy Applications and Settings source stays present.
- `APK-IDENTITY-01`: user-installable APK remains package `top.apaipai.dsm_helper` and uses the existing stable development certificate.
- `CI-DOCS-01`: acceptance/status-only commits do not require a redundant Android CI run.
- Do not rewrite DSM SDK, Drift, Provider architecture, Task 5 Overview shortcuts, or unrelated legacy UI.
- Do not begin Task 7 or later feature implementation.
- Do not rerun an unchanged commit merely because an existing CI run is slow/cancelled; inspect the existing run/evidence first.
- If the executor runtime lacks Flutter/Dart, do not claim local execution. Use committed RED tests plus GitHub Actions as executable RED/GREEN evidence and record that limitation exactly.

## Review Focus

1. **Alias collision / order:** a DSM list containing both Log Center aliases or both Docker/Container Manager IDs must emit one canonical item at the first source position without moving neighboring applications. B1 owns this proof.
2. **Context switch with hidden favorites:** favorites unavailable on context A but available on B must survive A-side pin/reorder activity and reappear on B without DSM writes. B2 owns storage/merge proof; B5 re-proves shell context behavior.
3. **Favorites write failure / repeated input:** failed persistence and duplicate rapid pin/unpin must not publish a successful or duplicated favorites state. B2 owns controller proof; B3 owns user feedback.
4. **Four-column grid under long labels / large fonts:** labels may wrap/grow but must not overflow, become cards, or silently degrade to the legacy oversized layout. B3 owns widget proof.
5. **Theme/legacy navigation relationship:** changing theme in My or entering a legacy settings/application child must preserve active DSM context, independent tab stacks and Back return semantics. B4 owns page-level proof; B5 owns full-shell proof.

---

## Dependency / Batch Matrix

| Batch | Primary concern | Depends on | Must not implement |
| --- | --- | --- | --- |
| B1 | Canonical application catalog + explicit destinations | Preflight | favorites, Modern Applications UI, shell cutover |
| B2 | Favorites store/controller + preservation merge | B1 | launcher UI, Settings, shell cutover |
| B3 | Modern Applications root + edit interactions | B1–B2 | formal shell cutover, Settings root |
| B4 | Modern Settings root + existing authority handoffs | Preflight (executed after B3) | power backend, Dynamic Color, shell cutover |
| B5 | Formal Applications/My shell cutover + relationship/device Gate | B1–B4 | legacy deletion, Task 7 |

Every Batch receives its own acceptance record under `docs/modern-ui/acceptance/`. A later Batch must not broaden an earlier Batch silently.

---

# Batch 1 — Canonical Application Catalog / Destination Foundation

**Contracts:** `T6-APP-01`, `T6-APP-02`, `T6-APP-03` destination completeness portion, `T6-APP-04`.

**Purpose:** Make “what applications exist, in what order, and where each can actually open” a pure, testable Task 6 boundary before any new launcher UI consumes it.

**Files:**
- Create: `lib/new_ui/applications/application_catalog.dart`
- Create: `lib/new_ui/applications/application_destination_catalog.dart`
- Create: `test/new_ui/applications/application_catalog_test.dart`
- Create: `test/new_ui/applications/application_destination_catalog_test.dart`
- Create after GREEN: `docs/modern-ui/acceptance/2026-10-10-task-6-batch-1-application-catalog-acceptance.md`

**Interfaces:**

`application_catalog.dart` produces:

```dart
enum ModernApplicationId {
  controlPanel,
  packageCenter,
  resourceMonitor,
  storageManager,
  logCenter,
  securityAdvisor,
  xunlei,
  containerManager,
  downloadStation,
  moments,
  photos,
  virtualMachineManager,
}

extension ModernApplicationIdPersistence on ModernApplicationId {
  String get storageKey;
}

enum ApplicationCatalogAvailability {
  unavailable,
  available,
}

class ModernApplicationItem {
  const ModernApplicationItem({
    required this.id,
    required this.sourcePackageName,
    required this.label,
    required this.assetPath,
  });

  final ModernApplicationId id;
  final String sourcePackageName;
  final String label;
  final String assetPath;
}

class ApplicationCatalogSnapshot {
  const ApplicationCatalogSnapshot({
    required this.availability,
    required this.items,
  });

  final ApplicationCatalogAvailability availability;
  final List<ModernApplicationItem> items;
}

class ModernApplicationCatalog {
  const ModernApplicationCatalog();

  ApplicationCatalogSnapshot build(InitDataModel initData);
}
```

`application_destination_catalog.dart` produces:

```dart
class ModernApplicationDestinationCatalog {
  const ModernApplicationDestinationCatalog();

  WidgetBuilder? builderFor(ModernApplicationId id);
}
```

Destination mapping must use the existing concrete legacy pages, including explicit Browser handling for Xunlei. It must not depend on `legacyNamedRoutes` completeness.

### Task 1.1 — Freeze source/fallback and canonical identity with RED tests

- [ ] Add catalog tests that assert:
  - loaded InitData + non-empty `validAppviewOrder` uses that exact order;
  - loaded InitData + empty `validAppviewOrder` falls back to `appviewOrder`;
  - missing/unloaded InitData yields `ApplicationCatalogAvailability.unavailable`, not an available empty list;
  - loaded source with zero supported IDs yields available + empty;
  - unknown DSM IDs are skipped without changing recognized-neighbor order.
- [ ] Run the focused test and capture expected RED because Task 6 catalog types do not yet exist.

Run:

```bash
flutter test test/new_ui/applications/application_catalog_test.dart
```

Expected: FAIL due missing Task 6 catalog implementation.

### Task 1.2 — Implement the minimal catalog

- [ ] Implement the interfaces above.
- [ ] Use the non-empty `validAppviewOrder` fallback rule exactly.
- [ ] Resolve existing application assets without changing legacy asset files.
- [ ] Keep unsupported entries out; do not invent generic browser/package destinations.
- [ ] Run the focused catalog test.

Expected: PASS.

### Task 1.3 — Prove aliases, dedupe and stable order

- [ ] Extend RED tests with:
  - `SYNO.SDS.LogCenter.Instance` + `SYNO.SDS.LogCenter.BuiltIn` → one `ModernApplicationId.logCenter`;
  - `SYNO.SDS.Docker.Application` + `SYNO.SDS.ContainerManager.Application` → one `ModernApplicationId.containerManager`;
  - first source occurrence determines canonical position;
  - Container Manager presentation is preferred when that package is actually available;
  - neighboring supported apps preserve DSM relative order.
- [ ] Run focused test to verify at least one new invariant fails before the implementation change.
- [ ] Implement only the alias/dedupe logic necessary for GREEN.
- [ ] Re-run focused tests.

### Task 1.4 — Explicit destination completeness

- [ ] Add destination tests that iterate every `ModernApplicationId` and assert `builderFor(id)` is non-null.
- [ ] Include an explicit Log Center assertion so the known named-route gap cannot regress.
- [ ] Include Xunlei destination construction as an explicit special case.
- [ ] Run test and capture RED if destination catalog is absent/incomplete.

Run:

```bash
flutter test test/new_ui/applications/application_destination_catalog_test.dart
```

- [ ] Implement the concrete destination mapping.
- [ ] Re-run both B1 test files.

### Task 1.5 — Batch regression / scope gate

Run:

```bash
flutter test test/new_ui/applications/
flutter test test/new_ui/app/ test/new_ui/shell/ test/new_ui/legacy/ test/new_ui/session/
flutter analyze lib/new_ui test/new_ui
```

Then trigger/inspect the standard Android CI for the exact implementation HEAD. The CI must complete:

- full `flutter test`;
- targeted analyze;
- beta debug APK build;
- APK package/certificate identity check;
- artifact upload.

- [ ] Diff from Batch start contains only B1 production/tests plus the acceptance document.
- [ ] No `lib/pages/**`, Task 5 Dashboard, auth/session or Android config changes.
- [ ] Write B1 acceptance with exact RED/GREEN and CI evidence.

**B1 Exit Gate:** PASS only when source availability, fallback, alias/dedupe/order and explicit destination completeness are executable facts.

**Stop:** Do not begin B2 without an explicit next-Batch instruction.

---

# Batch 2 — Applications Favorites Persistence / State

**Contracts:** `T6-FAV-01`, `T6-FAV-02`, `T6-FAV-03`, `T6-FAV-04`.

**Purpose:** Establish the local ordered favorites authority, max-eight current-context projection and lossless reorder merge before UI mutation controls exist.

**Files:**
- Create: `lib/new_ui/applications/application_favorites_store.dart`
- Create: `lib/new_ui/applications/application_favorites_controller.dart`
- Create: `test/new_ui/applications/application_favorites_store_test.dart`
- Create: `test/new_ui/applications/application_favorites_controller_test.dart`
- Create: `test/new_ui/applications/application_favorites_relationship_test.dart`
- Create after GREEN: `docs/modern-ui/acceptance/2026-10-10-task-6-batch-2-application-favorites-acceptance.md`

**Interfaces:**

`application_favorites_store.dart`:

```dart
abstract interface class ApplicationFavoritesStore {
  Future<List<String>> load();
  Future<void> save(List<String> ids);
}

typedef ApplicationFavoriteIdsRead = List<String> Function();
typedef ApplicationFavoriteIdsWrite = Future<bool> Function(List<String> ids);

class SpUtilApplicationFavoritesStore implements ApplicationFavoritesStore {
  static const storageKey = 'modern_ui_application_favorites_v1';

  SpUtilApplicationFavoritesStore({
    ApplicationFavoriteIdsRead? read,
    ApplicationFavoriteIdsWrite? write,
  });

  @override
  Future<List<String>> load();

  @override
  Future<void> save(List<String> ids);
}
```

Default production callbacks wrap `SpUtil.getStringList/putStringList`. `save` throws if persistence reports failure.

`application_favorites_controller.dart`:

```dart
enum FavoriteMutationOutcome {
  changed,
  unchanged,
  limitReached,
}

class ApplicationFavoritesController extends ChangeNotifier {
  ApplicationFavoritesController({required ApplicationFavoritesStore store});

  bool get loaded;
  List<String> get storedIds;
  bool isPinned(ModernApplicationId id);

  Future<void> load();

  List<ModernApplicationId> visibleFor(
    List<ModernApplicationItem> catalog,
  );

  Future<FavoriteMutationOutcome> pin(
    ModernApplicationId id, {
    required List<ModernApplicationItem> catalog,
  });

  Future<FavoriteMutationOutcome> unpin(
    ModernApplicationId id,
  );

  Future<FavoriteMutationOutcome> reorderVisible(
    List<ModernApplicationId> edited, {
    required List<ModernApplicationItem> catalog,
  });
}
```

All mutations persist first and publish the new in-memory list only after successful save.

### Task 2.1 — Store RED → GREEN

- [ ] Write tests for empty default, ordered round-trip, copy isolation, and write failure.
- [ ] Verify RED with missing store.
- [ ] Implement `SpUtilApplicationFavoritesStore` using the frozen key and injectable read/write callbacks.
- [ ] Verify focused GREEN.

Run:

```bash
flutter test test/new_ui/applications/application_favorites_store_test.dart
```

### Task 2.2 — Projection / pin / unpin RED → GREEN

- [ ] Write controller tests:
  - restore exact raw stored order;
  - unknown raw IDs remain stored but are invisible;
  - unavailable known IDs remain stored but are invisible;
  - first eight eligible distinct favorites are visible;
  - duplicate pin → unchanged;
  - pin when eight are currently visible → `limitReached` and no write;
  - pin when fewer than eight are visible appends only the target canonical ID;
  - unpin removes only target ID;
  - failed save leaves `storedIds` and listeners unchanged.
- [ ] Verify RED.
- [ ] Implement minimal controller behavior.
- [ ] Verify GREEN.

### Task 2.3 — Preservation reorder relationship

- [ ] Write relationship tests around persisted lists containing interleaved:
  - current visible favorites;
  - known-but-unavailable IDs;
  - unknown future IDs;
  - eligible overflow beyond the first eight.
- [ ] Assert reorder replaces only slots belonging to the current visible set and leaves every other ID in the same relative position.
- [ ] Assert an edited list with a different membership set is rejected without write.
- [ ] Verify RED before adding the merge.
- [ ] Implement the exact preservation merge from the Contract Matrix.
- [ ] Verify GREEN.

### Task 2.4 — Prove independence from DSM / Task 5 shortcuts

- [ ] Add a source-level/relationship test that the favorites store/controller imports no DSM write model and performs no `UserSettings.apply`, shortcut mutation or desktop-order mutation.
- [ ] Exercise projection against two different catalog fixtures A/B using one stored list; assert B filtering does not mutate storage.
- [ ] Run all B1+B2 tests.

### Task 2.5 — Batch regression / gate

Run:

```bash
flutter test test/new_ui/applications/
flutter test test/new_ui/dashboard/overview_shortcuts_test.dart test/new_ui/dashboard/overview_shortcut_relationship_test.dart
flutter analyze lib/new_ui test/new_ui
```

Then inspect standard CI at the exact implementation HEAD.

- [ ] Confirm full test/analyze/APK/identity/artifact success.
- [ ] Diff contains only favorites/catalog test scope plus acceptance.
- [ ] Write B2 acceptance.

**B2 Exit Gate:** local ordered favorites are durable, max-eight-visible, cross-context-safe and mechanically independent from DSM shortcut/order state.

**Stop:** Do not begin B3 without explicit instruction.

---

# Batch 3 — Modern Applications Hub UI

**Contracts:** `T6-APP-03`, `T6-APP-04`, `T6-APP-05`, consumes all `T6-FAV-*`.

**Purpose:** Build the real Material 3 Applications page and favorites edit interaction on top of B1/B2 without changing the formal shell root yet.

**Files:**
- Create: `lib/new_ui/applications/applications_page.dart`
- Create: `lib/new_ui/applications/application_launcher_tile.dart`
- Create: `lib/new_ui/applications/edit_application_favorites_page.dart`
- Create: `test/new_ui/applications/applications_page_test.dart`
- Create: `test/new_ui/applications/edit_application_favorites_page_test.dart`
- Create: `test/new_ui/applications/application_navigation_relationship_test.dart`
- Create after GREEN: `docs/modern-ui/acceptance/2026-10-10-task-6-batch-3-applications-ui-acceptance.md`

**Interfaces:**

```dart
typedef ApplicationFavoritesControllerFactory =
    ApplicationFavoritesController Function();

class ApplicationsPage extends StatefulWidget {
  const ApplicationsPage({
    super.key,
    required this.onOpenNotifications,
    required this.onOpenApplication,
    this.connectionStatusText,
    this.catalog = const ModernApplicationCatalog(),
    this.favoritesControllerFactory,
  });

  final VoidCallback onOpenNotifications;
  final ValueChanged<ModernApplicationId> onOpenApplication;
  final String? connectionStatusText;
  final ModernApplicationCatalog catalog;
  final ApplicationFavoritesControllerFactory? favoritesControllerFactory;
}

class ApplicationLauncherTile extends StatelessWidget {
  const ApplicationLauncherTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });
}

class EditApplicationFavoritesPage extends StatelessWidget {
  const EditApplicationFavoritesPage({
    super.key,
    required this.controller,
    required this.catalogItems,
  });
}
```

The page owns the controller returned by its factory and disposes it. Production default creates `SpUtilApplicationFavoritesStore`.

### Task 3.1 — Applications structure RED → GREEN

- [ ] Write widget tests for:
  - App Bar title/notification/status;
  - “常用” before “全部应用”;
  - All applications uses exactly four columns;
  - launcher items are not Cards;
  - labels are max two lines;
  - loaded-empty versus unavailable states are different;
  - empty Common does not hide All applications.
- [ ] Verify RED.
- [ ] Implement page/tile composition with Task 2 tokens.
- [ ] Verify GREEN.

### Task 3.2 — Favorite interaction RED → GREEN

- [ ] Add widget tests:
  - long press unpinned item opens Bottom Sheet with “添加到常用”;
  - long press pinned item offers removal;
  - `limitReached` shows local Snackbar and does not alter grid;
  - store write exception shows failure feedback and retains prior state;
  - Common updates after successful mutation.
- [ ] Verify RED.
- [ ] Wire controller mutation and Material 3 Bottom Sheet.
- [ ] Verify GREEN.

### Task 3.3 — Edit/reorder surface RED → GREEN

- [ ] Add tests:
  - Common with at least two visible favorites exposes “编辑”;
  - edit opens dedicated `EditApplicationFavoritesPage`;
  - edit surface uses `ReorderableListView`;
  - reorder calls controller with the displayed IDs;
  - hidden/unavailable IDs do not appear in the editor;
  - persistence failure leaves edit list/order consistent with controller state.
- [ ] Verify RED.
- [ ] Implement edit page and navigation.
- [ ] Verify GREEN.

### Task 3.4 — Navigation callback / Back relationship

- [ ] Add relationship test: tap a catalog item → exactly one `onOpenApplication(id)` → simulated child push → Back returns to Applications with favorite/order state intact.
- [ ] Prove notification action is independent from app destination callback.
- [ ] Verify no direct `Navigator.pushNamed("/<icon>")` dependency is introduced in Task 6 Applications UI.

### Task 3.5 — Density / accessibility / themes

- [ ] Test representative 360dp portrait width at normal text scale.
- [ ] Test long labels and large text scaling for no overflow exceptions.
- [ ] Test Light and Dark themes using `NewUiTheme`.
- [ ] Assert four-column launcher semantics remain and icon/label tap targets stay usable.

### Task 3.6 — Batch regression / optional focused device visual gate

Run:

```bash
flutter test test/new_ui/applications/
flutter test test/new_ui/theme/ test/new_ui/legacy/
flutter analyze lib/new_ui test/new_ui
```

Inspect standard CI at exact HEAD.

A focused real-device visual check is useful here if an APK is already being installed, but Task 6 final acceptance remains B5. Record any B3 device check accurately as focused evidence, not final Task acceptance.

- [ ] Write B3 acceptance with automated evidence and any actual device evidence.
- [ ] Do not wire the Applications primary destination yet.

**B3 Exit Gate:** ApplicationsPage is complete/tested as an isolated Modern root, but production shell still uses the pre-B5 entry.

**Stop:** Do not begin B4 without explicit instruction.

---

# Batch 4 — Modern Settings Shell

**Contracts:** `T6-SET-01` through `T6-SET-06`, supports `T6-NAV-01`.

**Purpose:** Build the sectioned My/Settings root using existing Task 4/theme/legacy authorities, without inventing missing power or Dynamic Color capability and without formal shell cutover.

**Files:**
- Create: `lib/new_ui/settings/settings_page.dart`
- Create: `lib/new_ui/settings/settings_theme_mode_sheet.dart`
- Create: `test/new_ui/settings/settings_page_test.dart`
- Create: `test/new_ui/settings/settings_theme_relationship_test.dart`
- Create: `test/new_ui/settings/settings_navigation_relationship_test.dart`
- Create after GREEN: `docs/modern-ui/acceptance/2026-10-10-task-6-batch-4-settings-shell-acceptance.md`

**Interfaces:**

```dart
class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.onOpenNotifications,
    required this.onOpenAccountManagement,
    required this.onLogout,
    required this.onOpenUserSettings,
    required this.onOpenHelperSettings,
    required this.onOpenAbout,
    required this.onOpenLegacySettings,
    this.connectionStatusText,
  });

  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenAccountManagement;
  final VoidCallback onLogout;
  final VoidCallback onOpenUserSettings;
  final VoidCallback onOpenHelperSettings;
  final VoidCallback onOpenAbout;
  final VoidCallback onOpenLegacySettings;
  final String? connectionStatusText;
}

Future<void> showSettingsThemeModeSheet(BuildContext context);
```

The page reads current `InitDataProvider` and `DarkModeProvider` only. It must not perform a new DSM fetch.

### Task 4.1 — Sectioned Settings composition RED → GREEN

- [ ] Write widget tests for one continuous page with ordered sections:
  - 当前设备与账号;
  - 外观;
  - 应用设置;
  - 关于.
- [ ] Assert current hostname/user metadata is shown only when present.
- [ ] Assert no wallpaper/profile hero or required remote load exists.
- [ ] Assert Server/Account management, Personal settings, Helper settings, compatibility settings, About and Logout entries invoke their injected callbacks.
- [ ] Verify RED.
- [ ] Implement the minimal sectioned Material 3 root.
- [ ] Verify GREEN.

### Task 4.2 — Theme mode RED → GREEN

- [ ] Add tests that opening theme mode shows exactly System / Light / Dark.
- [ ] Selecting each maps to the existing `DarkModeProvider` values 2 / 0 / 1 respectively.
- [ ] Assert no Dynamic Color control appears.
- [ ] Assert theme change does not invoke account/logout/legacy callbacks.
- [ ] Verify RED.
- [ ] Implement `showSettingsThemeModeSheet` using Material 3 Bottom Sheet and existing provider.
- [ ] Verify GREEN.

### Task 4.3 — Power-boundary proof

- [ ] Add a test asserting Modern Settings exposes no shutdown/reboot callback, button or label.
- [ ] Add a source-boundary check that Task 6 Settings does not invent `SYNO.Core.System` power calls.
- [ ] Keep the legacy Settings source unchanged.

This is a contract proof, not a request to implement power control.

### Task 4.4 — Legacy handoff / Back relationship

- [ ] In a page-level test harness, wire User / Helper / About / compatibility callbacks to push hosted child pages or sentinel legacy children.
- [ ] Verify Back returns to the same My root and does not invoke logout/account switching.
- [ ] Repeat under Light and Dark host themes to preserve `G-THEME-02`.

### Task 4.5 — Theme/navigation relationship

- [ ] Mount Settings under a nested route/tab harness with an active-context sentinel.
- [ ] Change theme mode.
- [ ] Assert current route, selected tab and active-context sentinel are unchanged.
- [ ] Rebuild from the persisted/provider value and assert selected mode remains visible.

### Task 4.6 — Batch regression / scope gate

Run:

```bash
flutter test test/new_ui/settings/
flutter test test/new_ui/auth/ test/new_ui/shell/ test/new_ui/legacy/ test/new_ui/theme/
flutter analyze lib/new_ui test/new_ui
```

Inspect standard CI at exact implementation HEAD.

- [ ] Confirm no Task 4 auth/session implementation was duplicated.
- [ ] Confirm no power/Dynamic Color backend was added.
- [ ] Write B4 acceptance.

**B4 Exit Gate:** Modern Settings root is complete in isolation, preserves existing authorities, and explicitly does not claim unsupported power capability.

**Stop:** Do not begin B5 without explicit instruction.

---

# Batch 5 — Formal Shell Cutover / Full Relationship + Device Gate

**Contracts:** `T6-APP-03`, `T6-CTX-01`, `T6-NAV-01`, `T6-NOTIFY-01`, `T6-SHELL-01`, `T6-FALLBACK-01`, `T6-APK-01`; re-proves relevant B1–B4 contracts through production wiring.

**Purpose:** Make Applications and My real Modern primary roots, preserve legacy detail/fallback access and prove the complete relationship under the live five-tab shell.

**Files:**
- Modify: `lib/new_ui/app/dsm_new_ui_shell.dart`
- Modify only if required by proven wiring need: `lib/new_ui/app/new_ui_app_shell.dart`
- Modify: `test/new_ui/wiring/production_wiring_test.dart`
- Create: `test/new_ui/app/task6_shell_relationship_test.dart`
- Extend as required: `test/new_ui/app/new_ui_app_shell_test.dart`
- Extend as required: `test/new_ui/applications/application_navigation_relationship_test.dart`
- Extend as required: `test/new_ui/settings/settings_navigation_relationship_test.dart`
- Create after final Gate: `docs/modern-ui/acceptance/2026-10-10-task-6-applications-settings-acceptance.md`
- Update after final Gate: `docs/modern-ui/2026-10-06-dsm-helper-modern-ui-master-plan.md`

### Task 5.1 — Production wiring RED

- [ ] Add shell relationship tests that currently fail because Applications/My roots are still generic/legacy-placeholder paths.
- [ ] Assert:
  - 应用 root is `ApplicationsPage`;
  - 我的 root is `SettingsPage`;
  - Overview/Files/Tasks destinations remain unchanged;
  - global notification callbacks remain present;
  - account management/logout callbacks are passed only to My;
  - legacy Applications/Settings builders remain retained as fallback/reference.
- [ ] Run focused test and capture RED.

Run:

```bash
flutter test test/new_ui/app/task6_shell_relationship_test.dart
```

### Task 5.2 — Minimal shell cutover GREEN

- [ ] Generalize the existing Overview-specific legacy-open helper only as far as required to host Task 6 children; do not create a second navigator abstraction.
- [ ] Wire Applications:
  - Modern `ApplicationsPage`;
  - catalog ID → `ModernApplicationDestinationCatalog.builderFor`;
  - builder → current `DsmProviderScope` + `LegacyPageHost`.
- [ ] Wire My:
  - Modern `SettingsPage`;
  - Task 4 `onManageAccounts` / `onLogout`;
  - UserSetting / HelperSetting / About / retained legacy Setting detail builders through the same legacy wrapper.
- [ ] Re-run focused test to GREEN.

### Task 5.3 — Application child and notification relationships

- [ ] From production shell, select Applications and open at least:
  - one ordinary page such as Resource Monitor/Storage Manager;
  - Log Center alias destination;
  - one special mapped destination where practical.
- [ ] Verify child uses legacy theme boundary and Back returns to Applications.
- [ ] Open global notifications from Applications; Back returns to same tab/root state.
- [ ] Switch away and back; independent tab stack remains intact.

### Task 5.4 — Settings relationships

- [ ] From production shell, select My and verify:
  - Server/Account management uses existing Task 4 callback;
  - logout uses existing Task 4 callback/flow;
  - Helper/User/About/compatibility handoffs return correctly;
  - notification entry works;
  - theme change does not reset tab or context.
- [ ] Confirm no Modern power control is present.

### Task 5.5 — Context-switch relationship

- [ ] Use test context A with an application unique to A and favorites containing A/B/unknown IDs.
- [ ] Switch/remount context B through the existing Task 3/4 context-keyed shell path.
- [ ] Assert:
  - A-only catalog item disappears;
  - B-only item appears;
  - no A InitData remains visible;
  - persisted favorites list is unchanged;
  - visible Common list is re-filtered for B;
  - selected primary tab resets to Overview per `G-NAV-03`.

### Task 5.6 — Full automated Gate

Run targeted suites:

```bash
flutter test test/new_ui/applications/
flutter test test/new_ui/settings/
flutter test test/new_ui/app/
flutter test test/new_ui/shell/
flutter test test/new_ui/legacy/
flutter test test/new_ui/session/
flutter test test/new_ui/startup/
flutter test test/new_ui/dashboard/
flutter test test/new_ui/auth/
flutter analyze lib/new_ui test/new_ui
```

Then rely on one standard CI run for the exact final implementation HEAD to prove:

```text
full flutter test
targeted flutter analyze
flutter build apk --debug --flavor beta
package ID = top.apaipai.dsm_helper
stable development certificate check
artifact upload
```

Do not substitute an earlier SHA's CI for the final implementation SHA.

### Task 5.7 — Diff / contract self-audit before device Gate

- [ ] Compare Task 6 implementation range against this plan.
- [ ] Confirm no:
  - Task 7 implementation;
  - legacy Applications/Settings deletion;
  - DSM SDK/Drift rewrite;
  - Task 5 shortcut mutation;
  - unplanned auth/session change;
  - shutdown/reboot backend;
  - Dynamic Color implementation;
  - unrelated formatting/cleanup.
- [ ] Re-read the Task 6 Contract Matrix and map every row to an executable test or explicit final device check.
- [ ] Confirm all previous B1–B4 acceptance records remain accurate and are not retroactively broadened.

### Task 5.7a — User-approved UI corrective follow-up (2026-10-11)

During the B5 device review, the user approved the original acceptance scenarios but required these five presentation corrections before repeating the final device Gate:

1. Remove the always-visible 常用 编辑 control; preserve reorder using the existing editor via a pinned favorite's long-press 调整常用顺序 menu (when two or more favorites are visible).
2. Match Applications long-press Bottom Sheet background to the bottom NavigationBar surface in both Light and Dark modes.
3. Remove all My section/category headings.
4. Use one compact device/account card, placing icon-only 个人设置 and 退出登录 actions inside it; keep established callbacks.
5. Make remaining My settings entries consistent text-first rows without mixed leading icons.

These **final-B5 presentation** requirements supersede the older B3 edit-entry and B4 Settings section-layout descriptions, without retroactively editing the B3/B4 historical acceptance files or changing their frozen business/session semantics. Require failing corrective tests, a passing final implementation-HEAD CI, and renewed device verification; the pre-correction B5 APK is not the final acceptance build.

### Task 5.8 — Real-device Gate

Install the final B5 CI APK **over** the accepted Task 5 APK without uninstalling.

Required user-visible checks:

1. overlay install succeeds and existing login/app data remains;
2. 应用 opens directly as the Modern hub;
3. four-column All applications layout is visually acceptable in portrait;
4. pin at least two applications; confirm no persistent Edit button, open pinned favorite long-press → 调整常用顺序, reorder, restart, and verify persistence/order;
5. open at least one real supported application and Back to Applications;
6. 我的 opens directly as the ungrouped Modern page, with a compact device/account card containing personal/logout icons;
7. theme mode change works and survives restart;
8. Server/Account management entry opens the established Task 4 flow and returns normally;
9. at least one legacy settings detail opens and returns normally;
10. global notification entry works from Applications and My;
11. normal tab switching preserves expected stacks;
12. no Modern shutdown/reboot action is shown;
13. Light/Dark layout has no material visual breakage at the user's normal phone width; application contextual sheets match bottom NavigationBar colors and My rows have uniform icon-free leading alignment.

Only scenarios actually performed are recorded as device PASS. Omitted scenarios are recorded as not tested, not implicitly accepted.

### Task 5.9 — Final acceptance / Master Plan closure

After automated + required device Gate pass:

- [ ] Write `docs/modern-ui/acceptance/2026-10-10-task-6-applications-settings-acceptance.md` with exact implementation SHA, CI run, test counts, artifact identity and device evidence.
- [ ] Update Master Plan Task 6 status to COMPLETE and point to final acceptance.
- [ ] Keep legacy Applications/Settings source retained.
- [ ] Under `CI-DOCS-01`, do not trigger/re-run full Android CI solely for the docs-only closure commit.
- [ ] Re-read remote commit after push and verify changed files.

**B5 / Task 6 Exit Gate:** PASS only when both Modern roots are production-wired, all contract relationships pass, final APK identity is stable, required real-device checks are recorded, and no later Task scope entered.

**Stop after Task 6. Do not automatically start Task 7A or merge the Task 6 branch unless the user explicitly instructs it.**

---

## Batch Execution Order

```text
Preflight
  ↓
B1 Canonical Application Catalog / Destinations
  ↓
B2 Favorites Persistence / State
  ↓
B3 Modern Applications Hub UI
  ↓
B4 Modern Settings Shell
  ↓
B5 Formal Shell Cutover / Full Relationship + Device Gate
```

B4 is technically less dependent on B1–B3 than the arrow suggests, but the task uses one branch and one frozen review sequence. Keep the order deterministic so each acceptance is an immutable handoff point.

## Plan Completion Gate

This plan is ready for execution because:

- every Task 6 Feature Design requirement maps to a Batch;
- every Contract Matrix row maps to unit/widget/relationship/CI/device evidence;
- application catalog, favorites, Applications UI, Settings UI and shell cutover have separate reviewable ownership;
- the two known misleading legacy facts — incomplete application route coverage and non-working power controls — are explicitly prevented from becoming implementation assumptions;
- no implementation step requires an unresolved product choice;
- no production/test file is changed by planning.

Planning completion authorizes **no implementation by itself**. Batch 1 requires an explicit execution instruction.
