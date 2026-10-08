# Task 4 Batch 4 — Server / Account Selector, Default, Delete and Logout Acceptance

> **Status: PASS — Batch 4 automated Exit Gate**
> Date: 2026-10-08
> Task: Task 4 — Server / Account / Login / OTP
> Batch: 4 — Server / Account Selector, Default, Delete and Logout
> Branch: `feature/t4-server-auth`
> Previous Batch 3 acceptance commit: `a0594774c17adc638715fdf9607846d3c0a9cada`
> **Verified implementation HEAD: `8d5e16041135d811efd3d283460ccd321c0c429c`**

## Implemented contracts and boundaries

- **`T4-ACC-01`:** exact saved `Server + Account` pairs become individual enterable cards. Multiple accounts for one Server retain their own identities and share the Server endpoint. A zero-account Server is shown as an explicit non-enterable management item; no synthetic Account is persisted.
- **`T4-ACC-02`:** real SQLite/Drift transactions prove that setting a default clears all other defaults and clearing a default permits none. Stored passwords and sessions of other accounts remain untouched.
- **`T4-DEL-01`:** deletion of one Account leaves its Server and other Accounts intact. Deleting the last Account leaves a manageable zero-account Server. Deleting one Server removes only that Server and Accounts with the matching `serverId`.
- **`T4-AUTH-03`:** logout first attempts optional existing `Auth.forget()`, then existing `Auth.logout()`; a failed remote operation cannot skip local cleanup. The target Account's persisted `sid`, `synoToken` and `ikMessage` are cleared transactionally while the Server, Account row, username, password, trusted-device ID and default flag are preserved. A local-exit callback is invoked only after successful persistence. A reusable Material 3 confirmation hook exposes the optional forget choice and supports cancellation.

The standalone selector provides a server-scoped edit callback and account-scoped selection/add-account actions. Long-press secondary actions are limited to applicable saved identities. No Task 5 dashboard, new startup wiring, legacy UI rewrite, QuickConnect UI, schema migration or other Task change is included.

## RED → GREEN verification

1. Selector/management RED: `af0a14236b81fc9a19fcac7616012e064958a1b1`; CI **#147** / `37744729777` completed failure because `server_account_controller.dart` and `server_account_page.dart` did not exist. All **94** previously existing tests passed. This is valid expected missing-implementation RED evidence, not a test syntax failure.
2. Selector/management GREEN: `ad0c50dbea4466b5c3beb3f3d2ff91248784a13b`; CI **#148** / `37745979709` **completed / success**, **100 tests passed**, analyze clean, Android development APK built and verified.
3. Logout RED: `9f03145f5f236b203c886b5dd71a08a6d26b1076`; CI **#149** / `37747131827` completed failure specifically because `logout_controller.dart` did not exist; the **100** existing tests passed. Valid missing-implementation RED evidence.
4. Logout GREEN / final implementation: `8d5e16041135d811efd3d283460ccd321c0c429c`; CI **#150** / `37747377610` **completed / success**, **106 tests passed**.

These are distinct code commits. No unsuccessful, in-progress or cancelled workflow is counted as final GREEN evidence; no unchanged failed Job was rerun. Actual local Flutter/Dart tests were not run because that executable environment was unavailable in the current session. All reported test/build results come from GitHub Actions.

## Final CI proof — exact implementation HEAD

- Workflow: **Modern UI Android CI**
- Run: **#150** — Run ID **`37747377610`**, Job ID **`113211972011`**
- Implementation SHA: **`8d5e16041135d811efd3d283460ccd321c0c429c`**
- Final run: **`completed / success`**
- Locked Flutter: **3.22.3**
- Full `flutter test`: **106 passed, 0 failed** (includes the auth management, real Drift persistence, widget confirmation and prior relationship/regression tests)
- Workflow `flutter analyze lib/new_ui test/new_ui`: **No issues found**
- `flutter build apk --debug --flavor beta`: **success**
- APK package: **`top.apaipai.dsm_helper`**
- Stable development signing SHA-256: **`0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2`**
- Artifact upload: **success**
- Artifact name: **`dsm-helper-modern-ui-android-debug`**
- Artifact ID: **`11536671736`**
- Artifact ZIP digest: **`sha256:2ef7b1526a25b5fbed83457b7ec3ed61b50d29d02ecb5f5eb7990e8dc0f7c013`**
- Workflow URL: https://github.com/qyxx2/dsm_helper/actions/runs/37747377610
- Artifact URL: https://github.com/qyxx2/dsm_helper/actions/runs/37747377610/artifacts/11536671736

The Batch Plan's `flutter test test/new_ui/auth` test files are all included in the passing full `flutter test` workflow, rather than being claimed as a separate focused command run. The final CI also proves Android signing and artifact checks on the *same* implementation HEAD.

## Diff boundary and remaining limitations

Comparison from Batch 3 acceptance HEAD `a0594774c17adc638715fdf9607846d3c0a9cada` to final Batch 4 implementation HEAD contains **exactly seven files**:

1. `lib/new_ui/auth/server_account_controller.dart` — new standalone joined selector/controller
2. `lib/new_ui/auth/server_account_page.dart` — new Modern Material 3 cards and scoped management actions
3. `lib/new_ui/auth/logout_controller.dart` — new best-effort remote logout, local cleanup orchestration and reusable confirmation hook
4. `lib/new_ui/auth/server_account_store.dart` — minimum Account delete and local session-clear operations
5. `test/new_ui/auth/server_account_controller_test.dart`
6. `test/new_ui/auth/server_account_page_test.dart`
7. `test/new_ui/auth/logout_controller_test.dart`

No unrelated production code, frozen legacy interface or dependency was modified. This acceptance is docs-only, excluded from repetitive APK builds by `CI-DOCS-01`; the implementation SHA above remains the tested source of truth even though the acceptance commit advances the branch HEAD.

**Real-device Gate:** none independently required for this standalone Batch 4 implementation because Task 4's migrated startup, Shell selection and logout entry are not yet connected. Task 4 final Android/DSM real-device and APK overwrite Gate remains mandatory after its separately authorized integration work. Neither device verification nor Task 4 completion is claimed here.

**Batch 4 Exit Gate: PASS.** Its standalone management, default/delete and explicit logout invariants are verified. Stop here; do not implement Batch 5, merge to `modern-ui`, or begin another Task.
