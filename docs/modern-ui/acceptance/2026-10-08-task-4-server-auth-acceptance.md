# Task 4 — Server / Account / Login / OTP — Batch 6 Acceptance

> **Decision: PASS for the user's verified HTTP-only personal-use scope; explicitly NOT a claim of universal real-device coverage.**
>
> Date: 2026-10-08
> Task / Batch: Task 4 / Batch 6 — Real DSM Gate and Task Closure
> Branch: `feature/t4-server-auth`
> Last verified **implementation** SHA: `422dbe0bfc5e4e353c3b1e5fa23a76afb44e064c`
> Batch 5 acceptance SHA / Batch 6 entry HEAD: `70fc203bdbfae586296d4552a59b3e03e2d5df71`
> Acceptance authority: user-reported Android + real DSM observations in the Batch 6 conversation, plus independently read GitHub CI job logs.

## 1. Decision and applicability

The user explicitly uses an ordinary **HTTP LAN DSM endpoint** for this personal deployment and authorized omitting scenarios that do not affect that use and have no demonstrated dependency on future Task implementation. The approved Batch 6 decision is therefore **scope-limited acceptance**. This is a recorded, intentional departure from the plan's broader physical-device HTTPS requirement; it is **not** a retroactive assertion that HTTPS, multi-account, OTP or forced server-side SID invalidation were exercised.

No confirmed failure exists in the paths actually used. Unexercised scenarios remain visible as coverage gaps and do not alone block Task 5 or other unrelated future work. Should the user later enable HTTPS/self-signed certificates, two or more DSM accounts, OTP/2FA, or require proof of server-side SID revocation, the associated real-device verification must be performed **before claiming those scenarios accepted**. Automated tests do not upgrade unexercised real-device scenarios to PASS. No Task 4 production changes were required in Batch 6.

The approved specification, contracts and original broader Gate remain intact; this decision records an applicability exception limited to the current user environment.

## 2. User real-device / real-DSM Gate

| Batch 6 step | Observation and evidence type | Result |
| --- | --- | --- |
| 1 — Direct APK upgrade (`APK-IDENTITY-01`) | User installed two different stable-signed CI APKs over each other without uninstalling; saved app data and DSM login remained intact. Run #153 and #159 independently report the same package/signing fingerprint. | **PASS** |
| 2 — HTTP DSM add/edit/login/persistence | User confirmed server addition, ordinary HTTP login, saved-account use, edit retaining account, and state persistence after app restart. | **PASS** |
| 3 — HTTPS and self-signed TLS policies | User confirmed HTTPS is not used in this installation and declined this test. Transport-policy unit/relationship coverage exists from prior Batches; no real HTTPS result was observed. | **NOT TESTED — user-deferred, HTTP-only scope** |
| 4 — Default choice / cold start | User confirmed exactly-one-default automatic restore, clearing default then seeing selector, manual saved-account entry, and persistence on restart. | **PASS** |
| 5 — Server/account management | User confirmed edit, Account deletion, zero-Account Server, adding Account again, Server deletion and persistence across restart. A second DSM account is not available, so live two-Account switch/isolation was not exercised. | **PASS for tested single-account operations; multi-account NOT TESTED** |
| 6A — Connectivity/offline vs reauth | User confirmed offline cold start preserves the saved context and recovery after network restoration, without an inappropriate login prompt. | **PASS** |
| 6B — Actual server-side session invalidation (119) | No real DSM-side SID revocation was induced. The automated exact-account reauth relationship remains the supporting evidence, not physical-device proof. | **NOT TESTED — user-deferred** |
| 7 — OTP/2FA/email verification | Not used/tested by user. Existing Stage 2 behavior has automated verification, not physical DSM verification. | **NOT TESTED — user-deferred** |
| 8 — Logout | User observed logout returning to saved selection and, on tapping the same account, visiting credentials UI then automatically reauthenticating into the shell with stored credentials. This is consistent with the frozen contract. Local SID/session clearing, Account/default preservation and auth retry semantics are tested in code; the user did not inspect the raw SID value. | **PASS for the observable logout/reuse/reauth flow** |

All reported device behavior was provided by the user. There is no claim that the assistant directly operated the Android device, DSM, or packet-level server session.

**Unexercised scenarios are excluded from the scope-limited approval, not marked as tested/accepted.** There is no known technical blocker to following Tasks that reuse the verified HTTP account/session path; future consumers must not extrapolate this Gate to unverified HTTPS, multi-account, OTP or forced server-side invalidation.

## 3. Existing automated implementation Gate — CI #159

- Workflow: **Modern UI Android CI**; run **#159**, run ID `37756282193`; job ID `113241526239`.
- Workflow commit: `422dbe0bfc5e4e353c3b1e5fa23a76afb44e064c`.
- Conclusion: **completed / success**. GitHub job logs were read directly.
- Flutter **3.22.3**; `flutter test`: **117 tests passed**.
- `flutter analyze lib/new_ui test/new_ui`: **No issues found**.
- `flutter build apk --debug --flavor beta`: successful, output `build/app/outputs/flutter-apk/app-beta-debug.apk`.
- Package: **`top.apaipai.dsm_helper`**.
- Development signing certificate SHA-256: **`0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2`**.
- Artifact: `dsm-helper-modern-ui-android-debug`, ID **`11539974995`**, ZIP digest `sha256:54d17cabcfa3178a06397de7790849d806dd2e0a2160f360d951c5db538ace24`.
- Evidence: https://github.com/qyxx2/dsm_helper/actions/runs/37756282193
- Artifact: https://github.com/qyxx2/dsm_helper/actions/runs/37756282193/artifacts/11539974995

Run #153 (`37750270034`, implementation SHA `9cbd26e6c243ccbfc1861332ad92afea570edcb2`) independently produced the same package and signing certificate; the user tested coverage-preserving overlay installation between the #153 and #159 APKs. Both versions use app version `0.1.2+152`. The stable signing proof originates in Batch 0 acceptance and is retained unchanged.

The post-CI Batch 5 documentation commit `70fc203bdbfae586296d4552a59b3e03e2d5df71` has **no production/test changes** relative to #159. Under `CI-DOCS-01` its docs-only changes do not require a redundant APK build. This Batch 6 closure likewise changes documentation only.

## 4. Contracts, dependency and outstanding coverage

Already accepted automation from Batches 0–5 covers persistence, per-Server transport setting, staged login/OTP, no premature account persistence, atomic default mutation, server/account delete, explicit logout, exact-context reauth, offline classification and active-context shell handoff. Their RED→GREEN commits and CI runs remain recorded in their individual acceptance files; notably Batch 5's final visual-theme RED `fd9842e23854cd958636c5d0046209a1f06da19a` / CI #158 was fixed by GREEN `422dbe0bfc5e4e353c3b1e5fa23a76afb44e064c` / CI #159.

Relevant frozen contract families: `T4-SRV-01/02`, `T4-TLS-01`, `T4-ACC-01/02`, `T4-AUTH-01/02/03`, `T4-DEL-01`, `T4-SESS-01`, plus `APK-IDENTITY-01`. **Passing automation is not proof of the physical-device scenarios marked NOT TESTED above.**

This personal-use acceptance does not alter the agreed Auth/Drift/DsmApi authority, QuickConnect exclusion, frozen UI rules, or future Task scopes. It also does not authorize merging into `modern-ui` without a separate integration decision.

## 5. Scope and handoff

Batch 6 writes exactly two docs:
- this acceptance record;
- Task 4 current-status entry in `docs/modern-ui/2026-10-06-dsm-helper-modern-ui-master-plan.md`.

No production, tests, Gradle, workflow, signing keys, dependencies or non-Task-4 files may change in closure. The exact documentation commit(s) and any integration PR are verified after remote write.

**Gate decision:** **PASS — scoped to the user's verified HTTP-only, single-account personal deployment; the documented unexercised scenarios remain unverified.** No observed blocker to starting a later Task that depends only on the accepted behavior. Stop after Task 4 Batch 6 closure and PR preparation; do not merge or implement the next Task automatically.
