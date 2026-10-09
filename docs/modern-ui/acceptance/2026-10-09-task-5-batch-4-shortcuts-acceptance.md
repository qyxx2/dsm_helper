# Task 5 Batch 4 — Overview Shortcuts / Legacy Handoff Acceptance

> Date: 2026-10-09  
> Repository: `qyxx2/dsm_helper`  
> Branch: `feature/t5-dashboard`  
> Starting HEAD (Batch 3 acceptance): `7d4c1be8b4a3bb74e501ecb1a2ae710ea225d914`  
> **Final verified Batch 4 implementation HEAD:** `090254795a9af2224c2055b713e195da1756300b`  
> Gate: **PASS — automated Batch 4 scope only**.

## Authorities, scope and decisions

Implementation follows the approved [Batch Execution Plan](../plans/2026-10-09-task-5-dashboard-batch-plan.md), [Feature Design](../specs/2026-10-09-task-5-dashboard-feature-design.md), [Task 5 Contract Matrix](../contracts/2026-10-09-task-5-dashboard-contract-matrix.md), frozen Visual Design, and existing legacy shortcut mapping / `LegacyPageHost` boundaries.

- **`T5-SHORT-01`:** `OverviewShortcutCatalog.build(InitDataModel)` reads the existing DSM `userSettings.desktop.shortcutItems` and `validAppviewOrder` only. It filters unknown, unsupported and unavailable destinations; retains source order rather than sorting by frequency; returns the first four eligible items. Docker vs Container Manager selection uses actual DSM available-app evidence. Direct container/detail and URL targets retain their exact URL and container-name inputs; invalid or missing target data is skipped rather than guessed. Shortcut objects carry their existing `WidgetBuilder` legacy destination.
- **`T5-SHORT-02`:** `ShortcutSection` forwards the *same selected `OverviewShortcut` object* via optional `onOpenShortcut` without inventing another route. The relationship test routes the emitted real Control Panel destination through `LegacyPageHost`, verifies legacy theme isolation, Back return to the same shell context, and preservation of another primary tab's nested stack. **Production shell cutover / provider-wrapped shortcut invocation is deferred to Batch 7 by the approved Batch Plan**; no live-shell wiring is claimed in Batch 4.
- **`T5-SHORT-03`:** The Modern Overview always renders its structural shortcut section after the conditional abnormal summary, independently of legacy `SettingProvider.showShortcut`. Empty eligible input renders an explicit restrained DSM-configuration message rather than removing the region. Populated content is a single compact four-column portrait row. The page reads its current `InitDataProvider` authority and forwards optional `onOpenShortcut`.

No new shortcut persistence, editor, DSM write protocol, transport, session authority or refresh loop was introduced. Legacy Dashboard files and global navigation were not changed.

## Ordered RED → GREEN evidence

1. **Steps 1–2 — catalog RED.** Test created at `a9032763c9447c497cad63f15ddde62ae81a8634`; a test-only invalid-context fixture was corrected at `cfcac8e8e9cbfda7df05c36f7c9c2316f778b0b1`. The corrected authoritative RED was CI **#181**, Run ID **37891133815**, Job ID **113692096546**: **167 pre-existing tests passed, 1 test file failed to load** specifically because `overview_shortcuts.dart` / `OverviewShortcutCatalog` did not yet exist. The earlier CI #180 is **not** counted as authoritative RED due to its test-fixture issue. [RED CI #181](https://github.com/qyxx2/dsm_helper/actions/runs/37891133815).
2. **Step 3 — catalog GREEN.** Implementation `61ade2f3620efc2bba1c1eed50a6525c2b5b8636`; CI **#182**, Run ID **37891415329**, Job ID **113692957036**, completed success: **173 tests passed**, analyzer clean, signed APK built and verified. [GREEN CI #182](https://github.com/qyxx2/dsm_helper/actions/runs/37891415329).
3. **Steps 4–5 — section/page and relationship RED.** Tests committed at `d8bc973d57d2545b4f5c1796e928cd6c92ecf88b`. CI **#183**, Run ID **37892363455**, Job ID **113695904930**, completed failure: **164 existing tests passed, three new test files failed to load**, caused by the expected absent `ShortcutSection` and missing `OverviewPage.onOpenShortcut` parameter. These were missing-feature errors, not new environment or test syntax failures. [RED CI #183](https://github.com/qyxx2/dsm_helper/actions/runs/37892363455).
4. **Step 6 — UI GREEN, full regression and analyze.** Implementation `090254795a9af2224c2055b713e195da1756300b` adds `ShortcutSection` and the minimal Overview presentation/callback integration. CI **#184**, Run ID **37892693133**, Job ID **113696927109**, completed success: **180 tests passed, 0 failed**, analyzer clean, signed APK built, install identity verified, Artifact uploaded. [Final GREEN CI #184](https://github.com/qyxx2/dsm_helper/actions/runs/37892693133).

### Executable coverage and verification provenance

Pure catalog tests exercise mixed supported/unsupported/unavailable input, DSM source order, five-eligible-entry truncation, Docker/Container Manager availability, exact URL/container details, and empty/missing data. Section/page tests cover fixed presence with legacy `showShortcut=false`, empty configuration text, ordered four-column row, exact callback object and real Overview integration. The relationship test covers emitted destination → legacy Control Panel widget through `LegacyPageHost` → isolated legacy theme → Back to original shell → another tab's nested stack unchanged.

The successful GitHub Actions workflow executed the **complete `flutter test` suite**, including the Batch 4 tests and existing `test/new_ui/legacy` and `test/new_ui/app` tests. Its Flutter analyzer ran against the workflow's `lib/new_ui` and `test/new_ui` targets, which include the Batch 4 dashboard sources/tests. The Batch Plan's separately grouped focused commands were **not independently run**, and no local Flutter/Dart execution is claimed.

## Final CI / APK identity

| Evidence | Verified result |
| --- | --- |
| Workflow | Modern UI Android CI |
| Final workflow run | **#184 / `37892693133`** |
| Job ID | `113696927109` |
| Checked-out implementation SHA | `090254795a9af2224c2055b713e195da1756300b` |
| Run/job conclusion | **completed / success** |
| Whole-suite `flutter test` | **180 passed, 0 failed** |
| `flutter analyze` (new UI targets) | **No issues found** |
| `flutter build apk --debug --flavor beta` | **Success** |
| Built APK | `build/app/outputs/flutter-apk/app-beta-debug.apk` |
| Package ID | `top.apaipai.dsm_helper` |
| Signing certificate SHA-256 | `0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2` |
| Artifact name | `dsm-helper-modern-ui-android-debug` |
| Artifact ID | `11599625848` |
| Artifact size | `190021881` bytes |
| Uploaded artifact ZIP SHA-256 | `ff6ea89f250399bf8b5bf2e2b86137f904a1cac725ba00a600bef8a040092c0e` |

[Final APK artifact #11599625848](https://github.com/qyxx2/dsm_helper/actions/runs/37892693133/artifacts/11599625848).

## Diff boundary, Exit Gate and deferred work

GitHub Compare from Batch 3 acceptance HEAD `7d4c1be8b4a3bb74e501ecb1a2ae710ea225d914` to final implementation HEAD verifies **exactly seven Batch-4-approved production/test paths**:

1. `lib/new_ui/dashboard/overview_shortcuts.dart` — added.
2. `lib/new_ui/dashboard/widgets/shortcut_section.dart` — added.
3. `lib/new_ui/dashboard/overview_page.dart` — modified.
4. `test/new_ui/dashboard/overview_shortcuts_test.dart` — added.
5. `test/new_ui/dashboard/shortcut_section_test.dart` — added.
6. `test/new_ui/dashboard/overview_shortcut_relationship_test.dart` — added.
7. `test/new_ui/dashboard/overview_page_test.dart` — modified.

**Batch 4 Exit Gate: PASS (automated).** Max-four, source-order, availability filtering, fixed-region semantics, lack of added shortcut persistence and test-proven legacy handoff isolation satisfy the Batch 4 acceptance conditions.

**NOT TESTED:** real DSM availability / live Docker and shortcut behavior, actual navigation from production shell (not yet wired), real-device APK installation or overwrite, session preservation, light/dark on physical hardware, and production callback routing. These are not represented as accepted; the master Batch Plan explicitly assigns integrated shell wiring and real-device verification to **Batch 7**. No Task 5 overall completion is claimed.

Per `CI-DOCS-01`, the acceptance is a documentation-only commit; the verified implementation SHA remains the exact immutable #184 source even when documentation later advances branch HEAD.

**Stop after Task 5 Batch 4.** Do not automatically implement Batch 5, merge into `modern-ui`, or change another Task.
