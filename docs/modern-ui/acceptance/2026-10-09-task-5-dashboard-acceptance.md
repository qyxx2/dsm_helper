# Task 5 — Dashboard Final Acceptance

> Date: 2026-10-09  
> Repository: `qyxx2/dsm_helper`  
> Branch: `feature/t5-dashboard`  
> Task start: `82912d8e21114f6070a020ea36fa8c6fc34a9e80`  
> Original Batch 7 device-review implementation: `7f746e52844a20bea67eef7864266576d18fb1eb`  
> **Final verified implementation HEAD: `699157d1dbb16aab34d306589b29ddb4ef1a26ee`**  
> Gate: **PASS — Task 5 complete for the declared automated and real-device scope.**

## Authority and completed scope

Task 5 was implemented under the approved [Feature Design](../specs/2026-10-09-task-5-dashboard-feature-design.md), [Contract Matrix](../contracts/2026-10-09-task-5-dashboard-contract-matrix.md), [Batch Execution Plan](../plans/2026-10-09-task-5-dashboard-batch-plan.md), frozen Modern UI visual rules, and the approved [two-item Batch 7 corrective follow-up](../plans/2026-10-09-task-5-batch-7-ui-corrective-follow-up.md).

The completed Task 5 surface includes the Modern Overview data/refresh state model, fixed core resource presentation, abnormal summary, legacy shortcut handoff, owned extension configuration/preservation, read-only CurrentConnection / TaskScheduler extensions, formal Overview shell cutover, context/session/navigation relationships, and the two post-device-review UI corrections. Legacy Dashboard remains available as the retained fallback authority; no Task 6 implementation is included.

Earlier Batch 1–6 acceptance records remain the detailed authority for their independent RED→GREEN and scope gates. This document records the integrated Batch 7 / Task 5 gate and does not replace those records.

## Original Batch 7 integrated CI and real-device evidence

The pre-correction integrated implementation was `7f746e52844a20bea67eef7864266576d18fb1eb`.

Modern UI Android CI [#223](https://github.com/qyxx2/dsm_helper/actions/runs/37914125683), run `37914125683`, job `113766061104`, completed **success**:

- whole-suite Flutter tests: **227 passed, 0 failed**;
- targeted New UI analyzer: **No issues found**;
- beta debug APK built successfully;
- package ID: `top.apaipai.dsm_helper`;
- signing certificate SHA-256: `0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2`;
- uploaded artifact: `dsm-helper-modern-ui-android-debug`, artifact ID `11609616658`, size `190088876` bytes, ZIP digest `sha256:dff90070670a7bae52e125f80b99f78ff6aa84d4b41dd5470ddd66df07bd8aae`.

The user completed the four planned Batch 7 physical-device review stages (11-A/B/C/D) on the #223 APK for the actual HTTP LAN DSM deployment. The accepted scope included direct overlay installation with existing app data/login state retained, Modern Overview startup and live DSM presentation, refresh/offline/recovery behavior, navigation/legacy handoff, Overview configuration/extensions and global notification access. The user explicitly did not require HTTPS/self-signed, a second account, OTP, or a forced DSM-119 physical-device scenario.

The original device review produced exactly two approved presentation corrections rather than a failed Task 5 gate:

1. **B7-UI-01:** move `数据刷新中` out of the Overview body into a stable fixed-width AppBar slot so refresh cannot shift the NAS name/resource cards.
2. **B7-UI-02:** show up to four trustworthy HDD/SSD temperatures in each storage-space card's unused upper-right header area, without adding a separate temperature row.

No shortcut-editor work or other enhancement was approved as part of this correction.

## Corrective follow-up RED → GREEN evidence

### B7-UI-01 — refresh layout stability

- RED commit `12aab32f15a3b77d10c4be48009a4ba547ce277b`; CI #224 / run `37923158382`: **226 tests passed, 2 failed**, both because the required fixed AppBar refresh slot was absent.
- Minimal production implementation `007a505c4a3aeefd1c86e3f31907f1623c83e44e` moved the indicator into the AppBar while retaining the existing `OverviewController`, refresh phases, last-valid/stale/error semantics and refresh ownership.
- Test-only semantics-finder corrections ended at `c1d474cb08ab8081fa90d60e3e99e26e141d9618`.
- CI [#227](https://github.com/qyxx2/dsm_helper/actions/runs/37924154361), run `37924154361`, job `113798961084`: **228 tests passed**, analyzer clean, APK built, package/signing identity verified.

### B7-UI-02 — per-volume disk temperatures

- RED test commit `7e109a741d5443554af076ff7e56d01328b55187`.
- CI #228 attempts 1–2 failed before tests because the existing Gitee-hosted `flutter_sharing_intent` dependency connection was reset; these attempts are recorded as infrastructure failures and are not RED evidence.
- CI #228 attempt 3 reached Flutter tests: **228 tests passed, 7 failed**. All seven new failures were the intended missing disk-temperature behavior.
- Production implementation began at `d38f3c5cc7f502ea8953f3adaebcf62d28558acf`: exact volume→pool→disk mapping, trustworthy `isSsd` typing, valid positive finite temperature filtering, same-pool `usedBy` fallback only when unambiguous, stable source order, four-item cap and no fabricated placeholders.
- CI #229 reached **234 tests passed, 1 failed**, isolating the remaining ordinary-width two-column layout requirement.
- CI #230 failed during dependency restore from the same existing Gitee network reset and is not code evidence.
- CI #231 again reached **234 tests passed, 1 failed**, confirming the same two-column layout issue.
- Final layout implementation `699157d1dbb16aab34d306589b29ddb4ef1a26ee` uses explicit two-column temperature rows at ordinary phone widths with a narrow/large-font responsive wrap fallback.

The temperature contract tests cover a single HDD without dummy cells, mixed 2 HDD + 2 SSD labels, 5+ disk capping, two pools/two volumes without cross-pool leakage, shared-pool reuse, ambiguous/missing relations, null/nonfinite/nonpositive temperatures, unknown `isSsd`, `usedBy` fallback, capacity/status preservation, and narrow portrait + large-font/dark rendering.

## Final CI / Android identity Gate

Modern UI Android CI [#232](https://github.com/qyxx2/dsm_helper/actions/runs/37926403702), run **`37926403702`**, job **`113806284686`**, verified checkout **`699157d1dbb16aab34d306589b29ddb4ef1a26ee`**, completed **success**:

| Evidence | Verified result |
| --- | --- |
| Whole-suite Flutter tests | **235 passed, 0 failed** |
| New UI analyzer | **No issues found** |
| Flutter beta debug APK | **Build successful** |
| APK output | `build/app/outputs/flutter-apk/app-beta-debug.apk` |
| Package ID | `top.apaipai.dsm_helper` |
| Signing certificate SHA-256 | `0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2` |
| Uploaded artifact | `dsm-helper-modern-ui-android-debug` |
| Artifact ID | **`11614223486`** |
| Artifact size | `190085692` bytes |
| Uploaded artifact ZIP SHA-256 | `3ce43aac52cd992217a59ec4d2649f09db0cf92d2e53e577f66d983588ac3d4e` |

[Downloadable final GitHub Actions APK artifact #11614223486](https://github.com/qyxx2/dsm_helper/actions/runs/37926403702/artifacts/11614223486).

The final correction diff from immutable pre-correction baseline `7f746e52844a20bea67eef7864266576d18fb1eb` contains only the approved corrective plan plus the four whitelisted code/test paths:

1. `lib/new_ui/dashboard/overview_page.dart`;
2. `lib/new_ui/dashboard/widgets/core_resource_section.dart`;
3. `test/new_ui/dashboard/overview_page_test.dart`;
4. `test/new_ui/dashboard/core_resource_section_test.dart`;
5. `docs/modern-ui/plans/2026-10-09-task-5-batch-7-ui-corrective-follow-up.md`.

No controller, API/model/provider, session/router, Android config/workflow, legacy Dashboard or Task 6 path was changed by the corrective implementation.

## Final focused real-device Gate

The user overlay-installed the final #232 APK and reported **“测试没有问题”** for the requested focused verification. This records PASS for the final correction scope:

- manual and automatic refresh no longer create the previous Overview body shift; the NAS/resource region and AppBar edit/notification actions remain usable;
- storage-space cards show the available real HDD/SSD temperature labels in the intended upper-right area without a separate temperature row or dummy cells;
- storage capacity/used/free presentation and basic navigation remain correct.

The earlier 11-A/B/C/D device observations were made against #223 and are not falsely recorded as completely rerun against #232. The #232 focused Gate is the required post-correction confirmation.

## Explicit NOT TESTED / NOT CLAIMED

The following remain **NOT TESTED on physical hardware** for Task 5 and are not silently promoted to PASS:

- HTTPS / self-signed DSM endpoint;
- a second saved account;
- OTP / 2FA;
- deliberately forced DSM error 119 runtime reauthentication.

These scenarios were already outside the user's declared physical-device scope and Task 5 introduced no new dependency that makes them a blocker. Their automated relationship/contract coverage remains separate from physical-device evidence.

## Final Task 5 Exit Gate

**PASS — Task 5 is complete for the declared scope.**

- Modern Overview is the formal Overview root while legacy Dashboard remains retained as fallback.
- B1–B6 accepted contracts remain covered by the final 235-test suite.
- refresh ownership, partial failure/last-valid/stale behavior, context isolation, runtime-auth relationship, notification access and legacy handoff remain in the integrated suite.
- the two approved post-device-review corrections are automated and physically confirmed.
- final Android package/signing identity is stable and the APK artifact is available.
- no Task 6 code has been started by this closure.

Per `CI-DOCS-01`, this final acceptance and Master Plan status update are documentation-only closure. Their docs-only commit does not replace immutable implementation SHA `699157d1...` verified by CI #232 and does not require another Android CI run.

**Stop after Task 5. Do not automatically merge `feature/t5-dashboard` into `modern-ui` or begin Task 6.**
