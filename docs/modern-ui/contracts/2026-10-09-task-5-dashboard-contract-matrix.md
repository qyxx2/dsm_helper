# DSM Helper Modern UI — Task 5 Dashboard Contract Matrix

> Status: Approved — Batch planning authorized  
> Date: 2026-10-09  
> Task: Task 5 — Dashboard  
> Branch: `feature/t5-dashboard`  
> Base: `modern-ui@701ad9e5ae93f5ecf6b5d71657686d8893e08475`  
> Feature design: `docs/modern-ui/specs/2026-10-09-task-5-dashboard-feature-design.md`

## 1. Purpose

This matrix freezes Task 5 feature-level behavior that is not already fully specified by the global contracts.

Inherited global contracts remain authoritative, especially:

- `G-DSM-01`
- `G-DSM-02`
- `G-SESS-01`
- `G-NAV-03`
- `G-STATE-01`
- `G-NET-01`
- `G-NOTIFY-01`
- `G-PREF-01`
- `APK-IDENTITY-01`
- `CI-DOCS-01`

## 2. Feature Contracts

| ID | Operation / Type | Preconditions | Authorities | Expected State Delta | Must Remain Unchanged | Failure / Rollback | Observable Result | Executable Invariant Proof |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| T5-DATA-01 | Core Overview source load | Active DSM context exists; source capability available | `System.info`, `Utilization.get`, `Storage.loadInfo`, `DsmNotify.notify` | Each source independently publishes a valid value and freshness metadata | Active Server/Account, other source values, navigation | One source failure changes only that source state; generic network failure never logs out | Available core regions render even if a sibling source fails | Inject 4 source callbacks; fail each one separately and prove other 3 remain valid |
| T5-DATA-02 | Initial empty vs initial failure | Source has no last-valid value | Existing model result + thrown DSM/network error | Successful empty becomes Empty; error becomes Error/Offline as classified | No fabricated model values | Empty result must not be created from caught exception or empty batch ambiguity | User can distinguish “none” from “could not load” | Success-empty test + thrown-error test for each source class used |
| T5-STATE-01 | Last-valid refresh | Source already has valid V1 | `G-STATE-01`, Task 5 controller | Refreshing keeps V1; success V2 atomically replaces V1; failure keeps V1 and marks stale | Navigation, other sources, account/session persistence | Failed refresh never zeros or clears V1 | V1 visible while refreshing/failing, then V2 after success | V1 → refresh start → failure → assert V1+stale → success V2 → assert V2+valid |
| T5-STATE-02 | Partial failure isolation | At least one Overview source is usable | Independent source state | Failed section gets local state only | Valid sibling regions and fixed page structure | No full-page error unless no usable core data exists | Overview stays usable with localized error/stale status | CPU valid + Storage failure; Storage valid + Notify failure; assert usable page |
| T5-REFRESH-01 | Automatic refresh | Overview mounted; active context unchanged | `SettingProvider.refreshDuration` | Refresh cycle starts at configured cadence | No duplicate timers; no route reset | Dispose/context change cancels old publication | Data updates without widget-local recursive polling | Fake clock/controller test; assert one cadence owner and cancellation |
| T5-REFRESH-02 | Manual refresh | Overview mounted | Pull-to-refresh + same Task 5 source loaders | All supported sources are requested; successful replacements publish independently | Last-valid values until each source succeeds | Failed source remains last-valid/stale; no login redirect on transport failure | Pull gesture refreshes page without blanking it | Trigger manual refresh with mixed success/failure and assert per-source result |
| T5-AUTH-01 | Runtime authenticated-session invalidation | Shell/Overview active; any source request throws `DsmException` code `119` | `DsmException`, `G-NET-01`, existing `ModernUiRoot` / `AuthFlowController` saved-account reauth | Overview emits one invalidation signal; root transitions the same Server + Account through existing reauthentication | Saved Account/default record, unrelated contexts, non-auth source state until transition | Non-119 DSM errors stay local; transport failures stay offline/stale; concurrent 119s must not start duplicate reauth | User is taken through the existing same-account reauth path rather than seeing 119 as offline or being logged out | Two sources throw 119 in one cycle → one callback/reauth; non-119 + timeout → zero reauth callbacks; same account identity preserved |
| T5-CTX-01 | DSM context switch isolation | Context A active, then Task 3/4 activates B | `G-SESS-01`, `G-NAV-03`, context-keyed Modern shell | A controller/timers become dead; B Overview initializes only from B | Persisted A account and unrelated global preferences | Failed B request cannot cause A data to appear under B | Overview root for B never displays A hostname/resources/notifications | Seed unique A values; switch to B; deliver delayed A callback; assert ignored |
| T5-DEVICE-01 | Device summary | InitData/System source available | `InitDataModel.session.hostname`, `System.upTime` | Presentation only | DSM state | Missing field omitted; no synthetic placeholder identity | Low-height hostname + uptime strip | Widget tests for both values, each missing separately, large font |
| T5-RESOURCE-01 | CPU resource row | Valid Utilization/System values | `cpu.totalLoad`, optional `minLoad1/5/15`, `System.sysTemp` | Presentation only | Source models | Missing field omitted; 10-minute load/CPU-temp meaning must not be invented | CPU usage and only actually available metrics are labeled correctly | Fixture with 1/5/15 values; assert no 10-minute label; sysTemp labeled system temp |
| T5-RESOURCE-02 | Memory resource row | Valid Utilization memory | `memory.realUsage` and verified absolute fields | Presentation only | Source models | Unknown unit/value omitted rather than inferred | Memory usage remains readable and compact | Percentage-only fixture + full-value fixture + missing-value fixture |
| T5-RESOURCE-03 | Storage resource rows | Valid Storage response | `Storage.volumes`, volume `size/status` | One row pattern per real volume | Storage source object | Missing/invalid fields omitted; no local warning threshold fabricated | Multiple volumes show real used/total/free/status | Multi-volume test; abnormal model status test; no hard-coded >80 abnormal contract |
| T5-ABN-01 | Abnormal summary classification | Notification/storage data is valid | Notification explicit WARN/ERROR; explicit abnormal storage states | Qualifying entries appear ordered by severity | Ordinary info notifications, normal background work | Unknown/unavailable data is not promoted to abnormal | Region absent when healthy; present only for real abnormality | Healthy fixtures → absent; INFO only → absent; WARN/ERROR/storage danger → present |
| T5-NOTIFY-01 | Notification relationship | Shell active with or without Overview | `G-NOTIFY-01`, existing shell notification builder | Overview may consume notification data for abnormal summary only | Global notification navigation/lifetime | Overview disposal/failure cannot disable notification entry | App Bar notification works from any primary tab | Mount shell with Overview absent/failing; open notification from other tabs |
| T5-SHORT-01 | Shortcut derivation | InitData Desktop settings loaded | `shortcutItems`, `validAppviewOrder`, existing supported route mapping | Produce ordered eligible shortcut view, max 4 | DSM shortcut settings | Unsupported/unavailable entries skipped; no automatic frequency sort | At most 4 real supported shortcuts in DSM source order | Mixed supported/unsupported fixture; assert order + max 4 |
| T5-SHORT-02 | Shortcut navigation | Eligible shortcut selected | Existing feature destination + `LegacyPageHost` | Opens selected legacy feature in current app context | Other tab stacks/session | Missing destination produces recoverable unavailable state, not a guessed route | Shortcut opens existing capability with correct Back/theme boundary | Relationship test with known legacy destination and Back return |
| T5-SHORT-03 | Fixed shortcut-region semantics | Modern Overview active | Approved Project Spec | Shortcut region remains structural even with zero eligible items | Legacy `SettingProvider.showShortcut` value | Zero eligible items renders restrained empty/config state; region is not silently removed | Modern Overview structure is stable | showShortcut false + eligible data; zero eligible data; assert fixed region semantics |
| T5-WCFG-01 | Read DSM widget configuration | InitData loaded | `synoSDSWidgetInstance.moduleList` | Classify IDs as core-equivalent, Task5-owned, deferred, opaque | Original complete module list | Unknown ID is never discarded during read/classification | Edit mode shows only Task5-owned controls while retaining other config | Fixture containing all classes + unknown ID |
| T5-WCFG-02 | Save Task5 extension selection/order | User commits edit mode | `UserSettings.apply(List<String>)` | Only Task5-owned subsequence changes according to approved merge rule | Core-equivalent, deferred, unknown IDs and their relative order | Save failure leaves local authoritative persisted state unchanged and exposes operation error | DSM receives a full merged module list with no unrelated loss | Reorder/remove/add owned IDs around opaque IDs; assert exact merged output; inject save failure |
| T5-EXT-01 | Current-connection extension read | Module selected and capability available | `CurrentConnection.get()` | Extension last-valid summary updates | Other Overview sources | Empty success = no connections; refresh error = stale prior value | Compact current-connection summary; no Modern kick action | Empty/nonempty/stale tests; assert no mutation path exposed |
| T5-EXT-02 | Task-scheduler extension read | Module selected and capability available | `TaskScheduler.list()` | Extension last-valid summary updates | Other Overview sources | Empty success = no tasks; refresh error = stale prior value | Compact scheduled-task summary; no Modern run/edit/delete action | Empty/nonempty/stale tests; assert no mutation path exposed |
| T5-EXT-03 | Deferred/unknown module preservation | Existing module list contains log or unknown IDs | Original module list + `T5-WCFG-02` | No presentation migration required in Task 5 | Exact opaque IDs | Any save that removes/rewrites them is contract failure | User's DSM widget config survives Task 5 edits | Round-trip known deferred + random opaque IDs through edit/save |
| T5-SHELL-01 | Overview root cutover | Task 5 prior batches pass | `DsmNewUiShell`, `NewUiAppShell`, Task 3/4 shell/session | 概览 root becomes Modern Overview | Other four destinations, global notification, account/logout behavior | Cutover failure must be revertible without deleting legacy Dashboard | Cold start/context switch lands directly on Modern Overview | Shell relationship tests + real-device cold start/switch |
| T5-FALLBACK-01 | Legacy Dashboard retention | Modern Overview becomes formal entry | Existing `lib/pages/dashboard/**` | No deletion required | Legacy functionality/source files | Task 5 must not delete fallback solely because Modern Overview exists | Legacy Dashboard remains available for regression/reference until separate removal decision | Diff boundary test/review: no legacy Dashboard deletion |
| T5-APK-01 | User-installable Task 5 Gate | CI build requested | `APK-IDENTITY-01` | New APK contains Task 5 | Existing app data/login identity | Package/signing mismatch blocks real-device Gate | APK overlays installed Task 4 version | CI package/cert assertion + user overlay install |

## 3. Owned vs Non-Owned DSM Widget IDs

Task 5 owns only:

```text
SYNO.SDS.SystemInfoApp.ConnectionLogWidget
SYNO.SDS.TaskScheduler.TaskSchedulerWidget
```

Core-equivalent and preserved:

```text
SYNO.SDS.SystemInfoApp.SystemHealthWidget
SYNO.SDS.ResourceMonitor.Widget
SYNO.SDS.SystemInfoApp.StorageUsageWidget
```

Known deferred and preserved:

```text
SYNO.SDS.SystemInfoApp.FileChangeLogWidget
SYNO.SDS.SystemInfoApp.RecentLogWidget
```

Every other ID is opaque and preserved.

## 4. Save Merge Invariant

Let the original module list be `O` and the edited Task 5-owned ordered list be `E`.

The merge must satisfy all of these:

1. Every non-owned element in `O` appears exactly once in the result and in the same relative order.
2. Existing owned slots are filled from `E` in edited order.
3. If `E` has more elements than original owned slots, extras are inserted immediately after the last original owned slot; if no owned slot existed, extras append.
4. If `E` has fewer elements, unused owned slots disappear.
5. No core-equivalent, deferred or opaque ID is created, deleted or reordered by Task 5.
6. The complete merged list is passed to `UserSettings.apply`; the UI must never pass only the Task 5-visible subset.

This invariant is part of the Task 5 contract because `UserSettings.apply` replaces the full DSM widget module list.

## 5. Contract Gaps

Preflight found no unresolved **blocking** Task 5 Contract Gap.

Resolved during preflight:

- batch failure ambiguity → core sources use independent requests;
- providers lacking state metadata → thin Task 5 state layer;
- legacy mixed polling intervals/recursive loops → one Task 5 lifecycle using the persisted refresh setting;
- 1/5/10 wording mismatch → real model 1/5/15 only;
- ambiguous system temperature → do not label as CPU temperature;
- local capacity threshold ambiguity → no invented threshold;
- fixed Modern shortcut structure vs legacy hide flag → Modern structure wins; legacy preference remains untouched;
- no proven shortcut write authority → consume DSM Desktop shortcut configuration without adding a new write path;
- full-list widget save hazard → preservation merge invariant;
- runtime 119 after shell entry → one-shot Overview invalidation signal forwarded to the existing same-account reauthentication flow;
- extension mutation scope → Task 5 summaries are read-only; legacy mutation capabilities remain outside the Modern Overview.

## 6. Preflight Verification

This Preflight is documentation/contract work only.

Required proof before moving to Batch Plan:

- no production/test file changed;
- Feature Design and this Matrix agree on all Task 5-owned IDs and authorities;
- no unresolved placeholder or open-ended marker remains;
- Master Plan points to these Task 5 preflight authorities;
- user reviewed and approved the committed documents.

Under `CI-DOCS-01`, no Android CI run is required for this docs-only Preflight commit.
