# Task 5 Batch 5 — Extension Widget Configuration / Preservation Acceptance

> Date: 2026-10-09  
> Repository: `qyxx2/dsm_helper`  
> Branch: `feature/t5-dashboard`  
> Starting HEAD (Batch 4 acceptance): `a50f563896b5c42a25cf93c22707e23b145a91c3`  
> **Final verified Batch 5 implementation HEAD:** `9a4c071edb21b03f0e1f73f7a702fae95f58c285`  
> Gate: **PASS — automated Batch 5 scope only**.

## Contract authorities and implementation boundaries

Authoritative sources: [Task 5 Batch Execution Plan](../plans/2026-10-09-task-5-dashboard-batch-plan.md), [Task 5 Feature Design](../specs/2026-10-09-task-5-dashboard-feature-design.md), [Task 5 Contract Matrix](../contracts/2026-10-09-task-5-dashboard-contract-matrix.md), frozen Modern UI Visual Design, and actual legacy `UserSettings.apply(List<String>)` / `SynoSdsWidgetInstance.moduleList` behavior.

- **T5-WCFG-01:** Edit Overview displays only the two Task 5-owned extension controls, `SYNO.SDS.SystemInfoApp.ConnectionLogWidget` (当前连接) and `SYNO.SDS.TaskScheduler.TaskSchedulerWidget` (计划任务). Core-equivalent, deferred and opaque IDs are not editable there; the fixed Overview structure, notifications and shortcuts remain unchanged. The action is disabled when no authoritative DSM module list is loaded.
- **T5-WCFG-02:** `mergeTask5OverviewModuleIds` edits only the owned ordered subsequence, reuses existing owned slots, inserts excess owned IDs after the last owned slot (or appends when none), and never moves or discards non-owned entries. Invalid edited IDs and repeated owned selections do not become extra saved modules. The controller forbids editing unowned IDs, prevents overlapping saves, reports failure, and returns a merged list only upon true success. The Overview save callback passes the **complete** merged list to existing `UserSettings.apply(List<String>)`. Only after confirmed success does Overview replace the captured `SynoSdsWidgetInstance.moduleList` and call `InitDataProvider.notify()`; the provider/instance identity guard avoids publishing a result into a switched local context. False/null/throw leaves local authoritative module state unchanged.
- **T5-EXT-03:** Fixtures include both known deferred module IDs and unknown opaque IDs among the editable slots, verifying round-trip preservation of their exact order and identity. There is no new DSM persistence API, widget-data polling, connection/task mutation, legacy-dashboard modification or shell cutover.

## Ordered RED → GREEN evidence

1. **Steps 1–2 — pure merge.** RED test commit `31cf640157ccde7fe2a75981214f403e7328740c`; CI [#185](https://github.com/qyxx2/dsm_helper/actions/runs/37893993698), Run ID `37893993698`, Job ID `113701033776`: **180 passed / 1 test file failed to load** because the production merge file/functions did not exist. Implemented at `1a93e7285cb2f5e166a1d6d3c1dbbc9802ed197d`; CI [#186](https://github.com/qyxx2/dsm_helper/actions/runs/37894255198), Run ID `37894255198`: **187 passed**, analyzer clean and signed APK built.
2. **Steps 3–4 — controlled edit/save.** RED controller tests added at `6662e3e07d676a62627b086483aa49389d7fe8c0`, with fixture correction `ee376be0afa1a41a53546058ca99e6717812bb40`. Authoritative corrected RED CI [#188](https://github.com/qyxx2/dsm_helper/actions/runs/37896088489): **187 existing tests passed**, controller test load failed due specifically to the absent `overview_widget_config_controller.dart`. Implementation `f81937696e9e253298c33a88e633c22ccc4878d5` passed **193 tests** in CI #189 but failed analyzer because the test file had an unused import. Removing that import alone at `6b0a9417085bc23f3cd31c57aa2738db93dcf560` produced complete success CI [#190](https://github.com/qyxx2/dsm_helper/actions/runs/37896492054), Run ID `37896492054`: **193 passed**, analyzer clean, signed APK built.
3. **Steps 5–6 — edit page and Overview production wiring.** RED edit-page tests `375c473a56ca0148fb32e7639991f746927cadbb`; Overview integration tests `04f8736bbc7cea2f3693e4c9f6c27829bb6e6762`. CI [#192](https://github.com/qyxx2/dsm_helper/actions/runs/37897511286), Run ID `37897511286`: **193 existing tests passed / 5 failures**, caused by the absent edit page and Overview action. Implemented edit page `5ed7f52c51c353280227f947beb9a6cba0c57192` and Overview save wiring `013e1dee2f99b577d6502fcfc8f3f00e5dec5396`. CI #194 confirmed **202 passed / 1 failed**: the sole remaining failure was a test expecting a selected owned ID to move after an opaque item instead of filling its original owned slot. The frozen contract and production result were correct. Test expectation and route result type corrected at `9a4c071edb21b03f0e1f73f7a702fae95f58c285`.
4. **Step 7 — final GREEN / complete regression / analyzer / build.** CI [#195](https://github.com/qyxx2/dsm_helper/actions/runs/37897987201), Run ID **`37897987201`**, Job ID **`113713653454`**, verified checkout **`9a4c071edb21b03f0e1f73f7a702fae95f58c285`**, **completed / success**: **203 tests passed, 0 failed**, analyzer clean, Android beta debug APK built, package and signing certificate identity verified, artifact uploaded.

The workflow executed the **whole `flutter test` suite** and analyzer on its configured new-UI targets, including the named Batch 5 files. The plan's separately grouped focused commands were **not independently executed** in a local Flutter SDK; do not treat them as independently witnessed results.

## Final CI and APK identity

| Evidence | Verified result |
| --- | --- |
| Workflow | Modern UI Android CI |
| Final run / job | **#195 / `37897987201` / `113713653454`** |
| Immutable source SHA | `9a4c071edb21b03f0e1f73f7a702fae95f58c285` |
| Run/job conclusion | **completed / success** |
| Whole-suite Flutter tests | **203 passed, 0 failed** |
| New UI analyzer | **No issues found** |
| Flutter beta debug APK | **Build successful** |
| APK output | `build/app/outputs/flutter-apk/app-beta-debug.apk` |
| Package ID | `top.apaipai.dsm_helper` |
| Signing certificate SHA-256 | `0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2` |
| Uploaded artifact | `dsm-helper-modern-ui-android-debug` |
| Artifact ID | **`11600942881`** |
| Artifact size | `190021881` bytes |
| Uploaded artifact ZIP SHA-256 | `6eafe62ad6560a3db5f81d11ed7af3e6689e64c4708328903a5c7135542e3194` |

[Downloadable GitHub Actions APK artifact #11600942881](https://github.com/qyxx2/dsm_helper/actions/runs/37897987201/artifacts/11600942881).

## Diff boundary and Exit Gate

GitHub Compare from starting HEAD `a50f563896b5c42a25cf93c22707e23b145a91c3` to final verified implementation `9a4c071edb21b03f0e1f73f7a702fae95f58c285` confirms **exactly these eight Batch-5-authorized production/test paths**:

1. `lib/new_ui/dashboard/overview_widget_config.dart` — added.
2. `lib/new_ui/dashboard/overview_widget_config_controller.dart` — added.
3. `lib/new_ui/dashboard/edit_overview_page.dart` — added.
4. `lib/new_ui/dashboard/overview_page.dart` — modified.
5. `test/new_ui/dashboard/overview_widget_config_test.dart` — added.
6. `test/new_ui/dashboard/overview_widget_config_controller_test.dart` — added.
7. `test/new_ui/dashboard/edit_overview_page_test.dart` — added.
8. `test/new_ui/dashboard/overview_page_test.dart` — modified.

**Batch 5 Exit Gate: PASS (automated).** Pure merge, controller, editor and Overview relationship tests prove the owned-only edit boundary, core/deferred/opaque preservation, true-success DSM apply handoff, save-failure retention and absence of Task 6 extensions. Global notifications remain independent.

**NOT TESTED / NOT CLAIMED:** real DSM `UserSettings.apply` round trip against hardware, physical-device editor interaction, APK overlay installation and user-data retention, active production shell cutover, live connection/task extension reads or summaries, or Task 5 overall completion. Batch 5 does not require a standalone real-device Gate; the Task 5 Batch Plan assigns integrated production shell, full-device and overwrite verification to **Batch 7**.

Per `CI-DOCS-01`, this acceptance record is a docs-only commit; its subsequent branch HEAD does not replace the immutable `9a4c071...` implementation SHA verified by CI #195.

**Stop after Task 5 Batch 5.** Do not automatically start Batch 6, merge `feature/t5-dashboard` into `modern-ui`, or modify another Task.
