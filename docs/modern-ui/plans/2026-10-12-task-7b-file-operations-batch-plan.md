# Task 7B — File Station File Operations Batch Execution Plan

> **For agentic workers:** use Superpowers RED→GREEN→REFACTOR and implement **only the Batch explicitly requested**. This is a planning document, not authorization to run B1 or to mutate a NAS.  
> **Status:** PLAN ONLY — B1–B6 all NOT STARTED (2026-10-12).  
> **Integration baseline:** `modern-ui@dc5a96f2a3006db75a0e7ebe9aa4a479b144f057` (Task 7A B1–B5 merged, PR #9); planning branch `feature/t7b-file-operations`.  
> **Goal:** Add real search and file operations to Task 7A's separately testable Modern File Station, keep existing legacy File Station as the default complete-feature entry, and hand transfer/preview/background-task presentation to Task 7C.
>
> **Authorities:** [Task 7B Feature Design](../specs/2026-10-12-task-7b-file-operations-feature-design.md); [Task 7B Contract Matrix](../contracts/2026-10-12-task-7b-file-operations-contract-matrix.md); Master Plan Task 7A/7B/7C, Project Spec §12, Visual Design Spec, Global Contract Matrix, Task 7A Spec/Contracts, and `acceptance/2026-10-11-task-7a-batch-5-acceptance.md`.

## 0. Preflight: actual source and authority audit

This plan was prepared after reading the **actual** integration HEAD, Task 7A B5 acceptance, existing `lib/new_ui/files/**`, legacy `lib/models/Syno/FileStation/{FileStationList,Sharing,BackgroundTask}.dart`, `lib/pages/file/{file,search,select_folder}.dart`, existing dialogs, `lib/utils/{api,utils}.dart`, `lib/apis/dsm_api/dsm_api.dart`, Shell and CI workflow.

**Real starting point**:
- `FileBrowseController` already has `contextId`, paging, request generations, `selectedPaths`, `selectLoaded`, `clearSelection`, stable selected identity and stale-snapshot handling. `FileBrowsePage` already supports directory routes, list/grid, sort, notification action and single-folder selection bar. Extend in place; do not rebuild them.
- The normal Files tab still opens the legacy page using `NewUiPrimaryPage` → `LegacyPageHost(FilePage)`; secondary `试用新版文件浏览（测试）` opens the optional Modern browse. **Retain both in their current priority.**
- `FileItem.rename`, `createFolder`, `deleteFiles`, Favorite methods and `Sharing.create` exist. Delete returns a background task ID rather than completion.
- **Legacy search is not a complete working UI contract:** `Search` returns input, but the toolbar's result callback is commented out. `Api.searchTask` starts a DSM Search job and `searchResult` currently hard-codes `offset=0, limit=1000`; `FilesState` polls every 2 seconds. Do not copy the commented-out UI as a completed feature.
- **Two transport surfaces are present:** `Api.dsm.entry` uses `DsmApi.sid/baseUrl` and typed `DsmException`; `Utils.post` uses mutable `Utils.sid/baseUrl/cookie`, constructs its own Dio and maps Dio failures to generic `success:false`. `Api.searchTask/searchResult/copyMoveTask` use the latter. **B1 must record which live active-context authority is correct and forbid cross-account dispatch** before later mutating Batches. Reuse existing DSM request semantics, not a new parallel login or HTTP client.
- `Api.copyMoveTask` sends `SYNO.FileStation.CopyMove/start` v3 with `overwrite="true"`, `remove_src` depending on move/copy. This is **not safe to assume collision-free**. B5 must not enable writes without an explicit user-authorized conflict policy and expendable DSM test.
- `Sharing.create` v3 supports ordinary links and a separate file-request mode; only the ordinary-link flow belongs to 7B. Legacy `DeleteFileDialog` starts Delete v2 task with confirmation.
- `Task 7A B5` was user-scoped accepted; scroll/frame-rate comparison after #337 remains unmeasured, and real DSM File Station mutations are **not tested** merely because browse passed.
- At initial review, merge CI #340 was in progress; it subsequently **completed successfully** on `modern-ui@dc5a96f2a3006db75a0e7ebe9aa4a479b144f057`. Before B1 recheck current integration HEAD and latest CI. Approved Task 7A B5 source SHA `255a01b600352bc8eecb0d3ca76fbf353707cfa3` also has separate passing #337 evidence; do not transfer one SHA's result to another.

### Invariants common to every Batch

1. **Only execute one expressly authorized Batch; stop at its Gate.** Never infer authorization for next Batch, PR, integration merge, default Files cutover or Task 7C.
2. **Before each Batch** actually fetch: branch HEAD and recent commits; current CI; this plan, feature design, contract matrix, global/visual authorities and immediately preceding acceptance; involved actual code/tests. If another actor advanced the branch, reconcile before editing.
3. No new global DSM SDK, token/SID cache, permissions database, provider refactor or full `FilesState` port. Prefer `lib/new_ui/files/**`, `test/new_ui/files/**`; allow **only narrowly justified** compatibility changes in `lib/utils/api.dart` or File Station models if exact compatibility tests prove required. Changes to `lib/new_ui/app/**` or `lib/new_ui/shell/**` are limited to B6 validated integration. No changes to Task 7C transfer/preview, `lib/database/**`, CI workflow, `android/**` or unrelated legacy pages by default.
4. Preserve `contextId + exact nonempty FileItem.path` identity, including `scheme://`; no synthetic `real_path`, index/name/object-based identity. On context change/invalidation discard late read/UI results and never refresh account B from an account A response.
5. Incomplete/partial listing is **not** complete; select-loaded selects only loaded paths, later pages are not automatically included. Handle nullable ACL conservatively and surface real DSM permission failure. Root shares remain navigation-only in Modern UI.
6. **No fake mutations:** before dispatch freeze selection and destination; validate action scope; confirm destructive actions; disable repeat submit; categorize `accepted task ID` vs `remote completed` vs error. Never silently retry an ambiguous write timeout. Keep stale rows when completion is unconfirmed.
7. Existing App Bar/global notification budget and light/dark, Back, insets, no-checkbox-gutter, zero-duration child-folder route and scroll-only paging behavior remain intact. No new heavyweight animation or eager load.
8. `APK-IDENTITY-01`: beta Debug `top.apaipai.dsm_helper`, original fixed signing certificate, overlay install safe. Documentation-only commits follow `CI-DOCS-01` (`.github/workflows/android-ci.yml` skips `docs/**`, `**/*.md`).
9. RED must fail for the missing **behavior**, not a syntax/fixture typo; GREEN proves the specific contract. CI can be used for RED/GREEN when local Flutter unavailable; report exact run number, SHA, failed assertion, test count, analyzer and artifact. Do not claim locally executed Flutter tests without a Flutter SDK. Do not repeatedly wait on unchanged hung CI. No covert test weakening.
10. Finish each Batch with `docs/modern-ui/acceptance/2026-10-12-task-7b-batch-N-acceptance.md` containing observed vs untested contracts, specific files, RED/GREEN links, exact remote commit/diff, UI/device scope and unresolved gaps; commit, re-fetch remote HEAD/files, **STOP**. Never mark a user-declined device case PASS.

## 1. Dependency and ownership matrix

| Batch | Testable deliverable | Depends on | Contracts primarily closed | Allowed primary files | Device risk |
| --- | --- | --- | --- | --- | --- |
| **B1 — Operation Authority & Safety** | Pure action eligibility/selection snapshot, typed operation/search adapter seams and correct active-context/error classification; **no actual DSM writes/UI actions enabled** | accepted 7A | OPS-01/02/03 foundations, STATE-01 foundation | new `file_operation_* .dart` / `file_search_* .dart` (without spaces), tests; rare model compatibility | Fake-only; no remote mutation |
| **B2 — Search** | Folder-scoped Search start/result incremental paging & bounded polling, Modern search route | B1 | SEARCH-01/02/03, STATE-01 | `lib/new_ui/files/file_search_*.dart`, relevant page/controller, tests | Read-only real DSM search optional |
| **B3 — Favorites / Ordinary Share** | Valid long-press item menu; DSM Favorite membership actions, ordinary share-link creation/display | B1–B2 | FAV-01, SHARE-01, UI-01 (single-item), STATE-01 | `lib/new_ui/files/file_*action*.dart`, contextual UI, tests | **DSM writes** on disposable entries |
| **B4 — Rename / Folder Create / Delete Start** | Guarded rename/create, destructive single/batch delete confirmation and task-start receipt, batch footer | B1–B3 | RENAME-01, CREATE-01, DELETE-01, UI-01 (batch), STATE-01 | operation adapter/coordinator/dialogs/page, tests | **Destructive DSM writes** on test fixtures only |
| **B5 — Copy / Move & Destination** | Folder-only destination picker, explicit copy/move request, collision-risk contract gate, task-start receipt | B1–B4 **plus user approval of overwrite policy** | COPYMOVE-01/02, OPS-01/02, STATE-01 | destination picker, coordinator, validated thin adapter, page/tests | **Blocking overwrite gate**; controlled real DSM |
| **B6 — Relationship/Final Task Gate** | Cross-mode/Back/search/actions/auth/context/regression CI + beta APK + scoped real DSM confirmation, opt-in preview retained | B1–B5 | UI-01, STATE-01, CUTOVER-01 + all exposed actions | integration tests, **minimal** Shell wiring only if unavoidable, acceptance | Final user real-device Gate; **no cutover** |

Batch count **6** is intentional: search job lifecycle is independent of DSM writes; favorites/share are non-destructive service actions; rename/delete needs a dedicated destructive Gate; copy/move has a unique hard-coded overwrite risk; final Shell/device verification must not be smuggled into a mutation step. B5 cannot be called PASS if its overwrite policy remains unresolved. No Batch automatically authorizes another.

### Cross-Batch dependency rules

- Implement a small **dependency-injected** operation/search boundary in B1, to allow all later widget and controller tests without actual DSM writes. Preserve exact API names/versions and request payload behavior under the verified active session.
- B2 may compose the existing Task 7A controller read API, **not** alter its paging semantics. Search job state and Browse state must be separate; only verified navigation back to browse may transition between them.
- B3 introduces the *single-item* context sheet before B4's multiselect footer. B4 must not expose copy/move controls as working until B5 is enabled. B5 only adds eligible actions; it does not implement downloads.
- Each release-facing mutating Batch has a test + safe real DSM gate. With no real DSM connection, automated results can be marked PASS and device gate `PENDING / NOT TESTED`; do not claim complete functional acceptance. Whether this blocks further Batches follows actual dependency on a verified behavior; **B5 overwrite-policy resolution is mandatory**.
- B6 runs all relationship proofs, retains existing legacy primary entry and does **not** merge to integration without an additional explicit request.

## 2. Batch 1 — Operation Authority & Safety

**Purpose:** Prevent future writes from going to a wrong DSM context or being falsely reported as complete. This is an adapter/policy Batch, not an operation-delivery Batch.

**Preferred files:**
- Create `lib/new_ui/files/file_operation_contract.dart` (typed action IDs, immutable target snapshot, eligibility/error/task-start semantics) and `file_operation_data_source.dart` (injectable operation functions; production adapter over verified canonical existing authority).
- Create `test/new_ui/files/file_operation_contract_test.dart`, `file_operation_data_source_test.dart`.
- Optional only if RED requires: narrow additions to `lib/utils/api.dart` or `FileStationList.dart`; preserve every legacy caller's default behavior and exact request values. No change to global auth/provider.
- After GREEN: `docs/modern-ui/acceptance/2026-10-12-task-7b-batch-1-acceptance.md`.

### B1 steps (RED→GREEN)

- [ ] **1.1 Preflight:** Read `Utils.post` and `DsmApi.entry` fully. Trace real active session/context initialization and check `Utils.sid/baseUrl` vs `Api.dsm.sid/baseUrl` across A→B. Record whether legacy `Utils.post` helpers are safe to call directly or whether a thin adapter must reuse `Api.dsm.entry` with identical DSM API/method/version/fields. Do not silently assume the two globals are synchronized. Review exact `DsmException`/Dio error shape and code 119.
- [ ] **1.2 RED tests:** For copied `FileItem` instances with same path, duplicate names/different paths, empty/null path, full vs partially loaded selection, root share, nullable ACL, read-only directory, route disposal and account A→B, assert the exact eligible target set and that no write calls occur. Assert correct copy vs move polarity, delete/favorite/rename/share API identity, real transport error vs DSM error classification using injected fakes. Assertions must fail from **missing contract/adapter behavior**.
- [ ] **1.3 GREEN:** Add immutable context-bound target snapshot and action-eligibility rules; typed adapter separating immediate bool response, server-created link and accepted nonempty task ID; one-shot 119 callback; existing error types preserved. The production adapter must use actual active DSM session, not a new auth/SID cache. For high-risk CopyMove and Delete, B1 exposes a seam only, never a mounted UI action.
- [ ] **1.4 Verify:** `flutter test test/new_ui/files/file_operation_contract_test.dart test/new_ui/files/file_operation_data_source_test.dart -r expanded`; `flutter analyze lib/new_ui/files test/new_ui/files`. Record request payload comparison against legacy for each supported action, including quotes and `_sid` ownership where applicable. If no local Flutter, stage failing test commit and observe distinct GitHub CI RED, then implement GREEN and use precise CI run.
- [ ] **1.5 Scope and Gate:** Confirm no writes were executed, no new remote transport, no Shell/legacy UI changes. Commit small source/test units; write B1 acceptance and remote re-read; STOP.

**B1 Exit:** Testable, session-safe operation contracts and adapters, verified error taxonomy; no UI operations enabled and no user-file mutation.

## 3. Batch 2 — Search Job, Result Paging and Search UI

**Purpose:** Ship genuinely working read-only search instead of copying the current commented-out legacy toolbar callback or limiting results silently to the legacy first 1000.

**Preferred files:** `lib/new_ui/files/file_search_data_source.dart`, `file_search_controller.dart`, `file_search_page.dart`; narrowly touch `file_browse_page.dart` to expose search action/navigation; tests `file_search_data_source_test.dart`, `file_search_controller_test.dart`, `file_search_page_test.dart`. Only a backward-compatible search-helper parameter addition if necessary and proven.

### B2 steps

- [ ] **2.1 RED protocol tests:** Verify `SYNO.FileStation.Search/start` v2 gets `folder_path` as JSON array, exact path/pattern/recursive/content flags; `list` v2 gets actual `taskid/offset/limit/filetype/additional`. Verify current helper's 0/1000 limitation is not copied. Test malformed response, `finished=false` vs `finished=true`, 0/101/1000+ records, duplicate/overlap, non-advancing offset, delayed first result and rate-limited polls.
- [ ] **2.2 GREEN datasource:** Reuse existing API family through B1 active-context adapter; only make minimal compatible additions where required to obtain later pages. Parse finished/partial/invalid separately; if the real DSM Search API lacks incremental list support, **do not claim complete search**—surface incomplete and record the blocker. Never fetch all result pages in an unbounded eager loop.
- [ ] **2.3 RED controller tests:** Rapid query replacement, route Back/IME dismiss, account A→B, offline/119, malformed/empty, one in-flight poll at a time, bounded retry/poll schedule, stale result excluded, disposed widget makes no further local polls. Verify no optimistic file selection or accidental directory listing replacement.
- [ ] **2.4 GREEN controller:** Independent query generation, result snapshot, task id, paging/progress, completed vs uncompleted search, cancellable *local* poll timer; use callback/invalidation context. Do not invent remote `Search/stop` or remote job cancellation.
- [ ] **2.5 RED→GREEN UI:** Folder-only App Bar search (single direct action; notifications remain global), compact Material 3 form/presentation, optional recursive/content toggles from legacy, query validation, proper keyboard/Back, results with full path identity, spinner/error/retry/empty/completion states. Results do **not** implement file previews; selection and mutation only after B3/B4 contracts are usable.
- [ ] **2.6 Verify/Gate:** `flutter test test/new_ui/files/file_search_data_source_test.dart test/new_ui/files/file_search_controller_test.dart test/new_ui/files/file_search_page_test.dart -r expanded`; `flutter test test/new_ui/files -r expanded`; analyzer; full code-changing GitHub CI and beta APK. Verify unchanged browse sort/paging/notification/Back in relationship tests; acceptance document with DSM search cases tested or `NOT TESTED`; commit/re-read and STOP.

**B2 Exit:** Folder-scoped Search actually starts/reads/results with no silent 1000 cap and no timer leakage. The browse directory/selection remains isolated.

## 4. Batch 3 — Single-Item Menu, Favorites & Ordinary Share Link

**Purpose:** Add a functional contextual surface before bulk mutations. Preserve DSM as the favorite/link authority.

**Preferred files:** `lib/new_ui/files/file_operation_coordinator.dart`, `file_operation_menu.dart`, minimal `file_browse_row.dart` and `file_browse_page.dart` changes; `file_favorite_action.dart`, `file_share_action.dart` if separation improves testability; focused tests. Reuse existing `FileItem.addFavorite/deleteFavorite`, `FileStationList.favoriteList`, `Sharing.create(paths:...,fileRequest:false)` through B1 seam.

### B3 steps

- [ ] **3.1 RED tests:** Normal long press on ordinary file/folder opens a **single-item** sheet; tap/swipe remain as T7A; share-root remains navigation-only. Assert no per-row permanent overflow or dead preview/download; double tap invokes at most one submission. Grid/list semantics equivalent.
- [ ] **3.2 RED Favorite tests:** Verify exact path, one write, duplicate 800/retry, remove favorite (only if server-confirmed membership), account-switch isolation, server membership refreshed after mutation, failure does not set optimistic star. Existing local Application favorites must never be used as File Station authority.
- [ ] **3.3 GREEN:** Minimal favorite adapter/coordinator + contextual Material 3 menu. Need not build a full favorite-management page; provide add/remove entry using server membership that is validated. If paging `favoriteList` cannot cover all memberships, do not treat absence from a partial list as definitive non-favorite; document or narrow the scope.
- [ ] **3.4 RED ordinary-share tests:** `Sharing.create` called with exact item paths and `fileRequest:false`; show returned nonempty actual link, copy it using existing available platform support. Invalid/no link, permission/119/offline, double dispatch or route disposal is handled explicitly. No guessed URL, no file-request mode, no printing link as diagnostic.
- [ ] **3.5 GREEN:** Add create-link dialog/result view with copy/share affordance and busy/error handling; prefer an ordinary single item when multi-item result semantics are unproven. Do not create share-admin/expiration/password screens.
- [ ] **3.6 Verify/Gate:** Targeted new tests + `flutter test test/new_ui/files -r expanded`; analyzer; full CI/APK; visual/context relationship tests. Safe real DSM test on a **disposable** file/folder for favorite/link creation if accessible; otherwise state `NOT TESTED` without claiming live behavior. Write B3 acceptance; remote diff/commit re-check; STOP.

**B3 Exit:** Context menu truly performs favorite/ordinary-link actions where supported, no preview/transfer dead actions, legacy default unchanged.

## 5. Batch 4 — Rename, Create Folder & Confirmed Delete Task Start

**Purpose:** Deliver distinct immediate-ack mutations and intentionally destructive task-start semantics with dedicated confirmation and tests.

**Preferred files:** `file_operation_coordinator.dart`, `file_operation_dialogs.dart`, `file_browse_page.dart`, `file_browse_selection_bar.dart`, and tests `file_operation_dialogs_test.dart`, `file_operation_controller_test.dart`, `file_browse_operations_test.dart`. No background-task UI.

### B4 steps

- [ ] **4.1 RED rename/create tests:** Single item only; exact path frozen before dialog; name nonempty (avoid whitespace-only), canceled dialog zero network, no duplicate submit, 414 conflict vs permission vs 119 vs Dio, success bool refreshes correct *current* directory. For create folder, path is current verified directory; share-root not valid.
- [ ] **4.2 GREEN immediate actions:** Reuse existing `FileItem.rename`, `FileItem.createFolder` under B1 adapter. Busy state and input ownership in one route; only confirmed success triggers directory refresh, no optimistic row inserts/moves. Do not change methods of legacy dialogs globally.
- [ ] **4.3 RED delete tests:** Single and frozen multi-selection exact path array; explicit confirm count + deletion warning, non-reentrant button, empty selection blocked; `FileItem.deleteFiles` v2 task-id success **only** when nonempty; blank ID, network ambiguous or DSM error retain visible rows; cancel/back makes no call. Verify pending-selection Back semantics and no delete of unseen pages.
- [ ] **4.4 GREEN delete:** Contextual Delete and selection-footer Delete invoke real task-start adapter after confirmation. On valid task ID show “删除任务已创建/已提交” not “文件已删除”; optionally emit the existing legacy `RefreshBackgroundTaskEvent` once; preserve browse until actual refreshed server result. Task 7C will own status/cancel.
- [ ] **4.5 RED→GREEN batch UI:** Selection header still offers count/exit/select-loaded, Back cancels selection before popping route. Bottom action menu shows working Delete/More only; do not display operational Copy/Move/Download yet. Normal long press shows item actions; selected-item long press targets the whole selected set.
- [ ] **4.6 Verify/Gate:** `flutter test test/new_ui/files/file_operation_dialogs_test.dart test/new_ui/files/file_operation_controller_test.dart test/new_ui/files/file_browse_operations_test.dart -r expanded`; broader Files tests; analyzer; full remote CI and signed beta APK. **Real DSM device gate:** create expendable nested folder, rename with/without conflict, create folder, delete only test file; distinguish task start from observed later deletion. Record skipped live tests precisely. Acceptance, remote diff audit, STOP.

**B4 Exit:** Validated rename/create, controlled delete task start and contextual batch UI; no implicit remote deletion claim.

## 6. Batch 5 — Copy/Move Destination and Overwrite Safety Gate

**Purpose:** Integrate the existing DSM CopyMove action only under an explicitly reviewed overwrite contract. This is the highest-risk file mutation Batch.

**Preferred files:** `lib/new_ui/files/file_operation_destination_page.dart` (or equivalent folder chooser), operation coordinator/menu/page; `test/new_ui/files/file_operation_destination_test.dart`, `file_copy_move_test.dart`, integration tests as required. Only narrow compatible `Api.copyMoveTask` adaptation after B1 transport proof; no transport rewrite.

### **B5 mandatory preflight / STOP gate**

`lib/utils/api.dart::Api.copyMoveTask` currently sends `overwrite="true"` for **both** copy and move. An existing destination file/folder may be overwritten. **Never present an unchecked/default harmless copy/move button.** Before any user data mutation:
- [ ] Document the exact actual payload and real DSM behavior using expendable source/destination fixtures, including same-name collision, permission denial, same-directory, folder-into-descendant and remote/special path if supported.
- [ ] Obtain explicit user approval of the overwrite/collision confirmation policy. A warning alone is **not** a verified server-side no-overwrite guarantee. Do not quietly change legacy request semantics or claim an atomic collision pre-check. Without approval, B5 remains **BLOCKED** (no CopyMove dispatch or enabled UI) and Task 7B cannot claim full B5 PASS.
- [ ] Confirm available test target is a dedicated disposable DSM path; never test collision/destructive semantics on valuable NAS data.

### B5 RED→GREEN after gate approval

- [ ] **5.1 RED destination tests:** Root/folder read through accepted T7A paging; choose **folders only** by exact DSM returned path, not arbitrary text or `real_path`. Back/cancel no write; empty/partial/permission state obvious; same path/descendant/invalid cross-context destination blocked; special `scheme://` only with verified semantics.
- [ ] **5.2 GREEN picker:** Build Material 3 destination chooser using existing browse reader, narrow state and current Files-tab navigation; preserve source selection snapshot while picker is open, do not leak selection into destination browser. No new global navigation layer.
- [ ] **5.3 RED command tests:** `CopyMove/start` v3, exact encoded source paths, destination path and `remove_src=false` for copy, `true` for move; legacy `overwrite` field identical under approved policy; one dispatch only after explicit consequence acknowledgment; valid `taskid` means accepted *start*. Error/ambiguous timeout/119 retains visible rows and reports uncertainty. A→B stale callback cannot refresh wrong NAS.
- [ ] **5.4 GREEN coordinator/UI:** Add Copy/Move actions to both normal-item and multi-selection menus and footer, only where eligibility/policy permit. No “移动/复制完成” toast based solely on task ID; show queued/start result and background-task compatibility event if necessary. Selection after success should not imply source disappeared before remote completion.
- [ ] **5.5 Verify/Gate:** `flutter test test/new_ui/files/file_operation_destination_test.dart test/new_ui/files/file_copy_move_test.dart -r expanded`; `flutter test test/new_ui/files -r expanded`; analyzer; full CI/APK. **Real DSM device gate using disposable files**, including user-approved overwrite fixture. Record actual collisions/bytes/results, not just launched task IDs. Acceptance and remote SHA/diff; STOP.

**B5 Exit:** Copy/Move request semantics proven and consented, safe destination picker, correct task-start acknowledgement. A BLOCKED overwrite gate cannot be relabeled PASS.

## 7. Batch 6 — Shell Relationship, Full Regression, Real-DSM Gate

**Purpose:** Verify the combined operation UX stays inside the opt-in Modern browser and protects accepted Task 7A and all unconverted legacy/File Station routes.

**Preferred files:** `test/new_ui/files/file_browse_operations_relationship_test.dart`, `test/new_ui/app/task7b_files_operations_relationship_test.dart`, existing pertinent tests; **minimal** `file_browse_page.dart`/Shell change only if failing relationship test proves essential. Final `acceptance/2026-10-12-task-7b-batch-6-acceptance.md` and optionally Task 7B aggregate acceptance with untested scopes. No default root cutover.

### B6 steps

- [ ] **6.1 RED relationship coverage:** Against combined B1–B5 source, assert normal Files main → legacy `LegacyPageHost(FilePage)`, secondary Modern preview remains opt-in, no third tab/navigator, no duplicate App Bar; search direct action + global notifications; sort/list/grid unchanged; long-press single vs selected set; footer only enabled valid 7B actions; system Back priority selection → sheet/dialog/search → directory → tab; IME/insets/theme; rapid A→B switch invalidates pending search/result/operation UI; 119 reauth callback one-shot and offline distinct.
- [ ] **6.2 GREEN minimal integration fixes:** Change only currently proven broken source. Preserve zero-duration child-folder and no visible `加载更多`; do not claim or target frame-rate improvements without measurement. Preserve existing Task 4 login/context and Task 3 external intent reception.
- [ ] **6.3 Full automated Gate:** `flutter test test/new_ui/files -r expanded`; targeted Task 7B relationship tests; **`flutter test` entire suite**, `flutter analyze lib/new_ui test/new_ui`, Android beta Debug APK, identical package/signing, artifact upload. Obtain exact commit/check-run/output; do not infer CI success from earlier run. If tests only run via remote CI, use its actual evidence.
- [ ] **6.4 Real-device Gate on expendable DSM test directory:** Verify search normal/empty/large/polling cancel; context menu and selection list/grid; favorite/link; create/rename; delete-start and eventual change; approved copy/move and collision case; Back/keyboard/theme/notification/overlay install; existing complete legacy route and external share intent still work. Any item not physically tested is `NOT TESTED`, and risk-blocking B5 needs user decision rather than exemption.
- [ ] **6.5 Final diff audit:** Compare final branch with baseline `dc5a96f2a3006db75a0e7ebe9aa4a479b144f057`. Review every changed file (including tests) for Task 7B-only ownership; no upload/download/preview, default Files cutover, Task 8, global auth or unrelated formatting. Verify no stale A-context action after A→B. Check Task 7A tests still green.
- [ ] **6.6 Acceptance:** Record exact HEAD + CI run/test/analyze/APK SHA/signature; real DSM operations accepted vs untested; overwrite-policy decision; residual special-path/search/permission risks and Task 7C handoff. Commit docs-only record, re-fetch remote HEAD and compare, **STOP**. Do not create PR, merge `modern-ui` or begin Task 7C without separate user authorization.

**Task 7B Exit Gate:** Real search and the user-approved/verified file-operation subset function in the **optional** Modern File Station without regressing browse, legacy, context/auth or signed APK. This is **not** approval of replacing the complete legacy Files tab.

## 8. Test / commit / stop protocol for Codex or another agent

Each code Batch uses sequence:
```text
re-read actual remote feature HEAD + latest CI + plan/spec/contracts/previous acceptance
→ inspect exactly involved code and tests
→ add targeted behavior RED test; obtain observable failing assertion (not test compile error)
→ minimal GREEN code; targeted test + analyzer
→ full relevant tests/remote Android CI (avoid redundant CI for docs-only changes)
→ compare expected/current diff and check files not in Batch
→ commit atomic code/tests; re-read real commit SHA and CI
→ create Batch acceptance with PASS / NOT TESTED / BLOCKED distinctions
→ commit documentation only; re-read real HEAD
→ STOP (no next Batch/PR/merge)
```

Suggested reusable commands when Flutter SDK exists:
```sh
flutter test test/new_ui/files -r expanded
flutter test
flutter analyze lib/new_ui test/new_ui
```
Use source-specific targeted commands from each Batch before these broad commands. If the current environment lacks Flutter, **do not invent a local pass**: use explicit remote CI RED/GREEN evidence and read real jobs/logs. Keep any test fixture independent of real DSM, and do not access/write users' real file content for automated tests.

The plan can be revised **only** through a separately reviewed contract decision if observed DSM behavior contradicts a frozen assumption. In particular, `T7B-GAP-01` overwrite is not delegated to unattended implementation discretion. All six Batches are **unstarted** when this document is created.
