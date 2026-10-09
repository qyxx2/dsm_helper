# DSM Helper Modern UI — Task 5 Dashboard Feature Design

> Status: Preflight complete — awaiting user review  
> Date: 2026-10-09  
> Task: Task 5 — Dashboard  
> Branch: `feature/t5-dashboard`  
> Integration branch: `modern-ui`  
> Base: `modern-ui@701ad9e5ae93f5ecf6b5d71657686d8893e08475`  
> Architecture path: Thin Overview adapter / independent source state

## 1. Purpose

Task 5 replaces the legacy Dashboard entry with the first complete Modern UI core page: Overview / 概览.

The goal is not to port the legacy Dashboard widget tree one-to-one. The goal is to implement the approved Overview product structure while reusing the existing DSM models, provider/bootstrap context, settings and legacy feature destinations.

Task 5 must prove that the Modern UI visual direction, information density and refresh semantics work against real DSM data without creating a second DSM backend authority.

## 2. Authoritative Inputs

Task 5 is governed by:

- `docs/modern-ui/2026-10-06-dsm-helper-modern-ui-master-plan.md`
- `docs/modern-ui/specs/2026-10-07-dsm-helper-modern-ui-spec.md`
- `docs/modern-ui/specs/2026-10-07-dsm-helper-modern-ui-visual-design.md`
- `docs/modern-ui/contracts/2026-10-07-global-interface-protocol-inventory.md`
- `docs/modern-ui/contracts/2026-10-07-global-contract-matrix.md`
- `docs/modern-ui/acceptance/2026-10-08-task-4-server-auth-acceptance.md`
- current `modern-ui` code at the base above.

This document adds only Task 5 feature-level decisions. It does not redefine the project-wide contracts.

## 3. Existing Authorities Confirmed by Audit

Task 5 reuses these existing sources:

| Concern | Authority |
| --- | --- |
| DSM context/bootstrap | Task 3/4 active context + `LegacySharedBootstrap` / `InitDataProvider` |
| Device name | `InitDataModel.session.hostname` |
| Uptime/system metadata | `System.info()` / `System.upTime` |
| CPU/memory/resource samples | `Utilization.get()` |
| Storage | `Storage.loadInfo()` |
| DSM notifications | `DsmNotify.notify()`, `DsmNotifyStrings.get()` |
| Current connections | `CurrentConnection.get()` |
| Scheduled tasks | `TaskScheduler.list()` |
| Automatic refresh period | `SettingProvider.refreshDuration` |
| DSM desktop shortcuts | `InitDataModel.userSettings.desktop.shortcutItems` + `validAppviewOrder` |
| DSM widget configuration | `InitDataModel.userSettings.synoSDSWidgetInstance.moduleList` + `UserSettings.apply(List<String>)` |
| Legacy feature destinations | existing pages hosted through `LegacyPageHost` |

Existing `SystemInfoProvider`, `UtilizationProvider`, and `StorageProvider` contain current values but do not encode last-valid / refreshing / stale / per-source failure state. They remain reusable value holders; they are not sufficient by themselves to satisfy Task 5 state contracts.

## 4. Architecture

Task 5 uses a **thin Overview orchestration layer** under `lib/new_ui/dashboard/**`.

Target flow:

```text
Modern Overview
      ↓
Overview controller/state
      ↓
existing System / Utilization / Storage / Notify / CurrentConnection / TaskScheduler authorities
      ↓
existing active DsmApi context
```

Rules:

- Do not create a second DSM transport, session, repository, or provider architecture.
- Do not move DSM request logic out of existing model authorities merely for structural cleanliness.
- The Overview state layer owns only request orchestration, refresh timing, last-valid state, source-local failure metadata, and presentation-ready composition.
- Polling belongs to the Overview lifecycle/controller, not recursively self-scheduling individual widgets.
- Controller/timer lifetime must end when the Overview is disposed or the DSM context changes.
- Task 3/4 context switching remains authoritative; Task 5 must never publish mixed data from two NAS contexts.

## 5. Data Fetch and Batch Decision

Core Overview sources are fetched independently.

Task 5 does **not** use `DsmApi.batch` as the default mechanism for the core Overview because:

- global contract `G-DSM-02` records weaker batch failure semantics;
- Task 5 requires source-local partial failure;
- an empty batch result must not be confused with a valid empty data set.

Therefore the normal core path is:

- `System.info()`
- `Utilization.get()`
- `Storage.loadInfo()`
- `DsmNotify.notify()`

Independent requests may run concurrently, but each source publishes success/failure separately.

A later Task 5 implementation may use batch only for a narrowly scoped source after proving member-error and empty-result semantics with executable tests. Batch use is not required for Task 5 completion.

## 6. Refresh and State Semantics

Task 5 inherits `G-STATE-01` and `G-NET-01`.

Each refreshable source has independent state sufficient to distinguish:

- no data yet / loading;
- valid;
- refreshing with valid data;
- stale after refresh failure;
- initial error with no usable data;
- unavailable capability when the source is not supported.

Rules:

1. A refresh never clears last-valid data before replacement data succeeds.
2. Failure of one source does not convert the whole Overview into a page error when other core data remains usable.
3. Network failure is stale/offline, not logout.
4. Auth invalidation continues to be classified by the existing session/auth layer.
5. Initial page loading may use progress/skeleton according to the Task 2 visual contract.
6. Manual refresh uses pull-to-refresh.
7. Automatic refresh uses `SettingProvider.refreshDuration` as the Task 5 cadence authority. Legacy hard-coded 30-second recursive loops are not copied into the Modern Overview.
8. A manual refresh attempts all currently supported Overview sources and preserves all prior valid source values until replacements succeed.
9. Duplicate widget-owned timers are prohibited.

The shell owns the global offline/reconnecting App Bar status. Overview data may be marked stale, but it must not duplicate a second full-page connection banner.

## 7. Fixed Overview Structure

The Modern Overview order is frozen as:

1. compact device summary;
2. core resource area;
3. abnormal summary when non-empty;
4. fixed shortcut region;
5. configurable extension widgets.

The first four structural regions are not removed by DSM widget configuration. The abnormal region is conditionally absent when there is no qualifying abnormality.

### 7.1 Device summary

The device summary is a low-height strip:

- left: `InitDataModel.session.hostname`;
- right: `System.upTime`, formatted using the existing uptime formatting semantics.

Missing values are omitted rather than replaced with invented values.

Connection/offline state stays in the App Bar/shell and is not duplicated in this strip.

### 7.2 Core resources

CPU, memory and storage use one consistent row-oriented visual language. They are not three large independent hero cards.

CPU authority:

- usage: `Utilization.cpu.totalLoad`;
- optional load averages: the real model exposes 1/5/15-minute values (`minLoad1`, `minLoad5`, `minLoad15`), so Task 5 must never synthesize a 10-minute value;
- temperature: `System.sysTemp` may be shown only as system temperature; it must not be relabeled as CPU temperature without a source proving that meaning.

Memory authority:

- usage: `Utilization.memory.realUsage`;
- absolute memory values may be shown only using verified existing model/unit semantics;
- missing values are omitted.

Storage authority:

- `Storage.volumes`;
- volume display name/status;
- `size.used`, `size.total`, `size.free` and derived percentage when valid;
- filesystem/type/temperature fields only when the model exposes a correctly identified value.

Multiple volumes repeat the same compact presentation.

Task 5 does not create Resource Monitor charts inside the Overview. Full monitoring remains a separate feature destination.

## 8. Abnormal Summary

The abnormal summary exists only for explicit, meaningful abnormalities.

Allowed Task 5 sources:

- DSM notifications with explicit warning/error severity;
- storage states whose existing model/enum explicitly classifies them as attention/warning/read-only/danger or equivalent abnormal state.

Rules:

- ordinary information notifications do not appear in the abnormal summary;
- background work such as normal scrubbing/checking is not automatically promoted to an error;
- unknown/unavailable data is not treated as abnormal;
- Task 5 does not invent a local storage-capacity warning threshold merely because the legacy UI changed color above 80%;
- DSM-originated low-capacity warnings may surface through notification/storage status authorities;
- items sort by severity/importance, not by data-source grouping;
- duplicate manifestations of the same condition should be de-duplicated when a stable identity exists.

Container failures are not fetched through a new Container Manager API in Task 5. They may appear if DSM already emits them as qualifying notifications.

## 9. Global DSM Notifications Boundary

The global notification icon remains a shell/App Bar capability under `G-NOTIFY-01`.

Task 5 may read notifications for the abnormal summary, but:

- the global notification entry must continue to work when Overview is not mounted;
- opening/clearing the notification page must not depend on Overview controller lifetime;
- Task 5 does not rewrite the notification page.

## 10. Shortcuts

The Overview contains a fixed shortcut region with at most four visible shortcuts in one portrait-phone row.

Authority:

- source order/content: DSM `Desktop.shortcutItems`;
- capability filter: existing supported legacy mapping plus current DSM application availability (`validAppviewOrder`) where applicable;
- destination: existing supported feature page through `LegacyPageHost` until that feature is migrated.

Rules:

- preserve source order; do not auto-sort by use frequency;
- unsupported or unavailable entries are skipped rather than shown disabled;
- show at most the first four eligible entries;
- no Task 5 local duplicate shortcut database/preference is introduced;
- Task 5 does not invent a new DSM shortcut write protocol.

The legacy `SettingProvider.showShortcut` flag remains a legacy Dashboard presentation preference. It does not remove the Modern Overview shortcut region because the approved Modern product spec defines that region as fixed. If zero eligible shortcuts exist, the region uses a restrained empty/configuration state instead of disappearing.

Task 5 treats the existing DSM Desktop shortcut configuration as the current user-configurable authority. A new in-app shortcut editor is outside Task 5 unless a later explicit decision adds one.

## 11. Extension Widgets

Modern Overview uses:

```text
fixed core summary + configurable extension widgets
```

The DSM widget module list remains the persistence authority.

### 11.1 Core-equivalent legacy widget IDs

These legacy widget IDs are represented by the fixed Modern core and are not rendered again as removable extension duplicates:

- `SYNO.SDS.SystemInfoApp.SystemHealthWidget`
- `SYNO.SDS.ResourceMonitor.Widget`
- `SYNO.SDS.SystemInfoApp.StorageUsageWidget`

Their existing module-list entries are preserved; Task 5 does not delete them merely because Modern Overview absorbs their information.

### 11.2 Task 5 Modern extension IDs

Task 5 modernizes these extension summaries:

- `SYNO.SDS.SystemInfoApp.ConnectionLogWidget` → current-connection summary;
- `SYNO.SDS.TaskScheduler.TaskSchedulerWidget` → scheduled-task summary.

Task 5 versions are read-only summaries. Direct `kickConnection()` and scheduled-task `run()` mutations are not migrated into Modern Overview in Task 5. Existing legacy pages/capabilities remain available; Task 5 does not delete those operations.

### 11.3 Deferred widget IDs

These known legacy module IDs are preserved but are not modernized in Task 5:

- `SYNO.SDS.SystemInfoApp.FileChangeLogWidget`
- `SYNO.SDS.SystemInfoApp.RecentLogWidget`

Unknown module IDs are also treated as opaque preserved configuration.

Task 5 must not silently drop a deferred or unknown module ID during save.

### 11.4 Safe save semantics

`UserSettings.apply(List<String>)` replaces the complete DSM widget module list. Therefore Modern edit mode may mutate only the Task 5-owned extension subsequence while preserving all non-owned IDs.

The save rule is:

- preserve every non-owned ID exactly once and in its existing relative order;
- replace the existing Task 5-owned subsequence with the edited Task 5-owned ordered subsequence;
- reuse existing owned slots in order;
- newly added owned IDs beyond existing owned slots are inserted immediately after the last existing owned slot, or appended when no owned slot existed;
- removing a Task 5-owned extension removes only that owned ID;
- core-equivalent, deferred and unknown IDs remain untouched.

This rule is required because sending only the Modern-supported list to `UserSettings.apply` would destroy unrelated DSM widget configuration.

## 12. Edit Overview Mode

An explicit “编辑概览” mode manages only Task 5-owned extension widgets.

It supports:

- show/hide current connections;
- show/hide scheduled tasks;
- reorder those Task 5-owned extensions;
- save/cancel.

It does not expose drag handles or delete controls during normal browsing.

The fixed device/resource/abnormal/shortcut structure cannot be removed or reordered by this mode.

## 13. Current Connection and Task Scheduler Extension Semantics

### Current connections

- data authority: `CurrentConnection.get()`;
- display a compact count/list summary appropriate to available data;
- initial empty result means no current connections only after a successful request;
- refresh failure retains the last valid summary and marks it stale;
- `kickConnection()` is not a Task 5 Modern action.

### Task Scheduler

- data authority: `TaskScheduler.list()`;
- display a compact upcoming/enabled task summary using existing task data;
- an empty successful task list is a real empty state;
- refresh failure retains last valid tasks and marks the extension stale;
- task run/enable/delete/edit operations are not migrated into the Task 5 Overview.

Full management remains in existing legacy capability until its own migration scope.

## 14. Context Switching and Lifecycle

Task 5 inherits the Task 3/4 single-active-context model.

When DSM context changes:

- old Overview controller/timers are disposed;
- no System/Utilization/Storage/Notify/Connection/Task data from context A may appear under context B;
- B begins from its own initial/loading or offline/stale-safe state;
- shell resets to Overview root according to existing `G-NAV-03`.

Background resume may trigger a refresh based on normal data freshness, but it must not reset tab/navigation state.

## 15. Shell Cutover Boundary

Until Task 5 passes its final automated and real-device Gate, the legacy Dashboard remains available as fallback/reference.

Final Task 5 integration changes the 概览 root from the generic Modern placeholder / explicit legacy-open flow to the Modern Overview.

The cutover must preserve:

- five-tab shell;
- global notification action;
- connection-status App Bar semantics;
- legacy hosting for not-yet-migrated destinations;
- account-management/session behavior from Task 4;
- stable APK package/signing identity.

Legacy Dashboard source files are not deleted in Task 5. Fallback removal is a separate later decision.

## 16. Explicit Non-Goals

Task 5 does not:

- rewrite `DsmApi`, API discovery, session, Drift, or providers;
- build a new repository/service architecture;
- migrate Resource Monitor charts;
- migrate Storage Manager detail;
- rewrite the notification page;
- implement a new shortcut persistence protocol;
- modernize Recent Log or File Change Log widgets;
- migrate current-connection kick actions;
- migrate scheduled-task run/enable/delete/edit operations;
- remove the legacy Dashboard;
- begin Task 6.

## 17. Required Verification Classes

### Unit / controller

Must prove:

- independent source success/failure;
- V1 → refresh failure → V1 stale → V2 replacement;
- initial error differs from successful empty;
- manual and automatic refresh do not clear last-valid data;
- context switch/dispose cancels old polling publication;
- extension merge/save preserves opaque IDs;
- shortcut filtering/order/max-four behavior;
- abnormal classification excludes normal/info states.

### Widget

Must prove:

- device summary and core resource composition;
- missing data is omitted, not fabricated;
- partial failure remains localized;
- stale data remains readable and explicitly marked;
- Light/Dark and large-font layout remains usable;
- fixed Overview regions cannot be removed in edit mode;
- extension edit reorder/show/hide behavior;
- pull-to-refresh.

### Relationship / integration

Must prove:

- active context A → B cannot leak A Overview data;
- global notification entry works independently of Overview lifetime;
- legacy shortcut navigation is hosted through the existing legacy boundary;
- Task 4 logout/account management behavior remains intact;
- shell tab stacks and Back behavior remain intact after Overview cutover.

### CI / device

Final Task 5 Gate requires:

- complete `flutter test`;
- targeted `flutter analyze lib/new_ui test/new_ui`;
- Android beta debug APK build;
- package/signature identity assertion;
- install over the previously installed Modern UI APK without uninstalling;
- real DSM Overview data;
- pull-to-refresh and automatic refresh;
- temporary network loss with last-valid/stale behavior;
- Light/Dark visual density;
- portrait phone / large-font sanity;
- shortcut and extension navigation/configuration actually usable.

## 18. Preflight Resolutions

The following previously open implementation questions are resolved by this design:

1. **Core batch or independent calls:** independent calls.
2. **Provider values without stale/error metadata:** add a thin Task 5 presentation/orchestration state layer; do not replace DSM authorities.
3. **Legacy recursive polling:** do not copy it; controller owns refresh lifecycle.
4. **Refresh cadence:** `SettingProvider.refreshDuration`.
5. **1/5/10 load wording vs real model:** display only actual 1/5/15 values when used; never synthesize 10-minute data.
6. **System temperature meaning:** label as system temperature, not CPU temperature.
7. **Storage warning threshold:** do not invent one; use explicit DSM/model abnormal semantics.
8. **Legacy `showShortcut`:** does not hide the fixed Modern shortcut region.
9. **Shortcut editing:** consume existing DSM Desktop shortcut configuration; no new write protocol in Task 5.
10. **Core legacy widgets:** absorbed by fixed core but their module IDs remain persisted.
11. **Connection/Task Scheduler operations:** Modern Task 5 summaries are read-only; mutations remain legacy capability.
12. **Recent/File-change logs:** deferred from Modern Task 5 and preserved in configuration.
13. **Widget full-list save risk:** opaque/non-owned module IDs are preservation-protected.

No blocking Task 5 Contract Gap remains after these resolutions.

## 19. Preflight Exit Gate

Task 5 Feature Design Preflight passes when:

- this Feature Design is committed;
- the Task 5 Contract Matrix is committed;
- Task 5 data/refresh/context/configuration authorities are explicit;
- no blocking Contract Gap remains;
- no production/test code was changed;
- no Batch implementation has started;
- user reviews this written design before Batch Execution Plan creation.
