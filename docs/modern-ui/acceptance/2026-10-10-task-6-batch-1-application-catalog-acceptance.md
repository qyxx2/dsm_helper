# Task 6 Batch 1 — Canonical Application Catalog / Destination Foundation Acceptance

> Date: 2026-10-10  
> Repository: `qyxx2/dsm_helper`  
> Branch: `feature/t6-applications-settings`  
> Batch start: `6b3aecae98b93b7b948a0117bc848f3d0691ae89`  
> **Final verified implementation HEAD: `b0a832302b447d87f66b8054b21bb213961a14ca`**  
> Gate: **PASS — Task 6 Batch 1 complete. Stop before Batch 2.**

## Authority and scope

Batch 1 was implemented against:

- `docs/modern-ui/specs/2026-10-10-task-6-applications-settings-feature-design.md`;
- `docs/modern-ui/contracts/2026-10-10-task-6-applications-settings-contract-matrix.md`;
- `docs/modern-ui/plans/2026-10-10-task-6-applications-settings-batch-plan.md`.

Accepted contracts are `T6-APP-01`, `T6-APP-02`, the destination-completeness portion of `T6-APP-03`, and `T6-APP-04`.

The resulting foundation defines the twelve canonical Modern application IDs, stable persistence keys, loaded/unavailable catalog snapshots, DSM source-order filtering, non-empty `validAppviewOrder` → `appviewOrder` fallback, explicit supported metadata/assets, Log Center and Docker/Container Manager alias canonicalization, first-source-position dedupe, and explicit concrete legacy destination builders.

No Applications launcher UI, favorites persistence/state, Settings implementation, shell cutover, or later Task 6 Batch work is included.

## RED → GREEN evidence

### Task 1.1 / 1.2 — source availability and fallback

- RED test commit: `72925672e70c201a8f883e928084cf50433ce8d8`.
- CI #236 / run `38028412415` / job `114144067230`: **failure**, 235 tests passed / 1 test file failed. It contained the expected missing Task 6 catalog failure, but also exposed a test-fixture mistake: the generated `Desktop` constructor has no `appviewOrder:` named parameter.
- Test-only fixture correction: `83ac5cbe194b91471a7e1b38176c890b7d2f20c0`; no production code changed.
- Clean RED CI #238 / run `38028704834` / job `114144929128`: **failure**, 235 passed / 1 failed; the remaining failure was only the absent `application_catalog.dart` / Task 6 catalog types.
- Minimal GREEN implementation: `55a5da98076a46f716e0316fbf262687d6ce01fa`.
- CI #240 / run `38028854030` / job `114145372039`: **success**, 240 tests passed, analyzer clean, beta debug APK built, package/signing identity verified and artifact uploaded.

### Task 1.3 — aliases, dedupe and stable order

- RED test commit: `2e1cf86975af8720b6718d0d2584c587ffa3340c`.
- CI #242 / run `38029381677` / job `114146923410`: **failure**, 240 passed / 5 failed. All five new failures were the expected missing Log Center alias, Docker/Container Manager canonicalization, first-occurrence position, preferred Container Manager presentation, and neighboring-order behavior.
- GREEN implementation: `a81e91e9495b59f004d9e9650bfb7768a25e247f`.
- CI #244 / run `38029583873` / job `114147516311`: **success**, 245 tests passed and analyzer clean; the standard APK/identity/artifact tail also completed successfully.

### Task 1.4 — explicit destinations and B1 completeness correction

- Destination RED test commit: `2c1439ea3f0180df7f20c3fc00d8754dbc9811c3`.
- CI #246 / run `38030010685` / job `114148774557`: **failure**, 245 passed / 1 failed; the only failure was the absent `application_destination_catalog.dart`.
- During the required B1 contract review before GREEN, the then-minimal catalog was found to resolve only six of the twelve frozen canonical families and to hard-code versioned legacy assets under `assets/applications/7`. Those were B1 `T6-APP-02` / presentation-metadata defects, not later-Batch features.
- Corrective RED test commit: `e29bef5ef903797a1820fbb7ee42b45af0bcbd70`.
- CI #248 / run `38030186215` / job `114149296335`: **failure**, 245 passed / 3 failed. The failures were exactly: missing destination catalog, missing six remaining one-to-one supported application mappings, and versioned asset path not following active `Utils.version`.
- Final GREEN implementation: `b0a832302b447d87f66b8054b21bb213961a14ca`.
- CI #250 / run `38030385833` / job `114149885212`: **success**.

The final catalog resolves all frozen supported families: Control Panel, Package Center, Resource Monitor, Storage Manager, Log Center, Security Advisor, Xunlei, Docker/Container Manager, Download Station, Moments, Synology Photos and Virtual Machine Manager. Unknown DSM IDs remain omitted and no route is guessed.

The final destination catalog provides a non-null explicit concrete builder for every `ModernApplicationId`. Log Center maps directly to `LogCenter`; Xunlei remains the explicit `Browser(title: '迅雷-远程设备', url: 'https://pan.xunlei.com/yc/?fromApp=paipai')` special case rather than relying on named-route completeness.

## Final regression / Android Gate

The executor runtime did not provide a local Flutter/Dart toolchain, so the plan's focused Flutter commands were not falsely recorded as separate local executions. The approved GitHub Actions fallback ran the complete Flutter suite on the exact final implementation HEAD, which includes every requested focused regression directory.

Final CI #250 evidence:

| Evidence | Verified result |
| --- | --- |
| Workflow run | #250 / `38030385833` |
| Job | `114149885212` |
| Verified implementation HEAD | `b0a832302b447d87f66b8054b21bb213961a14ca` |
| Workflow conclusion | **success** |
| Whole-suite Flutter tests | **250 passed, 0 failed** |
| B1 Applications tests represented in full suite | **15 passed** |
| Requested related `new_ui/app` tests represented | **5 passed** |
| Requested related `new_ui/shell` tests represented | **8 passed** |
| Requested related `new_ui/legacy` tests represented | **8 passed** |
| Requested related `new_ui/session` tests represented | **9 passed** |
| New UI analyzer | **No issues found** |
| Flutter beta debug APK | **Build successful** |
| APK output | `build/app/outputs/flutter-apk/app-beta-debug.apk` |
| Package ID | `top.apaipai.dsm_helper` |
| Signing certificate SHA-256 | `0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2` |
| Uploaded artifact | `dsm-helper-modern-ui-android-debug` |
| Artifact ID | **`11661438879`** |
| Artifact size | `190085692` bytes |
| Uploaded artifact ZIP SHA-256 | `085004af560bfcddea2ba56b38a2920d0b85d0dede03305ca79b09ac2da3d3f3` |

GitHub Actions artifact: https://github.com/qyxx2/dsm_helper/actions/runs/38030385833/artifacts/11661438879

## Diff / boundary Gate

Implementation diff from immutable Batch 1 start `6b3aecae98b93b7b948a0117bc848f3d0691ae89` through verified implementation HEAD `b0a832302b447d87f66b8054b21bb213961a14ca` contains exactly four B1 code/test paths:

1. `lib/new_ui/applications/application_catalog.dart`;
2. `lib/new_ui/applications/application_destination_catalog.dart`;
3. `test/new_ui/applications/application_catalog_test.dart`;
4. `test/new_ui/applications/application_destination_catalog_test.dart`.

No `lib/pages/**`, Task 5 Dashboard, auth/session, Android configuration, workflow, Settings, favorites, shell-cutover, Task 7, or other later-Batch file was changed.

## Device Gate and limitations

**Physical-device Gate: NOT REQUIRED / NOT RUN for Batch 1.**

Batch 1 is an internal pure catalog/destination foundation and is not wired into the production Applications user path. No physical-device result is claimed.

The accepted `T6-APP-03` scope here is destination completeness only. Actual Applications UI tap → `LegacyPageHost` + current `DsmProviderScope` navigation/back-stack relationship remains for the later Batch explicitly assigned to launcher UI and shell wiring. Favorites and Settings are also intentionally absent.

## Batch 1 Exit Gate

**PASS.**

- source availability vs loaded-empty semantics are executable;
- non-empty valid-order fallback behavior is executable;
- supported canonical IDs, aliases, dedupe and source-relative order are executable;
- existing application asset selection is explicit and DSM-version-aware where applicable;
- every canonical application has an explicit concrete destination;
- final full regression, analyzer, Android build, package/signing identity and artifact Gate passed on one immutable implementation HEAD;
- scope diff is limited to B1 files.

Per `CI-DOCS-01`, this acceptance-only commit does not require a redundant Android CI run. The immutable implementation SHA verified by CI remains `b0a832302b447d87f66b8054b21bb213961a14ca`.

**Stop after Task 6 Batch 1. Do not begin Batch 2 and do not merge the Task branch into `modern-ui`.**
