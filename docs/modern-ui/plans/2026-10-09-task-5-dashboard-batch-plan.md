# Task 5 Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the legacy Dashboard entry with a complete Modern UI Overview that preserves DSM authorities, last-valid/stale semantics, configuration integrity, shell/session isolation, and legacy fallback boundaries.

**Architecture:** Add a thin `lib/new_ui/dashboard/**` orchestration/presentation layer above the existing DSM models. Core sources refresh independently through one controller-owned lifecycle; fixed Overview UI, alerts, shortcuts, and extension widgets consume that state without creating a second transport/provider authority. The formal shell cutover occurs only after all preceding batches pass.

**Tech Stack:** Flutter 3.22.3, Dart, Material 3, Provider/ChangeNotifier, existing Synology DSM models/APIs, existing Task 3/4 shell/session infrastructure, GitHub Actions Android CI.

**Spec:** `docs/modern-ui/specs/2026-10-09-task-5-dashboard-feature-design.md`  
**Contracts:** `docs/modern-ui/contracts/2026-10-09-task-5-dashboard-contract-matrix.md`

## Global Constraints

- Integration branch: `modern-ui`.
- Task branch: `feature/t5-dashboard`.
- Base Preflight commit: `21174e7fac64ad77db0e5aca68ea2fb02759bb6c`.
- GitHub is the formal code source of truth.
- New Task 5 code belongs under `lib/new_ui/dashboard/**` except the minimum final shell wiring.
- Existing `DsmApi`, API discovery, Task 3/4 active context, Drift and DSM model classes remain authoritative.
- Core Overview fetches use independent source requests; do not make `DsmApi.batch` the default core path.
- One controller owns automatic Overview polling. Widget-local recursive polling is prohibited.
- Automatic cadence comes from `SettingProvider.refreshDuration`; changing the setting while Overview is alive must update the controller cadence without creating a second timer.
- Refresh preserves last-valid data; partial failures remain local.
- Generic network failure is never authentication invalidation.
- DSM `DsmException` code `119` from an Overview request emits one runtime auth-invalidation signal and must reuse the existing Task 4 same-account reauthentication flow; Task 5 must not create a second auth authority.
- Overview must never publish delayed data from a disposed/previous DSM context.
- The fixed Overview structure is device summary → core resources → abnormal summary when non-empty → shortcuts → configurable extensions.
- Missing data is omitted. Never fabricate zero values or unsupported fields for visual symmetry.
- CPU load averages use only the real 1/5/15-minute model values. `System.sysTemp` is system temperature, not CPU temperature.
- No Task 5-local storage-capacity warning threshold is introduced.
- The Modern shortcut region is fixed; legacy `SettingProvider.showShortcut` does not hide it.
- No new shortcut persistence protocol is introduced.
- Task 5 owns only ConnectionLog and TaskScheduler extension IDs; every other DSM widget ID must survive edit/save unchanged unless explicitly owned.
- CurrentConnection and TaskScheduler Modern extensions are read-only summaries in Task 5.
- Recent Log and File Change Log Modern widgets are deferred, not deleted.
- Legacy Dashboard source remains present through Task 5.
- Task 2 visual rules, `APK-IDENTITY-01`, `CI-DOCS-01`, and all inherited global contracts remain authoritative.
- Do not begin Task 6.
- A docs-only acceptance/status commit does not require redundant Android CI under `CI-DOCS-01`.
- Do not rerun an unchanged CI commit merely because an earlier run is slow or cancelled; inspect the existing run first and rerun only when evidence is genuinely missing.

## Review Focus

1. **Late result from old NAS/context:** deliver an A response after A is disposed and B is active; the A response must be ignored. Owned by Batch 1 relationship tests and re-proven in Batch 7 shell tests.
2. **Slow request overlapping the refresh cadence:** one in-flight refresh must not spawn another timer/request cycle or clear last-valid data. Owned by Batch 1 controller tests.
3. **Unknown/deferred DSM widget IDs around owned IDs:** edit/reorder/save must preserve them exactly and in relative order. Owned by Batch 5 merge tests.
4. **Sparse DSM responses + large font/dark mode:** missing metrics must disappear without fake zeroes, overflow, unreadable stale state, or layout collapse. Owned by Batch 2 widget tests.
5. **Shortcut/notification navigation from a nontrivial shell state:** legacy handoff must return to the same Overview/tab context and the global notification action must remain independent of Overview lifetime. Owned by Batch 4 and Batch 7 relationship tests.

---

## Dependency / Batch Matrix

| Batch | Primary concern | Depends on | Must not implement |
| --- | --- | --- | --- |
| 1 | Data state, refresh, lifecycle | Preflight contracts | Visual Dashboard, shortcuts, extensions |
| 2 | Fixed device/core-resource Overview UI | B1 | Abnormal semantics, config, shell cutover |
| 3 | Abnormal summary | B1-B2 | New backend polling, container API migration |
| 4 | Shortcuts + legacy handoff contract | B2 | Shortcut persistence/editor, shell cutover |
| 5 | Extension configuration + preservation | B1-B2 | Extension data widgets, Task 6 |
| 6 | CurrentConnection / TaskScheduler extensions | B1, B5 | Mutating connection/task actions |
| 7 | Formal shell cutover + full relationship/device Gate | B1-B6 | Legacy Dashboard deletion, Task 6 |

Each Batch receives its own acceptance record under `docs/modern-ui/acceptance/`. A later Batch must not silently broaden an earlier Batch's accepted scope.

---

# Batch 1 — Overview Data / Refresh State Foundation

**Contracts:** `T5-DATA-01`, `T5-DATA-02`, `T5-STATE-01`, `T5-STATE-02`, `T5-REFRESH-01`, `T5-REFRESH-02`, `T5-AUTH-01`, supports `T5-CTX-01`.

**Purpose:** Establish one testable source-state and refresh authority before any Modern Dashboard widget depends on data.

**Files:**
- Create: `lib/new_ui/dashboard/overview_source_state.dart`
- Create: `lib/new_ui/dashboard/overview_data_source.dart`
- Create: `lib/new_ui/dashboard/overview_controller.dart`
- Create: `test/new_ui/dashboard/overview_source_state_test.dart`
- Create: `test/new_ui/dashboard/overview_controller_test.dart`
- Create: `test/new_ui/dashboard/overview_refresh_relationship_test.dart`
- Create after GREEN: `docs/modern-ui/acceptance/2026-10-09-task-5-batch-1-data-state-acceptance.md`

**Interfaces:**

`overview_source_state.dart` produces:

```dart
enum OverviewSourcePhase {
  initial,
  loading,
  valid,
  refreshing,
  stale,
  error,
  unavailable,
}

class OverviewSourceState<T> {
  const OverviewSourceState({
    required this.phase,
    this.value,
    this.error,
    this.updatedAt,
  });

  final OverviewSourcePhase phase;
  final T? value;
  final Object? error;
  final DateTime? updatedAt;

  bool get hasValue;
}
```

`overview_data_source.dart` produces:

```dart
typedef OverviewSystemLoader = Future<System?> Function();
typedef OverviewUtilizationLoader = Future<Utilization?> Function();
typedef OverviewStorageLoader = Future<Storage?> Function();
typedef OverviewNotificationLoader = Future<DsmNotify?> Function();

class OverviewDataSource {
  const OverviewDataSource({
    required this.loadSystem,
    required this.loadUtilization,
    required this.loadStorage,
    required this.loadNotifications,
  });

  factory OverviewDataSource.production();

  final OverviewSystemLoader loadSystem;
  final OverviewUtilizationLoader loadUtilization;
  final OverviewStorageLoader loadStorage;
  final OverviewNotificationLoader loadNotifications;
}
```

A loader returning `null` means capability unavailable; exceptions remain errors/offline inputs and must not be converted to empty success.

`overview_controller.dart` produces:

```dart
typedef OverviewAuthInvalidationHandler =
    void Function(DsmException error);

class OverviewController extends ChangeNotifier {
  OverviewController({
    required OverviewDataSource dataSource,
    required Duration refreshInterval,
    OverviewAuthInvalidationHandler? onAuthInvalidated,
  });

  OverviewSourceState<System> get system;
  OverviewSourceState<Utilization> get utilization;
  OverviewSourceState<Storage> get storage;
  OverviewSourceState<DsmNotify> get notifications;

  Future<void> loadInitial();
  Future<void> refresh();
  void startAutoRefresh();
  void updateRefreshInterval(Duration refreshInterval);
  void stopAutoRefresh();

  @override
  void dispose();
}
```

Controller invariants:
- one auto-refresh timer owner;
- no overlapping refresh cycle;
- each source commits independently;
- disposed generation ignores all late completions;
- `updateRefreshInterval` replaces, never duplicates, the timer;
- the first observed `DsmException(119)` invokes `onAuthInvalidated` at most once for that controller lifetime;
- code `119` is never reclassified as generic offline; non-119 DSM errors and transport failures never invoke the auth callback.

- [ ] **Step 1: Write RED source-state tests**

Cover exact phase/value invariants:
- initial has no value;
- valid contains V1 + timestamp;
- refreshing can retain V1;
- stale retains V1 + error;
- error has no fabricated value;
- unavailable is distinct from empty/error.

- [ ] **Step 2: Run the focused RED test**

Run:

```bash
flutter test test/new_ui/dashboard/overview_source_state_test.dart
```

Expected: FAIL because Task 5 source-state types do not exist.

- [ ] **Step 3: Implement the minimum source-state model and production data-source adapter**

`OverviewDataSource.production()` must call only:
- `System.info()`;
- `Utilization.get()`;
- `Storage.loadInfo()`;
- `DsmNotify.notify()`.

Do not add transport/request code.

- [ ] **Step 4: Write RED controller tests**

Cover:
- four core sources can succeed independently;
- one source failing does not overwrite successful sibling sources;
- V1 → refresh → failure = V1 + stale;
- later V2 replaces V1 and clears stale;
- successful empty notification list remains valid rather than error;
- loader `null` becomes unavailable;
- manual refresh requests all supported sources;
- two concurrent source failures with `DsmException(119)` produce exactly one auth-invalidation callback;
- a non-119 `DsmException` produces zero auth-invalidation callbacks;
- a transport exception produces zero auth-invalidation callbacks and stays source-local stale/error;
- a slow refresh does not overlap the next automatic tick;
- `updateRefreshInterval` leaves exactly one timer cadence.

- [ ] **Step 5: Run the controller RED test**

Run:

```bash
flutter test test/new_ui/dashboard/overview_controller_test.dart
```

Expected: FAIL before controller implementation.

- [ ] **Step 6: Implement `OverviewController` minimally**

Use independent async source updates. Preserve source V1 until that same source returns a valid replacement. Guard all async publication with controller lifetime/generation state.

- [ ] **Step 7: Write and run the context/disposal relationship RED→GREEN test**

Test:
- start A load;
- dispose A before completion;
- create/load B;
- complete delayed A with unique A data;
- assert no listener/state owned by B observes A;
- stop/dispose prevents future automatic ticks.

Run:

```bash
flutter test test/new_ui/dashboard/overview_refresh_relationship_test.dart
```

Expected after implementation: PASS.

- [ ] **Step 8: Focused regression and analyze**

Run:

```bash
flutter test test/new_ui/dashboard
flutter test test/new_ui/session test/new_ui/startup
flutter analyze lib/new_ui/dashboard test/new_ui/dashboard
```

Expected: all tests PASS; analyze reports no new issues.

- [ ] **Step 9: Diff boundary review and commit**

Only Batch 1 files plus its acceptance record may change. Do not edit shell/UI/legacy Dashboard files.

**Batch 1 Exit Gate**
- independent source state mechanically proven;
- last-valid/stale semantics proven;
- no overlapping timer cycle;
- late disposed-context results ignored;
- Task 3 session/startup regressions green.

---

# Batch 2 — Fixed Overview Core UI

**Contracts:** `T5-DEVICE-01`, `T5-RESOURCE-01`, `T5-RESOURCE-02`, `T5-RESOURCE-03`, consumes B1 state contracts.

**Purpose:** Build the fixed device + CPU/memory/storage presentation against the B1 state model without making it the formal shell root yet.

**Files:**
- Create: `lib/new_ui/dashboard/overview_page.dart`
- Create: `lib/new_ui/dashboard/widgets/device_summary.dart`
- Create: `lib/new_ui/dashboard/widgets/core_resource_section.dart`
- Create: `test/new_ui/dashboard/overview_page_test.dart`
- Create: `test/new_ui/dashboard/device_summary_test.dart`
- Create: `test/new_ui/dashboard/core_resource_section_test.dart`
- Modify only as required for model-safe formatting reuse: no legacy visual widgets
- Create after GREEN: `docs/modern-ui/acceptance/2026-10-09-task-5-batch-2-core-ui-acceptance.md`

**Interfaces:**

```dart
typedef OverviewControllerFactory =
    OverviewController Function(Duration refreshInterval);

class OverviewPage extends StatefulWidget {
  const OverviewPage({
    super.key,
    required this.controllerFactory,
    required this.onOpenNotifications,
    this.connectionStatusText,
  });

  final OverviewControllerFactory controllerFactory;
  final VoidCallback onOpenNotifications;
  final String? connectionStatusText;
}
```

`OverviewPage` reads:
- hostname from the existing `InitDataProvider`;
- refresh duration from `SettingProvider.refreshDuration`;
- all live/stale source values from its owned `OverviewController`.

It owns and disposes the controller it creates.

- [ ] **Step 1: Write RED device-summary tests**

Assert:
- hostname left, uptime right;
- hostname-only and uptime-only remain valid;
- neither missing field is rendered as fake `0`/`-` identity data;
- large text scaling remains readable without horizontal overflow.

- [ ] **Step 2: Write RED core-resource tests**

CPU:
- `totalLoad` shown when available;
- fixture with 1/5/15 values shows exactly those values;
- no “10 分钟” label exists;
- `sysTemp` is labeled system temperature.

Memory:
- `realUsage` shown when available;
- absent absolute fields are omitted.

Storage:
- multiple real volumes repeat one row pattern;
- used/total/free/status use model values;
- missing fields do not create fake zero rows.

- [ ] **Step 3: Run RED widget tests**

Run:

```bash
flutter test test/new_ui/dashboard/device_summary_test.dart test/new_ui/dashboard/core_resource_section_test.dart
```

Expected: FAIL because Modern core widgets do not exist.

- [ ] **Step 4: Implement the fixed summary widgets using Task 2 visual tokens**

Use Material 3, medium-high density, 6dp capacity bars, restrained surfaces. Do not import legacy Dashboard `WidgetCard`, legacy gauges, or legacy theme components.

- [ ] **Step 5: Write RED `OverviewPage` state tests**

Assert:
- first load uses initial loading semantics;
- refreshing keeps V1 visible;
- one source error remains local while siblings remain;
- stale is explicit text/status, not opacity alone;
- pull-to-refresh calls controller refresh;
- changing `SettingProvider.refreshDuration` updates controller cadence once;
- Light/Dark both render;
- text scale representative large value produces no overflow exceptions.

- [ ] **Step 6: Implement `OverviewPage` and run GREEN tests**

The page must:
- create its controller exactly once;
- call `loadInitial()` and `startAutoRefresh()` exactly once for that controller;
- forward later `SettingProvider.refreshDuration` changes through `updateRefreshInterval()`;
- dispose the controller when the page/context is removed.

Run:

```bash
flutter test test/new_ui/dashboard/overview_page_test.dart test/new_ui/dashboard/device_summary_test.dart test/new_ui/dashboard/core_resource_section_test.dart
```

Expected: PASS.

- [ ] **Step 7: Focused regression/analyze and commit**

Run:

```bash
flutter test test/new_ui/dashboard
flutter test test/new_ui/theme test/new_ui/system
flutter analyze lib/new_ui/dashboard test/new_ui/dashboard
```

**Batch 2 Exit Gate**
- fixed core UI exists independently of shell cutover;
- missing fields are omitted rather than fabricated;
- refresh/stale visuals obey Task 2;
- Light/Dark/large-font focused tests are green.

---

# Batch 3 — Abnormal Summary

**Contracts:** `T5-ABN-01`, `T5-NOTIFY-01`.

**Purpose:** Add a pure, evidence-based abnormal classifier and a conditional Overview region without inventing thresholds or new backend calls.

**Files:**
- Create: `lib/new_ui/dashboard/overview_alerts.dart`
- Create: `lib/new_ui/dashboard/widgets/abnormal_summary.dart`
- Modify: `lib/new_ui/dashboard/overview_page.dart`
- Create: `test/new_ui/dashboard/overview_alerts_test.dart`
- Create: `test/new_ui/dashboard/abnormal_summary_test.dart`
- Modify: `test/new_ui/dashboard/overview_page_test.dart`
- Create after GREEN: `docs/modern-ui/acceptance/2026-10-09-task-5-batch-3-abnormal-summary-acceptance.md`

**Interfaces:**

```dart
enum OverviewAlertSeverity { warning, error }
enum OverviewAlertDestination { notifications, storageManager }

class OverviewAlert {
  const OverviewAlert({
    required this.id,
    required this.title,
    required this.severity,
    required this.destination,
  });
}

List<OverviewAlert> buildOverviewAlerts({
  Storage? storage,
  DsmNotify? notifications,
});
```

Classification rules are exact:
- notification `NOTIFICATION_ERROR` → error;
- notification `NOTIFICATION_WARN` → warning;
- information/unknown notification levels → excluded;
- volume `danger` → error;
- volume `attention`, `has_unverified_disk`, `read_only` → warning;
- `normal`, normal background check/scrub states, and `unknown` → excluded;
- no `usedPercent > 80` local warning rule.

- [ ] **Step 1: Write RED pure-classifier tests**

Include healthy-only, INFO-only, WARN, ERROR, abnormal-storage, normal-scrub, unknown, and duplicate notification identity fixtures.

- [ ] **Step 2: Run classifier RED test**

Run:

```bash
flutter test test/new_ui/dashboard/overview_alerts_test.dart
```

- [ ] **Step 3: Implement classifier and de-duplication**

De-duplicate only where a stable source identity can be formed. Keep error before warning.

- [ ] **Step 4: Write RED widget/page tests**

Assert:
- no abnormal region when list is empty;
- error/warning appears with text + icon/semantic label, not color alone;
- tapping alert reports its exact `OverviewAlertDestination`;
- stale notification source does not erase an already valid abnormal list until a valid replacement is available;
- ordinary notification content does not fill Overview.

Extend `OverviewPage` with:

```dart
final ValueChanged<OverviewAlertDestination>? onOpenAlertDestination;
```

- [ ] **Step 5: Implement conditional abnormal section and run GREEN tests**

Run:

```bash
flutter test test/new_ui/dashboard/overview_alerts_test.dart test/new_ui/dashboard/abnormal_summary_test.dart test/new_ui/dashboard/overview_page_test.dart
```

- [ ] **Step 6: Regression/analyze and commit**

**Batch 3 Exit Gate**
- healthy Overview has no “everything normal” card;
- no invented capacity threshold;
- notification/storage severity mapping is executable;
- global notification ownership is not moved into Overview.

---

# Batch 4 — Overview Shortcuts / Legacy Handoff

**Contracts:** `T5-SHORT-01`, `T5-SHORT-02`, `T5-SHORT-03`.

**Purpose:** Derive at most four real supported shortcuts from DSM InitData and define the legacy handoff without adding a second shortcut store/editor.

**Files:**
- Create: `lib/new_ui/dashboard/overview_shortcuts.dart`
- Create: `lib/new_ui/dashboard/widgets/shortcut_section.dart`
- Modify: `lib/new_ui/dashboard/overview_page.dart`
- Create: `test/new_ui/dashboard/overview_shortcuts_test.dart`
- Create: `test/new_ui/dashboard/shortcut_section_test.dart`
- Create: `test/new_ui/dashboard/overview_shortcut_relationship_test.dart`
- Modify: `test/new_ui/dashboard/overview_page_test.dart`
- Create after GREEN: `docs/modern-ui/acceptance/2026-10-09-task-5-batch-4-shortcuts-acceptance.md`

**Interfaces:**

```dart
class OverviewShortcut {
  const OverviewShortcut({
    required this.id,
    required this.label,
    required this.assetPath,
    required this.routeName,
    required this.legacyBuilder,
  });

  final String id;
  final String label;
  final String assetPath;
  final String routeName;
  final WidgetBuilder legacyBuilder;
}

class OverviewShortcutCatalog {
  const OverviewShortcutCatalog();

  List<OverviewShortcut> build(InitDataModel initData);
}
```

`build()` preserves DSM shortcut order, filters to supported/currently available mappings, and returns at most four items.

Extend `OverviewPage` with:

```dart
final ValueChanged<OverviewShortcut>? onOpenShortcut;
```

- [ ] **Step 1: Write RED catalog tests**

Cover:
- supported + unsupported mixed input;
- source order preserved;
- more than four eligible → first four only;
- Docker vs Container Manager mapping follows real DSM app availability;
- direct container/url shortcut preserves its real destination data;
- zero eligible result is valid.

- [ ] **Step 2: Run RED catalog tests**

- [ ] **Step 3: Implement minimal catalog by reusing the existing supported legacy destination set**

Do not copy legacy visual layout. Do not add shortcut write methods.

- [ ] **Step 4: Write RED section/page tests**

Assert:
- fixed region remains when legacy `showShortcut == false`;
- zero eligible result renders restrained empty/configuration text rather than removing the region;
- tap emits the exact `OverviewShortcut`;
- no usage-frequency auto-sort.

- [ ] **Step 5: Write legacy-handoff relationship test**

Use the emitted destination with `LegacyPageHost` and prove:
- selected legacy page opens;
- legacy theme isolation remains;
- Back returns to the same host context;
- no other primary-tab state is reset.

- [ ] **Step 6: GREEN, regression/analyze, commit**

Run:

```bash
flutter test test/new_ui/dashboard/overview_shortcuts_test.dart test/new_ui/dashboard/shortcut_section_test.dart test/new_ui/dashboard/overview_shortcut_relationship_test.dart
flutter test test/new_ui/legacy test/new_ui/app
flutter analyze lib/new_ui/dashboard test/new_ui/dashboard
```

**Batch 4 Exit Gate**
- max-four/order/filter rules proven;
- legacy hide flag cannot remove Modern shortcut structure;
- no new persistence path exists;
- legacy handoff boundary remains valid.

---

# Batch 5 — Extension Widget Configuration / Preservation

**Contracts:** `T5-WCFG-01`, `T5-WCFG-02`, `T5-EXT-03`.

**Purpose:** Implement “编辑概览” configuration safely before the Modern extension widgets themselves are added.

**Files:**
- Create: `lib/new_ui/dashboard/overview_widget_config.dart`
- Create: `lib/new_ui/dashboard/overview_widget_config_controller.dart`
- Create: `lib/new_ui/dashboard/edit_overview_page.dart`
- Modify: `lib/new_ui/dashboard/overview_page.dart`
- Create: `test/new_ui/dashboard/overview_widget_config_test.dart`
- Create: `test/new_ui/dashboard/overview_widget_config_controller_test.dart`
- Create: `test/new_ui/dashboard/edit_overview_page_test.dart`
- Modify: `test/new_ui/dashboard/overview_page_test.dart`
- Create after GREEN: `docs/modern-ui/acceptance/2026-10-09-task-5-batch-5-widget-config-acceptance.md`

**Interfaces:**

```dart
const task5OwnedOverviewWidgetIds = <String>[
  'SYNO.SDS.SystemInfoApp.ConnectionLogWidget',
  'SYNO.SDS.TaskScheduler.TaskSchedulerWidget',
];

List<String> mergeTask5OverviewModuleIds({
  required List<String> originalModuleIds,
  required List<String> editedOwnedIds,
});
```

The merge implements the exact `T5-WCFG-02` invariant from the Contract Matrix.

```dart
typedef OverviewWidgetModuleSaver =
    Future<bool?> Function(List<String> moduleIds);

class OverviewWidgetConfigController extends ChangeNotifier {
  OverviewWidgetConfigController({
    required List<String> originalModuleIds,
    required OverviewWidgetModuleSaver saveModuleIds,
  });

  List<String> get selectedOwnedIds;
  bool get saving;
  Object? get error;

  void setVisible(String moduleId, bool visible);
  void reorder(int oldIndex, int newIndex);
  Future<List<String>?> save();
}
```

`save()` returns the exact persisted merged list only on success; on failure it returns `null` and retains the pre-save authoritative state.

- [ ] **Step 1: Write RED merge tests before any controller/UI**

Required fixtures:
- core IDs before/between/after owned IDs;
- both deferred IDs;
- random unknown opaque IDs;
- owned reorder;
- owned remove;
- owned add when one owned slot exists;
- owned add when no owned slot exists;
- duplicate-free preservation;
- exact relative order of all non-owned IDs.

- [ ] **Step 2: Run merge RED test, then implement only the pure merge**

Run:

```bash
flutter test test/new_ui/dashboard/overview_widget_config_test.dart
```

- [ ] **Step 3: Write RED controller tests**

Assert:
- edit state exposes only the two Task 5-owned IDs;
- invalid/unowned ID cannot be toggled through the controller;
- save callback receives the complete merged module list;
- save failure does not report success or mutate source-authoritative module IDs;
- save success returns the exact merged list.

- [ ] **Step 4: Implement controller and run GREEN tests**

- [ ] **Step 5: Write RED edit-page tests**

UI:
- two extension rows;
- show/hide;
- drag/reorder only selected owned extensions;
- Save disabled/progress while saving;
- Cancel does not save;
- core summary is absent from editable controls;
- unknown/deferred IDs are never presented as deletable Task 5 items.

- [ ] **Step 6: Implement edit page and Overview entry action**

Use the one allowed page-specific App Bar action beside the global notification action.

Production save wiring must call the existing:

```dart
initData.userSettings?.apply(mergedModuleIds)
```

Only after true success:
- update `synoSDSWidgetInstance.moduleList` to the returned merged list;
- call the existing `InitDataProvider.notify()`.

- [ ] **Step 7: Focused regression/analyze and commit**

Run:

```bash
flutter test test/new_ui/dashboard/overview_widget_config_test.dart test/new_ui/dashboard/overview_widget_config_controller_test.dart test/new_ui/dashboard/edit_overview_page_test.dart test/new_ui/dashboard/overview_page_test.dart
flutter analyze lib/new_ui/dashboard test/new_ui/dashboard
```

**Batch 5 Exit Gate**
- opaque/deferred/core IDs cannot be lost;
- only Task 5-owned extension IDs are user-editable here;
- save failure leaves authoritative state unchanged;
- no extension data polling/UI has started.

---

# Batch 6 — CurrentConnection / TaskScheduler Modern Extensions

**Contracts:** `T5-EXT-01`, `T5-EXT-02`, consumes `T5-WCFG-01/02` and B1 refresh contracts.

**Purpose:** Add the two Task 5-owned extension summaries to the same controller-owned refresh lifecycle.

**Files:**
- Modify: `lib/new_ui/dashboard/overview_data_source.dart`
- Modify: `lib/new_ui/dashboard/overview_controller.dart`
- Modify: `lib/new_ui/dashboard/overview_page.dart`
- Create: `lib/new_ui/dashboard/widgets/current_connection_extension.dart`
- Create: `lib/new_ui/dashboard/widgets/task_scheduler_extension.dart`
- Modify: `test/new_ui/dashboard/overview_controller_test.dart`
- Create: `test/new_ui/dashboard/current_connection_extension_test.dart`
- Create: `test/new_ui/dashboard/task_scheduler_extension_test.dart`
- Create: `test/new_ui/dashboard/overview_extension_relationship_test.dart`
- Create after GREEN: `docs/modern-ui/acceptance/2026-10-09-task-5-batch-6-extensions-acceptance.md`

**Interface extensions:**

Add to `OverviewDataSource`:

```dart
final Future<CurrentConnection?> Function() loadCurrentConnections;
final Future<TaskScheduler?> Function() loadTaskScheduler;
```

Production factory uses only `CurrentConnection.get()` and `TaskScheduler.list()`.

Add to `OverviewController`:

```dart
OverviewSourceState<CurrentConnection> get currentConnections;
OverviewSourceState<TaskScheduler> get taskScheduler;

void updateEnabledExtensions(Set<String> moduleIds);
```

Rules:
- extension source loads only when its owned module ID is enabled;
- both use the same manual/automatic refresh cycle as the core;
- disabling an extension stops future loads and removes its visible extension state from Overview;
- no second timer/controller polling loop is allowed.

- [ ] **Step 1: Write RED controller extension tests**

Cover:
- neither extension selected → neither loader called;
- each selected independently;
- both selected;
- refresh success/empty/failure/stale independently;
- toggle enabled set while mounted;
- automatic tick still has one refresh owner;
- disabled extension does not publish a delayed result after it is disabled.

- [ ] **Step 2: Implement the minimum B6 controller/data-source extension**

- [ ] **Step 3: Write RED CurrentConnection widget tests**

Assert:
- successful empty means no current connections;
- compact nonempty summary uses real user/source fields;
- stale prior data remains readable;
- no kick/disconnect button or `kickConnection()` path is exposed.

- [ ] **Step 4: Write RED TaskScheduler widget tests**

Assert:
- successful empty means no scheduled tasks;
- compact summary uses real name/next-trigger/enabled data where available;
- stale prior data remains readable;
- no run/enable/delete/edit mutation control is exposed.

- [ ] **Step 5: Implement the two read-only extension widgets**

- [ ] **Step 6: Write relationship tests for configuration → polling → display**

Change module list through the B5 provider/config result and assert:
- only selected extension appears;
- corresponding loader begins/stops;
- core resources remain unchanged;
- deferred/unknown IDs do not create empty phantom extensions.

- [ ] **Step 7: Full Task 5 focused regression/analyze and commit**

Run:

```bash
flutter test test/new_ui/dashboard
flutter test test/new_ui/session test/new_ui/legacy test/new_ui/app
flutter analyze lib/new_ui/dashboard test/new_ui/dashboard
```

**Batch 6 Exit Gate**
- selected extension IDs control real data summaries;
- no duplicated polling;
- mutation capabilities remain legacy-only;
- B5 configuration preservation still passes.

---

# Batch 7 — Formal Overview Shell Cutover / Relationship / Device Gate

**Contracts:** `T5-CTX-01`, `T5-AUTH-01`, `T5-NOTIFY-01`, `T5-SHELL-01`, `T5-FALLBACK-01`, `T5-APK-01`, plus inherited `G-NAV-03`, `G-SESS-01`, `G-STATE-01`, `G-NET-01`, `G-NOTIFY-01`, `APK-IDENTITY-01`.

**Purpose:** Make Modern Overview the formal 概览 root only after B1-B6 are independently green, then prove whole-shell/context behavior and perform the real-device Gate.

**Files:**
- Modify: `lib/new_ui/app/new_ui_app_shell.dart`
- Modify: `lib/new_ui/app/dsm_new_ui_shell.dart`
- Modify: `lib/new_ui/app/modern_ui_root.dart`
- Modify only if required for reusable App Bar chrome: `lib/new_ui/shell/new_ui_primary_page.dart`
- Modify: `test/new_ui/app/new_ui_app_shell_test.dart`
- Modify: `test/new_ui/wiring/production_wiring_test.dart`
- Create: `test/new_ui/dashboard/overview_shell_relationship_test.dart`
- Create: `test/new_ui/dashboard/overview_context_switch_relationship_test.dart`
- Reuse/regress: `test/new_ui/auth/server_auth_relationship_test.dart`
- Create after automated + user Gate: `docs/modern-ui/acceptance/2026-10-09-task-5-dashboard-acceptance.md`
- Modify after final acceptance only: `docs/modern-ui/2026-10-06-dsm-helper-modern-ui-master-plan.md`

**Shell interface change:**

Add an optional Modern root builder without changing fallback behavior for the other four destinations:

```dart
typedef NewUiModernRootBuilder = Widget Function(
  BuildContext context, {
  required VoidCallback onOpenNotifications,
  required String? connectionStatusText,
});

class NewUiAppDestination {
  const NewUiAppDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.legacyBuilder,
    this.modernBuilder,
    this.onLegacyBack,
  });

  final NewUiModernRootBuilder? modernBuilder;
}
```

`NewUiAppShell` behavior:
- `modernBuilder == null` → existing `NewUiPrimaryPage` placeholder + legacy-open behavior unchanged;
- `modernBuilder != null` → builder becomes that tab's root and receives the same global notification callback and connection-status text.

Only 概览 receives `modernBuilder` in Task 5. Its existing `legacyBuilder: (_) => Dashboard()` remains in the destination definition; legacy Dashboard source is not deleted.

Runtime auth seam added in the same Batch:

```dart
class DsmNewUiShell extends StatefulWidget {
  // existing arguments retained
  final VoidCallback? onReauthNeeded;
  final OverviewControllerFactory? overviewControllerFactory;
}
```

Production uses the default Overview controller factory. The optional factory is a relationship-test seam only.

`ModernUiRoot` adds one internal helper:

```dart
Future<void> _reauthSavedAccountIds({
  required int serverId,
  required int accountId,
});
```

Existing startup `_reauthSaved(StartupSavedContext)` delegates to this helper. The shell's `onReauthNeeded` parses the already-active `contextId` and calls the same helper, so startup 119 and runtime 119 converge on one saved-account reauthentication implementation.

- [ ] **Step 1: Write RED generic shell test for one Modern root**

Assert:
- one destination may use `modernBuilder`;
- other four still use existing placeholder/legacy fallback;
- Modern root receives global notification callback and connection status;
- tab stacks and Back semantics remain unchanged.

- [ ] **Step 2: Implement the minimal generic shell seam**

Do not special-case the label string inside `NewUiAppShell`; use the explicit optional builder.

- [ ] **Step 3: Write RED production-wiring tests**

Assert `DsmNewUiShell`:
- wires 概览 to `OverviewPage`;
- creates production `OverviewDataSource`;
- uses current `SettingProvider.refreshDuration`;
- forwards global notification action;
- preserves connection-status text;
- leaves Files/Applications/Tasks/My destinations on the existing paths;
- retains `Dashboard()` as legacy fallback source definition.

- [ ] **Step 4: Wire Modern Overview into `DsmNewUiShell`**

Shortcut destinations must be opened through the existing provider-wrapped `LegacyPageHost`.

Alert destination routing:
- notifications → existing global notification entry;
- storage manager → existing Storage Manager page via `LegacyPageHost`.

The production Overview controller receives `onAuthInvalidated: (_) => widget.onReauthNeeded?.call()`.

Do not add a second global Navigator/shell.

- [ ] **Step 5: Write runtime-119 RED relationship tests**

Cover:
- shell is already active for saved Server A + Account A;
- one Overview source throws `DsmException(119)`;
- `ModernUiRoot` enters the existing saved-account reauthentication path for A rather than selector/offline;
- two Overview sources returning 119 in the same refresh still start one reauth;
- transport failure and non-119 DSM failure do not start reauth;
- Account/default persistence remains unchanged until the existing auth flow succeeds.

- [ ] **Step 6: Implement the minimum runtime reauth seam**

Refactor the existing startup reauth lookup body into `_reauthSavedAccountIds(serverId:, accountId:)`; make both startup `_reauthSaved` and shell runtime invalidation call that helper. Reuse `_beginLogin(... automatic: true)` and the existing `AuthFlowController`.

No global Dio interceptor and no second session state machine are allowed.

- [ ] **Step 7: Write A→B context-switch relationship RED→GREEN test**

Prove:
- A Overview loads unique hostname/resource/notification values;
- Task 3/4 context switch resets shell to Overview root;
- B starts clean for its context;
- a delayed A completion after switch is ignored;
- no A shortcut/config/extension state is rendered under B.

- [ ] **Step 8: Write global notification + navigation relationship tests**

From Overview and at least one non-Overview tab:
- open notifications;
- return without losing selected tab/root state;
- simulate Overview source failure/disposal and prove notification entry still works;
- open a legacy shortcut and Back returns correctly;
- Task 4 account-management/logout callbacks still route correctly.

- [ ] **Step 9: Run full targeted regression locally when a compatible Flutter environment exists**

Run:

```bash
flutter test test/new_ui
flutter analyze lib/new_ui test/new_ui
```

Then run the complete suite:

```bash
flutter test
```

Expected: all tests PASS; analyze has no new issues.

If the execution environment lacks compatible Flutter/Android tooling, do not fabricate local results. Use the existing GitHub Actions RED→GREEN workflow exactly as in Task 4 and record the actual run IDs.

- [ ] **Step 10: Push the final implementation commit and verify Android CI**

Required CI evidence:
- complete `flutter test`;
- targeted `flutter analyze lib/new_ui test/new_ui`;
- `flutter build apk --debug --flavor beta`;
- package id `top.apaipai.dsm_helper`;
- signing certificate SHA-256 `0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2`;
- APK artifact uploaded.

Do not repeatedly rerun an unchanged commit merely because a workflow is slow. Inspect the run/job logs and only rerun when the evidence is genuinely incomplete.

- [ ] **Step 11: User real-device Gate**

Install the new CI APK directly over the accepted Task 4 APK without uninstalling.

Required observations for the user's current HTTP LAN deployment:
1. install succeeds and existing saved login/data remains;
2. cold start enters Modern 概览 directly;
3. real hostname/uptime/CPU/memory/storage display plausibly and without duplicate legacy Dashboard chrome;
4. pull-to-refresh keeps old data visible while refreshing;
5. temporary network loss keeps last-valid data visibly stale/offline and does not force Login;
6. network restoration refreshes to live state;
7. Light and Dark remain readable;
8. representative larger Android font scaling remains usable;
9. shortcuts open expected legacy capability and Back returns to Overview;
10. edit Overview can show/hide/reorder the two Task 5-owned extensions without losing other DSM widget configuration;
11. global DSM notifications remain accessible;
12. navigation to Files/Applications/Tasks/My remains unchanged.

Scenarios already explicitly outside the user's Task 4 physical-device scope (HTTPS/self-signed, second account, OTP, forced 119) are not silently reclassified as tested by Task 5. They block Task 5 only if Task 5 introduces a dependency on them; this plan does not.

- [ ] **Step 12: Final diff and relationship audit**

Compare Task 5 branch to `modern-ui`:
- no unrelated legacy rewrite;
- no legacy Dashboard deletion;
- no Task 6 code;
- no new transport/session authority;
- no unknown DSM widget ID deletion logic;
- no CurrentConnection/TaskScheduler Modern mutation actions.

- [ ] **Step 13: Write final acceptance and update Master Plan only after user Gate**

Record:
- exact final implementation SHA;
- exact CI run/job/artifact;
- test/analyze/build counts;
- package/signing evidence;
- user-tested device observations;
- any expressly untested scenario as NOT TESTED, never as accepted.

Then mark Task 5 complete in the Master Plan. This final docs-only closure follows `CI-DOCS-01`.

**Batch 7 / Task 5 Exit Gate**
- Modern Overview is the formal 概览 root;
- B1-B6 contracts remain green;
- A→B context isolation is executable;
- runtime DSM 119 converges on the existing same-account reauthentication flow without duplicate reauth;
- global notifications and legacy handoff remain independent;
- Android CI and stable APK identity pass;
- user real-device Gate passes for the declared deployment scope;
- legacy Dashboard source remains intact;
- Task 6 has not started.

---

## Batch Execution Order

Execute strictly:

```text
B1 → B2 → B3 → B4 → B5 → B6 → B7
```

No Batch may be skipped merely because a later Batch appears to cover similar behavior.

At every Batch boundary:
1. re-read this plan, the Feature Design, Contract Matrix, prior Batch acceptance, current branch HEAD and current CI state;
2. confirm the exact Batch file boundary before editing;
3. use TDD RED→GREEN for behavior changes;
4. run the listed focused regression;
5. inspect diff for scope leakage;
6. commit only the current Batch;
7. record real evidence, not assumed results;
8. do not automatically start the next Batch.

## Plan Completion Gate

This plan is complete when:
- all seven Batch scopes, interfaces, tests and Exit Gates are explicit;
- each feature-level Task 5 contract maps to at least one executable Batch;
- no unresolved placeholder or open semantic choice remains in the plan;
- no production/test code has been changed by planning;
- Batch 1 remains unstarted until the user explicitly authorizes execution.
