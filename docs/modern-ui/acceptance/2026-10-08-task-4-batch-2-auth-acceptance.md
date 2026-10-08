# Task 4 Batch 2 — Login / OTP / Reauthentication Controller Acceptance

> Status: PASS  
> Date: 2026-10-08  
> Task: Task 4 — Server / Account / Login / OTP  
> Batch: 2 — Login / OTP / Reauthentication Controller  
> Branch: `feature/t4-server-auth`  
> Verified implementation HEAD: `b4fd1c418069f045c7babf1e7e9a4ac6d8095013`

## Scope and frozen contracts

- `T4-AUTH-01`: stage 1 credential login, stage 2 OTP/email verification, final-success-only persistence, and authenticated Account handoff.
- `T4-AUTH-02`: saved-account reauthentication, including stored-credential first attempt and same Account identity on success.
- Supports `T4-SESS-01`: exposes persisted authenticated Account for a later active-context activation; **no shell activation or selector integration in Batch 2**.

Reuses the existing `Auth.login(account:, password:, optCode:)` protocol and the Batch 1 `ServerAccountStore`. Does not implement a second login protocol or change the database schema.

## TDD evidence

### Controller RED → GREEN

- RED commit: `0f3bd28d900a2273f88a94d4c4c37602f0ada9c5`.
- Expected failure: GitHub Actions #131, run ID `37720120258` (missing staged-controller implementation).
- GREEN commit: `7d97476d992458ba6b4d98672743942290a5952c`.
- GitHub Actions #132, run ID `37720402177`: `success`.

Controller tests cover DSM errors 400/403/404/414, OTP code forwarding, no premature Account persistence, new-account creation, update rather than duplicate for an existing Server + username, saved-account first-use of persisted credentials, and saved-credential rejection returning to Stage 1 with the same identity.

### Widget RED → corrective GREEN

- Widget RED commit: `0287d3e2266bf810610306d438047c308e5856dd`.
- GitHub Actions #133, run ID `37721910573`: expected missing-widget failure.
- Initial widget implementation: `c9e61ca75522316f7bb273e64b006e187e210bfd`.
- Runs #134 (`37721974950`) and #135 (`37722018263`) did not provide GREEN proof. Logs showed `pumpAndSettle timed out` in `login_page_test.dart`, followed by cancellation.
- Test-isolation correction: `8be1d3ce6af29ada16e52fff3519fee5a9ea6299`. Widget tests now use a small, test-only, in-memory `FakeServerAccountStore`; Controller tests retain real Drift/SQLite transaction and persistence coverage.
- Run #136 (`37734551207`) exposed an invalid Flutter 3.22.3 `pumpAndSettle(timeout: ...)` named argument introduced in that correction.
- Corrective commits: `c7a147e7f69efb930f79526f437bc8cf667f0743` and `b4fd1c418069f045c7babf1e7e9a4ac6d8095013`, removing all seven unsupported argument usages. Run #137 (`37734867626`) was an intermediate failure before the second file was corrected.
- Final GREEN: run #138 (`37734875367`), on verified HEAD `b4fd1c418069f045c7babf1e7e9a4ac6d8095013`, `completed / success`.

The final full test suite includes the stage 1 account/password/password-visibility/default/submit/re-authentication widget tests and stage 2 OTP, retry, email-context, and return-to-credentials tests. These widget tests exercise the real controller with injected login callback and deterministic persistence substitute; transaction details remain verified separately in Controller tests.

## Final automated verification

Workflow: `Modern UI Android CI`  
Run number: **#138**  
Run ID: **`37734875367`**  
Job ID: **`113172027303`**  
Implementation HEAD: **`b4fd1c418069f045c7babf1e7e9a4ac6d8095013`**  
Conclusion: **`completed / success`**

- [x] Stable development signing key restored.
- [x] Dependencies resolved with Flutter 3.22.3.
- [x] Full `flutter test`: **80 tests passed**.
- [x] `flutter analyze lib/new_ui test/new_ui`: **No issues found** (covers Batch 2's `lib/new_ui/auth` and `test/new_ui/auth` paths).
- [x] `flutter build apk --debug --flavor beta`: success.
- [x] APK package name: `top.apaipai.dsm_helper`.
- [x] APK signing certificate SHA-256: `0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2`.
- [x] Development APK artifact uploaded.

Artifact:

- Name: `dsm-helper-modern-ui-android-debug`
- ID: `11531517300`
- Digest: `sha256:4798325d7894be5455f4c22df9d398ce90d39c4a9c9db059864a378acc4fdb04`
- URL: https://github.com/qyxx2/dsm_helper/actions/runs/37734875367/artifacts/11531517300

A separate local Flutter run was not available in the agent container. This acceptance relies on the complete recorded GitHub Actions #138 execution, not an inferred local test result. No real-device Batch 2 verification is claimed.

## Diff and change boundary

Compared with Batch 1 acceptance commit `3f9d2758abf9fe160115bb386955523f9d17127e`, the verified implementation HEAD adds/modifies only:

- `lib/new_ui/auth/auth_flow_controller.dart`
- `lib/new_ui/auth/auth_flow_models.dart`
- `lib/new_ui/auth/login_page.dart`
- `lib/new_ui/auth/verification_page.dart`
- `lib/new_ui/auth/server_account_store.dart`
- `test/new_ui/auth/auth_flow_controller_test.dart`
- `test/new_ui/auth/login_page_test.dart`
- `test/new_ui/auth/verification_page_test.dart`
- `test/new_ui/auth/support/fake_server_account_store.dart`

No Task 4 Batch 3 Server Add/Edit work, QuickConnect support, schema migration, shell/selector wiring, or unrelated production code was added.

## Batch 2 Exit Gate

**PASS**

- Staged auth state transitions and error classifications are executable.
- OTP verification forwards the entered `optCode`.
- Persistence only after final success, correct update-vs-insert account identity, and saved-account reauthentication are proven by Controller tests using real Drift storage.
- Stage 1 and Stage 2 UI interactions are verified by Widget tests.
- Full tests, analyze, APK build, package identity, stable signing, and artifact upload succeeded on the same implementation HEAD.
- Authentication success is exposed as a persisted Account for later integration; **Batch 2 does not perform UI shell handoff**.

**Window boundary:** Stop after acceptance. Do not start Task 4 Batch 3, merge to `modern-ui`, or implement later integration work in this window.
