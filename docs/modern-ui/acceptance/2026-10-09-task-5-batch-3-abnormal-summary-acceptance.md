# Task 5 Batch 3 — Abnormal Summary Acceptance

> Date: 2026-10-09  
> Repository: `qyxx2/dsm_helper`  
> Branch: `feature/t5-dashboard`  
> Starting HEAD (Batch 2 acceptance): `bc7b45bf1936adf8bdfd2f49ad777253d4a773e3`  
> **Final verified Batch 3 implementation HEAD:** `24a5d0c4fd5c183a09b5c34a1757a8a679e88dfe`  
> Gate: **PASS — automated Batch 3 scope only**.

## Scope, authorities and contracts

This acceptance covers **Task 5 Batch 3 only**, following the approved
[Task 5 Batch Execution Plan](../plans/2026-10-09-task-5-dashboard-batch-plan.md),
[Task 5 Feature Design](../specs/2026-10-09-task-5-dashboard-feature-design.md),
[Task 5 Contract Matrix](../contracts/2026-10-09-task-5-dashboard-contract-matrix.md),
Task 2 Visual Design and the inherited Batch 1/2 controller, source-state and page contracts.

- **`T5-ABN-01`:** A pure `buildOverviewAlerts` classifier consumes existing `Storage` and `DsmNotify` model objects without another request or polling authority. Only explicit `NOTIFICATION_ERROR` and `NOTIFICATION_WARN` produce notification alerts. Volume `danger` produces error; `attention`, `has_unverified_disk` and `read_only` produce warnings. `normal`, `background`, `background_scrubbing`, `unknown`, other unknown values and absent data do not produce alerts. No local volume utilization/capacity threshold (including 80%) is introduced. Errors sort before warnings. Repeated notification entries are de-duplicated only with a nonempty event title and timestamp plus available source/context identity; otherwise separate records remain separate.
- **`T5-NOTIFY-01`:** The conditional `AbnormalSummary` region appears after fixed core resources only when qualifying alerts exist. Healthy and INFO-only inputs produce no “everything normal” card. Every error/warning has text, a semantically labeled icon and Theme-based severity color, not color alone. Alert taps emit the exact `OverviewAlertDestination` to an **optional** `OverviewPage.onOpenAlertDestination` callback; Batch 3 does not invent or wire a legacy navigation route. The existing independent `onOpenNotifications` App Bar action remains unchanged. When the notification source is stale, its last-valid alert remains shown with an explicit text warning until a valid replacement is received. Ordinary notifications are not listed on Overview.
- Existing `OverviewController` and `OverviewDataSource` remain the sole source lifecycle/DSM read authorities. No auth, context, database, legacy Dashboard, Shell root, widget configuration, shortcut, Task 6 or post-Batch-3 feature was modified.

## Ordered RED → GREEN evidence

1. **Steps 1–2, pure classifier RED** — `054d637f0502bb5ab2e398d61db1587373c51501`. CI **#176**, Run ID **37889264045** (`completed / failure`): 153 pre-existing tests passed; the added classifier suite could not load specifically because `overview_alerts.dart` / its public API was not implemented. [RED run](https://github.com/qyxx2/dsm_helper/actions/runs/37889264045).
2. **Step 3, pure classifier GREEN** — `171bf12514ce0270311ab87c7788af28b58860c4`. Implemented a classifier with direct existing model/enum inputs. Corrected one test-only healthy fixture that had itself supplied `NOTIFICATION_ERROR` instead of a missing level. CI **#177**, Run ID **37889433925**, finished `completed / success`: **159 tests passed**, analyzer clean, APK built. [GREEN run](https://github.com/qyxx2/dsm_helper/actions/runs/37889433925).
3. **Step 4, widget/page RED** — `600d898f44953229c3f4b01a8abc244ca752a732`. CI **#178**, Run ID **37889705105** (`completed / failure`): 153 tests passed; the two new widget/page test files failed to load due only to absent `abnormal_summary.dart` and absent `onOpenAlertDestination` parameter. These are the expected missing-feature RED errors, not a test syntax/environment failure. [RED run](https://github.com/qyxx2/dsm_helper/actions/runs/37889705105).
4. **Steps 5–6, widget/page GREEN and regression** — `24a5d0c4fd5c183a09b5c34a1757a8a679e88dfe`. Added a conditional Material 3 abnormal section and a minimal `OverviewPage` seam. CI **#179**, Run ID **37889868233**, completed **success**: **167 tests passed, 0 failed**, analyzer clean, signed APK built, package/signing verification passed and Artifact uploaded. [Final GREEN run](https://github.com/qyxx2/dsm_helper/actions/runs/37889868233).

### Executable coverage

Classifier tests cover healthy/info/unknown inputs; WARN/ERROR; all four abnormal volume states; normal scrubbing/check states; 99%-used healthy capacity with no invented warning; stable notification deduplication and distinct event identity; and severity-first ordering.

Widget and page tests cover empty-region omission; error/warning text, icon and semantic labels; exact destination forwarding; independent global notification action; normal notification exclusion; preserved last-valid alert during notification refresh failure; and Light/Dark, 2.2× text scaling. Previously accepted Batch 1/2 source-state, polling, stale, lifecycle and display behavior were included in the whole-suite regression.

## Exact final CI proof

| Evidence | Result |
| --- | --- |
| Workflow | Modern UI Android CI |
| Run number / Run ID | **#179 / `37889868233`** |
| Job ID | `113688126633` |
| Checkout SHA | `24a5d0c4fd5c183a09b5c34a1757a8a679e88dfe` |
| Workflow conclusion | **`completed / success`** |
| Flutter / Dart | **3.22.3 / 3.4.4** |
| Whole-project `flutter test` | **167 passed, 0 failed** |
| `flutter analyze` for the workflow's new UI targets | **No issues found** |
| `flutter build apk --debug --flavor beta` | **Success** |
| APK path | `build/app/outputs/flutter-apk/app-beta-debug.apk` |
| Package ID (aapt) | **`top.apaipai.dsm_helper`** |
| APK signing certificate SHA-256 | **`0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2`** |
| Artifact | **`dsm-helper-modern-ui-android-debug`** |
| Artifact ID | **`11598630243`** |
| Artifact size | **190021881 bytes** |
| Uploaded Artifact ZIP SHA-256 | **`79a8e7d50109dd849ce0d98b7a41e4256f12fdbc9f836fa138c3b1694ffa177d` |

Artifact: [run #179 / artifact #11598630243](https://github.com/qyxx2/dsm_helper/actions/runs/37889868233/artifacts/11598630243).

The successful CI ran the **full `flutter test` suite** and its **new-UI analyzer target**, encompassing the Batch 3 files. The Batch Plan's individual focused `flutter test` command groups were **not separately invoked**. No local Flutter/Dart execution, APK installation or direct DSM operation is claimed.

## Diff boundary and device Gate

GitHub Compare from Batch 2 acceptance HEAD `bc7b45bf1936adf8bdfd2f49ad777253d4a773e3` to final verified implementation HEAD shows **exactly six Batch-3-approved paths**:

1. `lib/new_ui/dashboard/overview_alerts.dart` — added
2. `lib/new_ui/dashboard/widgets/abnormal_summary.dart` — added
3. `lib/new_ui/dashboard/overview_page.dart` — modified
4. `test/new_ui/dashboard/overview_alerts_test.dart` — added
5. `test/new_ui/dashboard/abnormal_summary_test.dart` — added
6. `test/new_ui/dashboard/overview_page_test.dart` — modified

The global notification App Bar owner remains in the prior page/shell contract; this Batch only reads existing Overview notification state for alerts. No Task 5 shell cutover or legacy Dashboard deletion occurred.

**Batch 3 Exit Gate: PASS (automated).** The Batch Plan does not require real-device or real-DSM validation at this intermediate, still-unwired UI stage. Accordingly, none is marked tested or accepted. Android identity was verified by CI, **not** by an actual overwrite installation; mandatory Task 5 final integration/device verification remains assigned to Batch 7. No premature acceptance of Batch 4–7, global navigation, real DSM runtime behavior or Task 5 overall completion is implied.

Per `CI-DOCS-01`, committing this **docs-only acceptance** does not require another Android build; the tested implementation SHA above remains distinct from the later documentation-only branch HEAD.

**Stop after Task 5 Batch 3.** Do not automatically implement Batch 4, merge to `modern-ui`, or change another Task.
