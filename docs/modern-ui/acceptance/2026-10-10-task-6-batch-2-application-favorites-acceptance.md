# Task 6 Batch 2 — Applications Favorites Persistence / State Acceptance

> Date: 2026-10-10  
> Repository: `qyxx2/dsm_helper`  
> Branch: `feature/t6-applications-settings`  
> Batch start: `415598ab011de553900af5ab3d4af69cdea727dc`  
> **Final verified implementation HEAD: `5ca4ea22746785fa02febdffc81b928c442feeee`**  
> Gate: **PASS — Task 6 Batch 2 complete. Stop before Batch 3.**

## Authority and scope

Batch 2 was implemented against:

- `docs/modern-ui/specs/2026-10-10-task-6-applications-settings-feature-design.md`;
- `docs/modern-ui/contracts/2026-10-10-task-6-applications-settings-contract-matrix.md`;
- `docs/modern-ui/plans/2026-10-10-task-6-applications-settings-batch-plan.md`.

Accepted contracts are `T6-FAV-01`, `T6-FAV-02`, `T6-FAV-03`, and `T6-FAV-04`.

The resulting authority provides:

- the frozen SpUtil storage key `modern_ui_application_favorites_v1`;
- exact ordered raw-ID persistence with copy isolation and write-failure propagation;
- a ChangeNotifier controller with explicit loaded state and immutable published ID views;
- current-catalog projection that preserves global storage, hides unknown/unavailable entries, deduplicates visible entries and caps the visible projection at eight;
- duplicate-safe pin, visible-limit enforcement, canonical-ID append semantics and targeted unpin;
- lossless visible reorder using preservation merge so unknown, unavailable and overflow stored IDs are not deleted;
- serialized pin / unpin / reorder mutations so rapid repeated input is applied in invocation order and stale in-flight state cannot produce duplicate writes or false success;
- persist-first / publish-after-success behavior for every mutation.

No Applications launcher UI, Settings implementation, shell cutover, DSM shortcut/order mutation, Task 5 Overview shortcut rewrite, or later Task 6 Batch work is included.

## RED → GREEN evidence

### Task 2.1 — favorites store

- RED test commit: `591b44e5b0b98ce84e413d3834c8209f0c6dd5d7`.
- CI #253 / run `38031650423` / job `114153674335`: **failure**, 250 tests passed / 1 test file failed. The only failure was the expected absent `application_favorites_store.dart` and its undefined store types.
- Initial GREEN implementation: `19ec173e0c24fad868fa135ed7bfa5ece5abadff`.
- CI #255 / run `38031814715` / job `114154165944`: **failure** during test compilation. The locked `sp_util` version exposes `SpUtil.putStringList` as nullable `bool?`, while the frozen store callback contract is `Future<bool>`.
- Minimal compatibility correction: `e0758851de1affd5c3eb426ac4e767b9d38943fa`; a null SpUtil result is treated as persistence failure.
- CI #257 / run `38031962265` / job `114154605169`: **success**, **254 tests passed**, analyzer clean, and the standard APK / identity / artifact tail completed successfully.

### Task 2.2 — projection, pin and unpin

- RED test commit: `1cda5276d169ebdb5f919b53b8e9c4e9b45a1cad`.
- CI #259 / run `38032457476` / job `114156066188`: **failure**, 254 tests passed / 1 test file failed. The remaining failure was only the absent `application_favorites_controller.dart` and undefined controller/outcome types.
- GREEN implementation: `17712f0e41726777bd8f1417895ed4200ceeaadd`.
- CI #260 / run `38032699798` / job `114156778149`: **success**, **262 tests passed**, analyzer clean, beta debug APK built, package/signing identity verified, and artifact uploaded.

The executable controller tests verify exact raw-order restore, unknown/unavailable preservation, first-eight distinct visible projection, duplicate pin no-op, visible-limit rejection without write, canonical append, targeted unpin, and no published mutation after save failure.

### Task 2.3 — preservation reorder

- RED relationship-test commit: `628fa7a2d3cd361168b61072ebe5d0a0400aa435`.
- CI #261 / run `38033357193` / job `114158668519`: **failure**, 262 tests passed / 3 failed. All three failures were the expected explicit `UnimplementedError` from `reorderVisible`.
- GREEN preservation-merge implementation: `6ba63f7249cbb13a132da0350c3df4819dcf9600`.
- CI #262 / run `38033509554` / job `114159110563`: **success**, **265 tests passed**, analyzer clean, and the standard APK / identity / artifact tail completed successfully.

The relationship tests prove that reordering replaces only slots belonging to the current visible favorite set while unknown IDs, known-but-unavailable IDs and eligible overflow entries retain their stored positions relative to the untouched data. Invalid edited membership is rejected without persistence or publication, and failed reorder persistence leaves the prior state published.

### Task 2.4 — independence and rapid mutation review focus

The first test-only commit for this step, `87e609439d8e5d13aaafd54ef91d427f16cb6fc8`, was rejected during required post-commit diff inspection because the newly added tests were inserted inside a helper class body. It is **not** counted as RED evidence and no production code was changed by that commit.

- Corrected test-only commit: `9bfe3c0e9c11e0af40971fb61a11cc3c2971d114`.
- CI #264 attempt 1 / run `38034180640` failed before tests in `flutter pub get` because `gitee.com/apaipai/flutter_sharing_intent.git` reset the connection. This external network failure is **not** counted as RED evidence.
- The failed job was rerun without a code change.
- CI #264 attempt 2 / run `38034180640` / job `114163107107`: **valid RED failure**, **267 tests passed / 2 failed**.
- The static independence and cross-catalog projection tests already passed. The only failures were the two Batch 2 Review Focus concurrency cases:
  - a rapid duplicate pin issued a second write before the first save completed;
  - a rapid pin → unpin sequence did not apply in invocation order.
- GREEN serialization fix: `5ca4ea22746785fa02febdffc81b928c442feeee`.
- CI #265 / run `38035081792` / job `114163736380`: **success**.

The final relationship tests mechanically verify that the favorites authority contains no `UserSettings.apply`, `showShortcut`, shortcut-order, Desktop write-model, or Task 5 Overview-shortcut dependency; changing catalog context only changes the projection and never rewrites the stored list; rapid duplicate pin publishes one change with one write; and rapid pin → unpin is serialized in invocation order.

## Final regression / Android Gate

The executor runtime did not provide a local Flutter/Dart toolchain, so the plan's focused Flutter commands were not falsely recorded as separate local executions. The approved GitHub Actions fallback ran the complete Flutter suite on the exact final implementation HEAD. That full suite includes all B1+B2 Applications tests and the requested Task 5 Overview shortcut regression tests.

Final CI #265 evidence:

| Evidence | Verified result |
| --- | --- |
| Workflow run | #265 / `38035081792` |
| Job | `114163736380` |
| Verified implementation HEAD | `5ca4ea22746785fa02febdffc81b928c442feeee` |
| Workflow event | `push` |
| Workflow conclusion | **success** |
| Whole-suite Flutter tests | **269 passed, 0 failed** |
| B2 Applications tests represented in full suite | **19 passed** |
| Task 5 `overview_shortcuts_test.dart` | represented and passed |
| Task 5 `overview_shortcut_relationship_test.dart` | represented and passed |
| New UI analyzer | **No issues found** |
| Flutter beta debug APK | **Build successful** |
| APK output | `build/app/outputs/flutter-apk/app-beta-debug.apk` |
| Package ID | `top.apaipai.dsm_helper` |
| Signing certificate SHA-256 | `0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2` |
| Uploaded artifact | `dsm-helper-modern-ui-android-debug` |
| Artifact ID | **`11664506152`** |
| Artifact size | `190085692` bytes |
| Uploaded artifact ZIP SHA-256 | `3978a3baebf767aa5fab36f835f3f629779b903bf7d2314f6529fac893aef4a0` |

GitHub Actions artifact: https://github.com/qyxx2/dsm_helper/actions/runs/38035081792/artifacts/11664506152

## Diff / boundary Gate

Implementation diff from immutable Batch 2 start `415598ab011de553900af5ab3d4af69cdea727dc` through verified implementation HEAD `5ca4ea22746785fa02febdffc81b928c442feeee` is 10 commits ahead, 0 behind, and contains exactly five B2 code/test paths:

1. `lib/new_ui/applications/application_favorites_store.dart`;
2. `lib/new_ui/applications/application_favorites_controller.dart`;
3. `test/new_ui/applications/application_favorites_store_test.dart`;
4. `test/new_ui/applications/application_favorites_controller_test.dart`;
5. `test/new_ui/applications/application_favorites_relationship_test.dart`.

No Task 5 Dashboard production file, `lib/pages/**`, Settings production code, shell wiring, Android configuration, workflow, DSM write model, Task 7, or other later-Batch file was changed.

The earlier Batch 1 catalog/destination files are unchanged by the Batch 2 net diff.

## CI trigger correction

Draft PR #7 had originally been opened during Batch 1 only to expose pull-request-triggered CI evidence. During Batch 2, the actual workflow was re-read and confirmed to trigger both:

- `push` on `feature/**`; and
- `pull_request` targeting `modern-ui`.

Keeping the obsolete Batch 1 Draft PR open therefore caused duplicate CI for each code push and its title/body incorrectly scoped the work to Batch 1. With explicit user authorization, PR #7 was closed without merge. Subsequent Batch 2 commits continued to receive the required `push` CI, including final CI #265.

## Device Gate and limitations

**Physical-device Gate: NOT REQUIRED / NOT RUN for Batch 2.**

Batch 2 is an internal persistence/controller authority and is not yet wired into the production Applications UI. No physical-device result is claimed.

Applications launcher controls, visible pin/unpin UI, drag reorder UI, Settings, shell integration and later user-facing behavior remain assigned to later Task 6 Batches.

## Batch 2 Exit Gate

**PASS.**

- local ordered favorites persistence is durable and uses the frozen storage key;
- unknown, unavailable and overflow favorites survive projection and reorder;
- current-context projection exposes at most eight eligible distinct favorites without mutating storage;
- pin/unpin semantics, limit handling and duplicate handling are executable;
- every mutation persists first and publishes only after successful persistence;
- visible reorder uses the frozen preservation-merge rule;
- rapid mutation input is serialized and mechanically regression-tested;
- favorites remain independent from DSM shortcut/order authority and Task 5 Overview shortcuts;
- final full regression, analyzer, Android build, package/signing identity and artifact Gate passed on one immutable implementation HEAD;
- scope diff is limited to B2 files.

Per `CI-DOCS-01`, this acceptance-only commit does not require a redundant Android CI run. The immutable implementation SHA verified by CI remains `5ca4ea22746785fa02febdffc81b928c442feeee`.

**Stop after Task 6 Batch 2. Do not begin Batch 3 and do not merge the Task branch into `modern-ui`.**
