# Task 6 Batch 4 — Modern Settings Shell Acceptance

## Outcome and scope

- **Result:** PASS — Batch 4 isolated Settings root and its applicable automated Exit Gate.
- **Task / Batch:** Task 6 / Batch 4, Modern Settings Shell.
- **Work branch:** `feature/t6-applications-settings`.
- **Batch 3 accepted base:** `38830b06ad890bce76eee18e90c6ad83b6209dbb`.
- **Final implementation HEAD (CI-verified):** `7039610a1bd86b7ec7f6738c13144b6c0969adce`.
- **Acceptance-only documentation commit:** follows this implementation HEAD; per `CI-DOCS-01`, it does not require another APK build.
- **Not included:** Batch 5 shell cutover, Task 7, integration-branch merge, legacy Settings deletion, power-control backend, Dynamic Color.

This Batch completes the Modern Settings page **in isolation**; `DsmNewUiShell` remains on the pre-Batch-5 root wiring.

## Completed steps and contracts

| Step | Verification / outcome | Contracts |
| --- | --- | --- |
| 4.1 | One continuous sectioned Settings page (当前设备与账号 → 外观 → 应用设置 → 关于), optional InitData session hostname/user, empty-context presentation, account management, personal/helper/compatibility/About and logout callbacks; corrected existing implementation and validated widget tests. | `T6-SET-01`, `T6-SET-03` |
| 4.2 | Bottom Sheet exposes System / Light / Dark only; maps to pre-existing `DarkModeProvider` 2 / 0 / 1 and persists `dark_mode` through existing `SpUtil`; changes do not call auth, logout or legacy callbacks. | `T6-SET-02`, `T6-SET-06` |
| 4.3 | Widget and source-boundary assertions confirm no Modern shutdown/reboot operation, callback or `SYNO.Core.System` power transport; legacy power source unchanged. | `T6-SET-05` |
| 4.4 | Page-level Light/Dark tests cover User, Helper, About and compatibility legacy-child handoffs; hosted legacy theme isolation and Android Back return to the same My root without account/logout transitions. | `T6-SET-04`, `T6-NAV-01`, `G-THEME-02` |
| 4.5 | Nested-tab route harness checks theme change retains the selected My tab, nested Settings route, hostname/user sentinel and state; stored theme value restores on remount. | `T6-SET-02`, `T6-NAV-01` |
| 4.6 | Whole-repository Flutter test, targeted New UI analyze, beta debug APK build, install identity check and artifact upload succeeded at the **same implementation HEAD**. | Batch 4 regression and `APK-IDENTITY-01` |

The root reads existing `InitDataProvider` and `DarkModeProvider`, does not initiate new DSM requests, and delegates Task 4 account/logout behavior through constructor callbacks rather than creating competing controllers.

## Test-first / CI evidence

| Commit | Run | Actual result |
| --- | --- | --- |
| `378f41d5`, `83538419` | #278, #279 | Initial Settings root and sheet export existed prior to the newly added tests; CI completed successfully. |
| `79116961` | #280 | **RED**: 283 passed / 3 failed. Tests exposed the invalid `InitDataModel.systemInfo` access and missing contract presentation/entry behavior. |
| `11505f32` | #281 | Root corrected to real `InitDataModel.session.hostname/user`, contract section/entries. 285 passed / 1 failed; failure narrowed to a test looking for an unbuilt lazy-list About row. |
| `fe0bc9e9` | #282 | 286 tests passed and analyze clean. Android build failed resolving `io.flutter:x86_64_debug`: Aliyun Maven returned HTTP 502 (including build tool's retry). No application-code cause shown. |
| `184c5faa` | #283 | Theme-mode/persistence/callback-isolation tests added; CI **success**. The mode sheet behavior was already present: **no distinct 4.2 RED was observed**, and no artificial RED was manufactured. |
| `fce76093` | #284 | Power-boundary test added; CI **success**. Test-only contract proof, not a production change. |
| `c68ee7d1` | #285 | Legacy handoff, theme and Back relationship tests added; CI **success**. Test-only proof. |
| `7039610a` | **#286** | Final theme/navigation/context/persistence relationship added; **completed / success**. |

RED/partial-green failures were investigated from actual job logs. Apart from the initial Settings root, the later tests verify existing or newly assembled behavior without requiring additional production changes. Their absence of an individual RED is not misreported as a test-first production cycle.

## Final implementation verification — CI #286

- **Workflow:** Modern UI Android CI.
- **Run number:** `286`.
- **Run ID:** `38047184703`.
- **Workflow URL:** https://github.com/qyxx2/dsm_helper/actions/runs/38047184703
- **Job ID:** `114198963980`.
- **Head SHA:** `7039610a1bd86b7ec7f6738c13144b6c0969adce`.
- **Status / conclusion:** `completed / success`.
- **Flutter SDK:** `3.22.3`.
- **Full `flutter test`:** **293 passed, 0 failed** (includes the Settings tests and all existing repository tests).
- **`flutter analyze lib/new_ui test/new_ui`:** **No issues found**.
- **Android:** `flutter build apk --debug --flavor beta` **success**; generated `app-beta-debug.apk`.
- **Application ID:** `top.apaipai.dsm_helper`.
- **Development signing certificate SHA-256:** `0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2`.
- **Artifact:** `dsm-helper-modern-ui-android-debug`, ID `11667872350`; upload successful, size `190085692` bytes.
- **Artifact ZIP SHA-256 (not APK-byte digest):** `1378c5c2f253798a0ae3054c009379845649fb00a80da4823a770bb9e3d55652`.
- **Artifact:** https://github.com/qyxx2/dsm_helper/actions/runs/38047184703/artifacts/11667872350

Individual commands from the Batch Plan (`flutter test test/new_ui/settings/` and the related subdirectory-targeted commands) were **not separately executed**; the final CI ran the full `flutter test` covering these tests. Flutter/Dart are not installed in the executor runtime, so **no local Flutter tests, analysis or APK build are claimed**.

## Final diff boundary

Compared with `38830b06ad890bce76eee18e90c6ad83b6209dbb`, implementation changes comprise **only**:

- `lib/new_ui/settings/settings_page.dart`
- `lib/new_ui/settings/settings_theme_mode_sheet.dart`
- `test/new_ui/settings/settings_page_test.dart`
- `test/new_ui/settings/settings_theme_relationship_test.dart`
- `test/new_ui/settings/settings_navigation_relationship_test.dart`

No `lib/pages/**` legacy source, Task 4 auth/session controller, Task 5 Dashboard, Android configuration, Gradle dependency, or production-shell cutover file changed. The acceptance document is the sole documentation addition after verified implementation.

## Device Gate, limitations and stop boundary

- **Batch 4 does not require a real Android/DSM device Gate:** new Settings root is not yet wired into the formal five-tab user path. Automated and CI results are the applicable Batch 4 Exit Gate.
- The **final Task 6** overlay installation, root-page visual review and real DSM handoffs belong to **Batch 5**, not this Batch.
- `SettingsThemeModeSheet` is exported by the dedicated sheet file while the implementation remains in `settings_page.dart`; no duplicated preference or theme authority was introduced.
- Legacy compatibility behavior and system power APIs were **not migrated or newly verified**; this Batch only proves page-level handoff and the explicit Modern power exclusion.
- No unsupported test scenario is claimed to have passed on a physical device.

**Batch 4 Exit Gate: PASS.** All in-scope functionality and CI/APK gates are satisfied. No automatic Batch 5 work, PR merge or integration-branch modification is authorized by this acceptance.
