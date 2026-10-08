# Task 4 Batch 3 — Add / Edit Server Modern UI Acceptance

> **Status: PASS — automated Batch 3 Exit Gate**  
> Date: 2026-10-08  
> Task: Task 4 — Server / Account / Login / OTP  
> Batch: 3 — Add / Edit Server Modern UI  
> Branch: `feature/t4-server-auth`  
> Previous Batch acceptance HEAD: `da0fc7d09e4ca211a247aa5b2b77c23a4b816b59`  
> **Verified implementation HEAD:** `77d42a0ae2cf8ad3b7c41bf0e4164a5ce1e989b2`

## Scope, contracts and evidence

This Batch implements only the standalone add/edit Server Controller and Material 3 form, **not** the later selector or application startup/navigation wiring.

- **`T4-SRV-01`:** parse ordinary HTTP/HTTPS domain, IPv4, bracketed IPv6 and single-label LAN hosts; default HTTP/HTTPS ports 5000/5001, with an explicit valid port taking precedence. Reject malformed endpoints/ports locally. Probe DSM API discovery **before** adding/updating a Server; failed or empty discovery does not persist changes.
- **`T4-SRV-02`:** allow a validated Server without Accounts; add flow returns the saved Server for a later login handoff without synthesizing an Account.
- **`T4-SRV-01` / persistence relationship:** editing updates the same Server row only after a successful probe, preserves existing Accounts, credentials, SID and default flags; failed edits leave the persisted state unchanged.
- **`T4-TLS-01`:** the candidate endpoint probe receives the selected `checkSsl` policy via a per-probe `DsmApi`. The candidate does not replace the current global `Api.dsm`; the existing `ApiModel.info()` API continues to work with its default argument.
- **UI:** one Material 3 form contains HTTPS, host, optional port, SSL certificate check and remark, plus one final primary action. No QuickConnect or LAN discovery entry is added.

Controller persistence tests use real in-memory Drift/SQLite. Widget interaction tests use a deterministic form-controller substitute, with database/transaction behavior retained in the separate Controller tests. The new form remains an isolated component until later Task 4 integration.

## RED → GREEN and diagnosis

1. **Controller RED:** `cae085c6d4e228a0d0dd1274d65779bd578651cf`; CI **#139** (`37738347866`) failed because `server_form_controller.dart` was not yet present; 80 previously existing tests passed.
2. **Controller implementation:** `3f68d6afcd68b6f2d75486c8c2379d94741fbadb`; CI **#140** (`37738678099`) exposed the missing optional `client` argument on `ApiModel.info()`. Corrected by `fb0c58f4d8168676a8c4ae7748f4b71ec3fcfb9f`. CI **#141** (`37738717294`) showed **11 Controller tests passed**, but full workflow failed at static analysis because of one unused import.
3. **Widget RED:** initial tests `49066452cc796b2e762b11119dbc67290a3cf28a` were syntactically corrected by `3aa6e62e82fb8e50e0609b238ebf58f317ecc705`. CI **#143** (`37738781470`) confirmed expected failure due to absent `server_form_page.dart`, with 91 other tests passing. CI **#142** had included test fixture syntax errors and is **not** counted as valid RED evidence.
4. **Widget implementation:** `47bd6845ea292145f384ab26d494c3171709c4b1`. The unused Controller import was removed by `f1c78503e5441720342e6608f1f42d8968eaba3f`. CI **#144** (`37739715408`) and **#145** (`37739728164`) each reported 91 passed / 3 timed-out Widget tests; these runs are **not** GREEN proof.
5. **Widget test-isolation correction:** `77d42a0ae2cf8ad3b7c41bf0e4164a5ce1e989b2` removes asynchronous Drift operations from the Flutter fake-async Widget test scope, without removing the Controller's actual database tests. **Final GREEN CI #146** (`37743080537`) is `completed / success` on this exact implementation SHA.

No failed/cancelled/intermediate CI run is used as final acceptance evidence. No repeated run of an unchanged failed Job was required.

## Final automated verification — same implementation SHA

- Workflow: **Modern UI Android CI**
- Run number: **#146**
- Run ID: **`37743080537`**
- Job ID: **`113198103147`**
- Implementation SHA: **`77d42a0ae2cf8ad3b7c41bf0e4164a5ce1e989b2`**
- Conclusion: **`completed / success`**
- Flutter: **3.22.3**
- Full `flutter test`: **94 passed, 0 failed**
- `flutter analyze lib/new_ui test/new_ui`: **No issues found**
- `flutter build apk --debug --flavor beta`: **success**
- Android package ID: **`top.apaipai.dsm_helper`**
- Stable development-signing certificate SHA-256: **`0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2`**
- APK artifact upload: **success**

Artifact:

- Name: `dsm-helper-modern-ui-android-debug`
- ID: `11534627514`
- Digest (artifact ZIP): `sha256:45ad488b9fbcc022d76cb9bc3eae82c7d39f0f4e629c70d31bab5f32e0fe0a2c`
- URL: https://github.com/qyxx2/dsm_helper/actions/runs/37743080537/artifacts/11534627514
- Workflow: https://github.com/qyxx2/dsm_helper/actions/runs/37743080537

The full suite contains the two new Batch 3 test files; the workflow also covers prior Task 3/Task 4 relationship and regression tests. CI provides the actual execution evidence; no separate local Flutter/Android test execution is claimed.

## Final diff boundary

Against Batch 2 acceptance `da0fc7d09e4ca211a247aa5b2b77c23a4b816b59`, exactly these **five implementation/test files** changed:

- `lib/new_ui/auth/server_form_controller.dart` — added
- `lib/new_ui/auth/server_form_page.dart` — added
- `test/new_ui/auth/server_form_controller_test.dart` — added
- `test/new_ui/auth/server_form_page_test.dart` — added
- `lib/models/api_model.dart` — minimal, backward-compatible optional probe client argument to isolate candidate DSM discovery from the active global client

No Drift schema migration, legacy page change, dependency upgrade, QuickConnect UI, Task 4 Batch 4 selector/logout work, Batch 5 shell startup wiring, unrelated Task, or integration-branch merge is included.

## Batch 3 Exit Gate and remaining limits

**PASS — Batch 3 automated Exit Gate:**

- [x] Ordinary supported endpoint forms covered by executable tests.
- [x] Invalid input and failed/empty API discovery never persist a new or edited Server.
- [x] Validated Server can exist with zero Accounts.
- [x] Editing preserves the same Server identity and associated Accounts/session/default state.
- [x] Selected HTTPS certificate-check policy reaches the isolated probe.
- [x] No QuickConnect dependency introduced.
- [x] Final full Flutter test, Modern UI analysis, beta APK build, stable package/signature checks and artifact upload passed on the same implementation SHA.
- [x] Implemented and tested only the frozen Batch 3 scope.

**Real-device Gate:** not independently required for Batch 3 because the form has not been wired into the active user path. Real DSM HTTP/HTTPS, self-signed certificate behavior, APK cover-install, navigation/login integration and related scenarios remain mandatory at the **final Task 4** device gate, after the later integration Batch. No real-device verification is claimed here.

**Stop boundary:** Batch 3 acceptance ends this window. Do not implement Batch 4 or later, merge to `modern-ui`, or mark the entire Task 4 complete. Batch 4 may be considered only in a separately authorized window using the real repository state.
