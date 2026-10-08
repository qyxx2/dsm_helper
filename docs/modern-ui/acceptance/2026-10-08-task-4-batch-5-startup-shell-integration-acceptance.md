# Task 4 Batch 5 — Startup, Reauth and Shell Integration Acceptance

> **Status: PASS — Batch 5 automated Exit Gate**
> Date: 2026-10-08
> Task: Task 4 — Server / Account / Login / OTP
> Batch: 5 — Startup, Reauth and Shell Integration
> Branch: `feature/t4-server-auth`
> Previous Batch 4 acceptance commit: `208963a9dce1c320a4bd22d9d6dd8d4575f17887`
> **Verified implementation HEAD: `422dbe0bfc5e4e353c3b1e5fa23a76afb44e064c`**

## Implemented contracts and relationships

- **`T4-SESS-01` / Task 3 active-context handoff:** Modern startup and saved-account selection reuse the existing `DsmActiveContextAdapter.activate` / active-context coordination path. Successful account authentication persists the saved session before attempting activation; only the returned authenticated/offline result opens the Modern shell. Activation failures do not open a bare shell.
- **`T4-AUTH-02` / exact reauthentication:** a restored default Account whose saved SID is rejected with DSM 119 is carried to the Task 4 reauthentication flow for that exact existing Server + Account, not converted to generic account selection or inserted as a duplicate row. A successful reauth updates the existing Account and reactivates its context.
- **Cold-start routing:** no Server opens Modern add-server, explicitly requested selection opens Modern account selection, and one saved default follows its existing authenticated/reauth/offline classification. Ordinary connectivity failure may enter the offline shell without being misclassified as invalid credentials.
- **Context switching and capability authority:** selecting a different Account clears the previous capability/context state through Task 3, binds the new identity, and activates it before showing the shell. Relationship tests prove persistence/activation ordering and isolation with actual Drift/SQLite where applicable.
- **Task 4 UI entry points:** `ModernUiRoot` wires Modern Server form, selector and Login controllers into the existing shell. The “我的” account-management and logout actions return through the Modern root, using a minimal interception in legacy Settings while preserving unrelated legacy fallback features. Task 4's migrated auth flow does not deliberately navigate through the old bare-`ModernUiShellEntry` shortcut.
- **Frozen visual scope:** the migrated auth gate applies the existing `NewUiTheme.light()/dark()` theme (including the approved `#00A6FF` seed), without redesigning legacy presentation or the global Material 3 system.

Implementation remains a thin adapter over the existing Drift, DSM `Auth`, transport and Task 3 context authorities. No new schema, independent auth service, QuickConnect flow, Task 5 UI or downstream Batch 6 code is included.

## RED → GREEN and corrective evidence

1. Initial relationship RED: commit `af94a7cd01aacc350ef7a9ddc48b565cac5cb4b9`, CI **#151** / `37749138149` failed on exact saved-default DSM 119 routing. The corrective startup commit `c8e4c31c33e46f9ff675ad15a9395bd4c516a2d6` passed CI **#152** / `37749380018`.
2. Task 4 shell/root wiring commit `9cbd26e6c243ccbfc1861332ad92afea570edcb2` passed CI **#153** / `37750270034`.
3. First expanded widget tests at `a57215c5922b8cca4b3f164008b045d34404c4b5` blocked CI **#154** because native Drift database Futures were awaited inside Flutter widget-test fake async. Diagnostic attempts **#155/#156** did not provide valid GREEN evidence. Commit `d3d6e08e0d83ae01d077e7766433c7a9ed25926c` separated real database checks into regular asynchronous `test(...)` and UI checks into isolated `testWidgets(...)`; CI **#157** passed the Flutter test/analyze steps but the Android Gradle build failed on `JetifyTransform` Java heap exhaustion. This failed run is not counted as final acceptance.
4. Visual theme RED: `fd9842e23854cd958636c5d0046209a1f06da19a`, CI **#158** / `37756109324` (116 tests passed, one intentional theme assertion failure). The minimal `NewUiTheme` integration at `422dbe0bfc5e4e353c3b1e5fa23a76afb44e064c` passed final CI **#159** / `37756282193`, including Android APK construction with the unchanged Gradle configuration.

The interrupted/failed workflows above are diagnostic evidence only. **Only CI #159 is the final all-GREEN verification of the accepted implementation SHA.** Local Flutter/Dart executions were not available in the assistant environment; all test/build evidence in this record comes from remote GitHub Actions.

## Final CI proof — exact implementation HEAD

- Workflow: **Modern UI Android CI**
- Run **#159**, run ID **`37756282193`**, job ID **`113241526239`**
- Implementation commit: **`422dbe0bfc5e4e353c3b1e5fa23a76afb44e064c`** (both run's checkout SHA and verified branch HEAD)
- Conclusion: **`completed / success`**
- Flutter: **3.22.3**
- Workflow full **`flutter test`**: **117 tests passed**
- **`flutter analyze lib/new_ui test/new_ui`**: **No issues found**
- **`flutter build apk --debug --flavor beta`**: **success**, output `build/app/outputs/flutter-apk/app-beta-debug.apk`
- Android package: **`top.apaipai.dsm_helper`**
- Fixed development signing certificate SHA-256: **`0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2`**
- Signed APK identity check: **success**, package and certificate match the expected fixed identity
- GitHub Artifact upload: **success**
- Artifact name: **`dsm-helper-modern-ui-android-debug`**
- Artifact ID: **`11539974995`**
- Artifact ZIP SHA-256: **`54d17cabcfa3178a06397de7790849d806dd2e0a2160f360d951c5db538ace24`**
- Workflow: https://github.com/qyxx2/dsm_helper/actions/runs/37756282193
- Artifact: https://github.com/qyxx2/dsm_helper/actions/runs/37756282193/artifacts/11539974995

The complete relationship test files under `test/new_ui/auth`, `test/new_ui/startup`, `test/new_ui/session`, `test/new_ui/app`, `test/new_ui/shell` and `test/new_ui/wiring` were included in the full passing `flutter test` workflow; this is **not** a claim that the narrower multi-directory command was run separately.

## Diff boundary

The GitHub compare from Batch 4 acceptance `208963a9dce1c320a4bd22d9d6dd8d4575f17887` to the final tested implementation SHA contains **exactly eight files**:

1. `lib/new_ui/app/dsm_new_ui_shell.dart` — account-management and logout hooks
2. `lib/new_ui/app/modern_ui_root.dart` — Modern Task 4 flow and theme
3. `lib/new_ui/app/new_ui_app_shell.dart` — “我的” action exposure
4. `lib/new_ui/shell/new_ui_primary_page.dart` — minimal account-management entry
5. `lib/new_ui/startup/modern_startup.dart` — exact reauth identity handoff
6. `lib/pages/setting/setting.dart` — narrow migrated-route callback interception; unrelated legacy Settings remain
7. `test/new_ui/auth/server_auth_relationship_test.dart` — cross-module/Drift and widget relationship proof
8. `test/new_ui/startup/modern_startup_test.dart` — startup regression proof

The legacy Login/SelectServer fallback code was not broadly rewritten because no additional reachable bypass from the migrated Task 4 root was confirmed. No unrelated production files or Android signing/Gradle configuration changed in this final accepted diff.

## Gate and handoff

**Batch 5 Exit Gate: PASS.** Automated Task 4 startup/reauth/context/shell relationship tests, full regression tests, targeted analysis and stable-identity APK verification are successful at one exact implementation SHA.

**Real Android/DSM verification was not performed or claimed for Batch 5.** Under the approved Batch Plan it belongs to **Batch 6**, including direct APK upgrade without uninstall, data retention, HTTP/HTTPS NAS login, certificate policy, default-account restore, management/delete behavior, offline vs 119, logout and OTP where available. No Task 4 whole-task acceptance, Master Plan Task 4 completion, PR or merge is authorized by this record.

This acceptance commit changes documentation only. Under `CI-DOCS-01`, documentation-only acceptance does not require rebuilding an identical APK; the verified implementation SHA above remains the authoritative test evidence.

**Stop at Batch 5. Do not automatically start Batch 6 or merge into `modern-ui`.**
