# Task 5 Batch 7 — Two-Item UI Corrective Follow-up

**Status:** Approved scope and execution plan only; production/test implementation NOT STARTED.  
**Branch:** `feature/t5-dashboard`  
**Immutable pre-correction baseline:** `7f746e52844a20bea67eef7864266576d18fb1eb`  
**Baseline CI:** Modern UI Android CI [#223](https://github.com/qyxx2/dsm_helper/actions/runs/37914125683), run `37914125683`, 227 Flutter tests passed, targeted analyze clean, beta debug APK built/signed/uploaded.  
**Approval:** The user completed the four Batch 7 real-device review stages (11-A/B/C/D) for their HTTP LAN DSM deployment. Exactly two UI refinements were approved afterward; no other enhancements were requested.

## 1. Authority and scope

This is a **narrow, Batch-7-local post-device-review correction**, NOT Batch 8, Task 6, a shortcut-editor implementation, a redesign of Task 5, or premature final Task 5 acceptance. The existing Task 5 Feature Design, Contract Matrix, Batch Plan, Task 2 visual rules, global contracts and `APK-IDENTITY-01` remain authoritative except for the explicit presentation/file-boundary extensions below.

The two approved changes are:
- **B7-UI-01 — refresh indicator layout stability.** Manual and automatic refresh currently insert/remove a `数据刷新中` row immediately below the device name, shifting the cards. Move its visual indicator into a **fixed-width slot in the Overview AppBar next to the title**. Keep title, connection-state label, edit and notification buttons stable; keep content scroll positions stable through refresh start/finish. Prefer a compact progress indicator and accessible label `数据刷新中`, not a newly inserted body row or full-width title replacement. During idle the indicator is visually absent, but its slot still occupies the same width. Keep the old last-valid/stale/error semantics.
- **B7-UI-02 — at most four disk temperatures in each volume card's upper-right unused space.** No separate bottom temperature row or reserved empty disk cells. The left header retains name/status, the right upper corner uses compact labels (up to a two-column/two-row arrangement); capacity percentage, progress and used/free information keep their existing hierarchy and full-width rows. Ordinary phone font sizes should not introduce a new card-height row for disk temperatures; large text/small width must avoid overlap/overflow, permitting natural responsive height where necessary.

### Exact whitelist

**Production edits (only):**
1. `lib/new_ui/dashboard/overview_page.dart`
2. `lib/new_ui/dashboard/widgets/core_resource_section.dart`

**Test edits (only):**
3. `test/new_ui/dashboard/overview_page_test.dart`
4. `test/new_ui/dashboard/core_resource_section_test.dart`

**Documentation:**
- This one plan is permitted before implementation.
- After final successful code CI and the user's focused post-fix device confirmation only, create `docs/modern-ui/acceptance/2026-10-09-task-5-dashboard-acceptance.md` and update `docs/modern-ui/2026-10-06-dsm-helper-modern-ui-master-plan.md` to close Task 5. Do not mark completion early.

No other code, tests, asset, model, provider, router, session, API, Android build/config, workflow, legacy Dashboard, or Task 6 paths may be changed. **If a legitimate dependency requires another file, STOP and report the exact need; do not silently enlarge this whitelist.** No shortcut editor, new shortcut persistence, extra status texts, or unrelated visual polish.

## 2. Frozen data and rendering rules

### B7-UI-01: one existing refresh authority

Use `OverviewController` already owned by `OverviewPage`; do not introduce another listener owner, state machine, timer, polling endpoint or refresh call. Its existing core-source `OverviewSourcePhase.refreshing` determination continues to drive indicator visibility. The AppBar may subscribe narrowly with `AnimatedBuilder`; both the visible and invisible indicator use the same fixed layout footprint. Connection/offline label and the two AppBar actions must stay usable. Do not change initial loading, source-local stale/error feedback, or last-valid preservation. Existing test assertions that search for the old body `数据刷新中` text must be updated to verify the AppBar indicator's visibility/semantics and that its body row is absent.

### B7-UI-02: existing Storage load only

Existing `Storage.loadInfo()` returns all required data **in one source response**:
- `Storage.volumes[*].poolPath` identifies a volume's storage pool;
- `Storage.storagePools[*].id/poolPath` and `StoragePools.disks` identify the pool's disk IDs;
- `Storage.disks[*].id`, `.temp` and `.isSsd` supply actual temperature and a trustworthy disk type;
- `Disks.usedBy` can serve as a same-pool identity cross-check/fallback only where it is unambiguous.

Match each volume to its own pool by exact nonempty pool identity, then disk IDs to corresponding disk entries. If no trustworthy same-pool relation is available, omit temperature labels rather than showing temperatures from another volume/pool. Do not infer SSD/HDD from SATA/NVMe `diskType` or model-name text: `isSsd == true` means SSD, `false` means HDD, `null` means unknown and is omitted. Omit null, nonfinite or nonpositive temperatures; format verified numeric Celsius naturally (e.g. `40℃`, not synthetic `0℃`). Do not use a locally invented alarming temperature threshold or mutate DSM values.

After valid, related entries are collected in stable authoritative source order, show **at most four per volume**, with compact labels `HDD 40℃` / `SSD 38℃` when exactly one visible device of that type exists, otherwise `HDD 1 40℃`, `HDD 2 42℃`, `SSD 1 38℃`, etc. Numbering distinguishes only visible same-type devices, not physical bay IDs. For one disk, show only its label; other upper-right space stays empty. Missing data results in the original layout. If two volumes share one pool, each may show the same legitimately associated pool-disk temperatures; never copy values from a different pool.

Keep all matching/formatting code private to `core_resource_section.dart`. Feed it through the existing `CoreResourceSection(storage: ...)` from the unchanged Overview controller and source. No new models, `Storage.loadInfo()` calls, per-disk requests or cache.

### Relationship invariants

Preserve `T5-REFRESH-01/02`, `T5-STATE-01/02`, `T5-RESOURCE-03`, `T5-CTX-01`, `T5-SHELL-01`, `T5-NOTIFY-01`, `T5-WCFG-02` and inherited global contract gates. No changes to `T5-SHORT-01/02/03` or shortcut editing semantics.

## 3. Ordered TDD execution — no scope expansion

**CFU-0 — before code.** Re-read branch HEAD, CI, this plan, B7 active plan/Feature Design/Contract Matrix, existing Overview and Storage model implementations, and both allowed tests. Confirm no concurrent branch movement and exactly four non-document code paths on the whitelist. Preserve baseline `7f746e52844a20bea67eef7864266576d18fb1eb`.

**CFU-1 — B7-UI-01 RED first.** Modify only `overview_page_test.dart` to demonstrate a pending refresh while valid source data remains shown: AppBar has a fixed-width indicator slot, indicator conveys refresh status only while refreshing, no extra `数据刷新中` list child exists, body card positions are the same before/during/after refresh, and AppBar connection/edit/notification positions and callbacks remain intact. Cover an automatic timer tick plus manual refresh and failure→stale→success; retain initial loading behavior. Run the focused Flutter test via local Flutter only if actually available, otherwise the existing GitHub Actions RED→GREEN workflow, preserving the real failure evidence.

**CFU-2 — B7-UI-01 GREEN.** Make only `overview_page.dart` satisfy those tests by moving the indicator to the AppBar's reserved slot. Do not modify Controller or the generic shell. Verify focused tests and UI behavior.

**CFU-3 — B7-UI-02 RED first.** Modify only `core_resource_section_test.dart`. Fixtures must cover: one HDD (no dummy slot), mixed 2 HDD + 2 SSD in the correct volume and right-upper layout, 5+ disks capped at 4, two pools/two volumes without cross-pool leakage, irrelevant/ambiguous pool identities, `null/invalid` temp and unknown `isSsd`, original volume capacity/status unaffected, and narrow portrait + large-font/dark readability without Flutter overflow. Verify the test fails for missing behavior, not for an invalid fixture.

**CFU-4 — B7-UI-02 GREEN.** Modify only `core_resource_section.dart`. Use the above existing Storage fields and safe read-only private mapping; render in upper-right header space. Do not add a second row below capacity or reserve placeholders for missing disks. Do not increase application network activity or loosen unknown-value rules. Verify focused tests.

**CFU-5 — combined regression and diff Gate.**
- `flutter test test/new_ui/dashboard/overview_page_test.dart`
- `flutter test test/new_ui/dashboard/core_resource_section_test.dart`
- `flutter test test/new_ui/dashboard/overview_refresh_relationship_test.dart test/new_ui/dashboard/overview_context_switch_relationship_test.dart test/new_ui/dashboard/overview_shell_relationship_test.dart`
- `flutter test`
- `flutter analyze lib/new_ui test/new_ui`

Where local Flutter/Android tooling is unavailable, use the existing remote CI and record the **real run IDs/results**, never claim unavailable local tests. Verify B1–B7 relationship suites and existing B7 navigation/reauth behavior remain GREEN. Compare every implementation commit against the baseline and confirm only the four whitelisted code/test files; recheck `modern-ui` for unrelated changes. No speculative extra changes.

**CFU-6 — final CI / Android identity Gate.** Obtain one completed-success workflow for the final implementation HEAD: all Flutter tests, clean targeted analyze, `flutter build apk --debug --flavor beta`, package `top.apaipai.dsm_helper`, fixed certificate SHA-256 `0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2`, uploaded artifact. Do not reuse #223 as proof for newly modified code; do not rerun identical commits unnecessarily.

**CFU-7 — focused real-device Gate.** Provide the new CI APK to the user to overlay-install without uninstalling and ask only for: (1) manual and automatic refresh no longer shift the NAS name/resource cards, with stable notification/edit AppBar buttons; (2) each storage card's upper-right HDD/SSD temperature labels correspond to the user's real pool data, including single-disk and multiple-disk cases where available; (3) storage percentage/labels and basic navigation stay correct. Record that other 11-A/B/C/D device checks were passed on the #223 build, **not automatically retested on the new build**. The user's explicitly untested HTTPS, second account, OTP and forced-119 cases remain NOT TESTED, not silently accepted.

**CFU-8 — documents only after user's positive focused Gate.** Write Task 5 Batch 7/overall acceptance with separate original #223 evidence and final corrected HEAD/CI/artifact, test counts, two change IDs, exact user-observed outcomes, real untested exceptions and final whitelist diff. Update Master Plan Task 5 completion only then, in a docs-only commit under `CI-DOCS-01`. Reconfirm remote commit. **Do not automatically merge into `modern-ui`, implement a shortcut editor or begin Task 6.**

## 4. Completion/stop conditions

PASS requires both visual corrections, complete automated and signing gates, verified modified-path whitelist, focused real-device confirmation and accurate final acceptance. A passing old APK or missing user observations cannot substitute for the final Gate.

STOP if non-whitelisted files are necessary, the source cannot prove SSD/HDD type or correct pool ownership, refresh state requires changing Controller/public contracts, a new route/API becomes necessary, or final CI/user validation fails. Record that blocker rather than inventing values or expanding implementation scope.
