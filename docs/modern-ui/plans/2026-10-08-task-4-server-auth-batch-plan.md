# Task 4 Server / Account / Login / OTP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the legacy server/account/login/OTP presentation with Modern UI while preserving the existing DSM auth, persistence and active-context authorities, fixing only confirmed Task 4 blockers.

**Architecture:** Use a Thin Adapter approach. New UI and feature orchestration live under `lib/new_ui/**`; existing Drift tables, `Auth`, `DsmApi`, `ApiModel`, and Task 3 active-context infrastructure remain authoritative. Legacy production files are modified only for confirmed Task 4 blockers.

**Tech Stack:** Flutter 3.22.3, Dart, Material 3, Drift, Dio, existing Synology DSM models/APIs, GitHub Actions Android build.

**Spec:** `docs/modern-ui/specs/2026-10-08-task-4-server-auth-feature-design.md`

## Global Constraints

- Integration branch: `modern-ui`.
- Task branch: `feature/t4-server-auth`.
- GitHub is the only formal code source of truth.
- New Task 4 UI belongs under `lib/new_ui/**`.
- Reuse existing `Database`, `Servers`, `Accounts`, `Auth`, `DsmApi`, `ApiModel`, and Task 3 active-context code.
- No Drift schema migration.
- No credential-storage architecture rewrite.
- No QuickConnect Modern UI path or Task 4 QuickConnect acceptance requirement.
- Supported Modern UI endpoint forms: HTTP/HTTPS + domain/IPv4/IPv6 + explicit/default port.
- Default ports remain HTTP 5000 / HTTPS 5001.
- Only real DSM auth invalidation enters reauth; ordinary network failure remains connectivity/offline.
- Task 2 visual rules remain authoritative.
- Key cross-module behavior requires executable relationship tests.
- Pure docs-only changes do not require Android CI under `CI-DOCS-01`.
- Before the next user-installed APK, `APK-IDENTITY-01` must replace ephemeral CI signing with one stable development signing identity.
- Do not begin Task 5.

## Review Focus

1. Existing saved databases may contain zero-account Servers or multiple default Accounts; Task 4 must recover safely without inventing contexts.
2. Endpoint edit or temporary network failure must not silently delete saved accounts or misclassify connectivity as logout.
3. OTP retry must preserve credentials and actually forward `optCode`.
4. Logout must succeed locally even when DSM is unreachable while preserving Account/default state and invalidating the local SID.
5. Self-signed HTTPS must honor the selected Server's certificate-validation policy; do not rely on unrelated image-loader certificate overrides.

---

## Batch 0 — Stable Development APK Signing

**Contracts:** `APK-IDENTITY-01`

**Purpose:** Ensure all subsequent user-facing Task 4 APKs can directly replace the previously installed APK.

**Files:**
- Modify: `.github/workflows/android-ci.yml`
- Modify only if required by existing Gradle wiring: `android/app/build.gradle`
- Modify: `android/.gitignore` only if a new CI keystore filename needs explicit ignore coverage
- Test/verify: GitHub Actions workflow and Android package/signature output

**Interfaces:**
- Consumes: existing beta flavor `applicationId "top.apaipai.dsm_helper"`
- Produces: deterministic CI signing inputs reconstructed from GitHub repository secrets

- [ ] **Step 1: Write the signing acceptance check before workflow changes**

Document the exact expected CI properties in the Batch acceptance record:
- beta package remains `top.apaipai.dsm_helper`;
- no workflow step executes `keytool -genkeypair`;
- the keystore file is reconstructed from a repository secret;
- the same certificate fingerprint is reused across two subsequent workflow runs.

- [ ] **Step 2: Define the one-time secret contract**

Use these repository secret names:
- `MODERN_UI_DEV_KEYSTORE_B64`
- `MODERN_UI_DEV_STORE_PASSWORD`
- `MODERN_UI_DEV_KEY_ALIAS`
- `MODERN_UI_DEV_KEY_PASSWORD`

The keystore itself must never be committed.

- [ ] **Step 3: User performs one-time secret setup**

Provide exact local commands to:
1. generate one development keystore;
2. print its SHA-256 certificate fingerprint;
3. base64-encode the keystore;
4. add the four GitHub repository secrets.

Do not continue to a user-installable APK Gate until the user confirms these secrets exist.

- [ ] **Step 4: Replace ephemeral signing workflow**

Modify `.github/workflows/android-ci.yml` so it:
- decodes `MODERN_UI_DEV_KEYSTORE_B64` to an ignored Android keystore path;
- writes `android/key.properties` from the other three secrets;
- does not generate a new certificate.

- [ ] **Step 5: Run CI twice and compare certificate identity**

Expected:
- both runs pass tests/analyze/build;
- both APKs use `top.apaipai.dsm_helper`;
- both APKs report the same signing certificate SHA-256 fingerprint.

- [ ] **Step 6: Commit**

Commit only signing/workflow changes.

**Batch 0 Exit Gate**
- stable dev signing configured;
- certificate fingerprint recorded;
- two CI runs prove identical signing identity;
- no private key committed.

---

## Batch 1 — Persistence, TLS and Context Foundation

**Contracts:** `T4-ACC-02`, `T4-TLS-01`, `T4-DEL-01`, supports `T4-SESS-01`

**Purpose:** Fix the minimum persistence/transport blockers before any new login/account UI depends on them.

**Files:**
- Modify: `lib/database/tables.dart`
- Modify: `lib/utils/http_util.dart`
- Modify: `lib/apis/dsm_api/dsm_api.dart`
- Modify: `lib/new_ui/session/active_context_coordinator.dart`
- Modify: `lib/new_ui/session/dsm_active_context_adapter.dart`
- Modify: `lib/new_ui/startup/modern_startup.dart`
- Modify: `lib/new_ui/startup/legacy_startup_adapter.dart` if needed to carry Server TLS policy
- Create: `lib/new_ui/auth/server_account_store.dart`
- Test: `test/new_ui/auth/server_account_store_test.dart`
- Test: `test/new_ui/session/active_context_coordinator_test.dart`
- Test: `test/new_ui/session/dsm_active_context_adapter_test.dart`

**Interfaces:**
- Produce `ServerAccountStore` for Task 4 persistence mutations only.
- Extend `ActiveContextRequest` with the selected Server certificate-validation policy; exact field name: `checkSsl`.
- Extend `DsmApi` constructor with `bool checkSsl = true`.
- `DsmApi` must configure only its own Dio transport policy; do not make a new global TLS switch.

- [ ] **Step 1: Write failing DB relationship tests**

Cover:
- deleting Server A removes only Accounts where `serverId == A.id`;
- setting Account B default clears all others;
- clearing B allows zero defaults;
- a failed transaction does not leave partially changed defaults.

- [ ] **Step 2: Run focused tests and verify failure**

Run:
`flutter test test/new_ui/auth/server_account_store_test.dart`

Expected: FAIL because Task 4 store/mutations are not implemented and/or current delete predicate is wrong.

- [ ] **Step 3: Implement `ServerAccountStore`**

Minimal responsibilities:
- query Servers/Accounts for Task 4 presentation;
- atomically set/clear default account;
- delete one Account;
- delete one Server and its Accounts;
- update Account session fields;
- clear one Account session for logout.

Do not turn this into a general repository layer.

- [ ] **Step 4: Correct the confirmed legacy cascade bug**

Fix `deleteAccountByServerId(int serverId)` to filter on `accounts.serverId`.

- [ ] **Step 5: Write failing TLS propagation tests**

Assert:
- `ActiveContextRequest(checkSsl: false)` reaches the `DsmApi` construction/bind layer;
- `DsmApi(checkSsl: false)` allows bad certificates only for that instance;
- `DsmApi(checkSsl: true)` retains normal certificate validation.

- [ ] **Step 6: Implement per-Server TLS policy**

Add `checkSsl` to the active-context request and DSM transport initialization with minimal Dio adapter configuration.

Do not modify `ExtendedNetworkImageProvider.httpClient` behavior in `main.dart`; it is an image-loader concern, not DSM transport authority.

- [ ] **Step 7: Update startup context construction**

Ensure saved default-account startup carries the owning Server's `checkSsl` into `ActiveContextRequest`.

- [ ] **Step 8: Run focused and existing session/startup tests**

Run:
`flutter test test/new_ui/auth test/new_ui/session test/new_ui/startup`

Expected: PASS.

- [ ] **Step 9: Run targeted analyze**

Run:
`flutter analyze lib/new_ui lib/apis/dsm_api/dsm_api.dart lib/database/tables.dart lib/utils/http_util.dart`

Expected: no new issues.

- [ ] **Step 10: Commit**

Commit only Batch 1 files.

**Batch 1 Exit Gate**
- delete cascade proven;
- default invariant proven;
- per-Server TLS policy reaches DSM transport;
- existing Task 3 startup/session tests remain green.

---

## Batch 2 — Login / OTP / Reauthentication Controller

**Contracts:** `T4-AUTH-01`, `T4-AUTH-02`, supports `T4-SESS-01`

**Purpose:** Build the reusable staged auth logic before attaching it to the selector UI.

**Files:**
- Create: `lib/new_ui/auth/auth_flow_controller.dart`
- Create: `lib/new_ui/auth/login_page.dart`
- Create: `lib/new_ui/auth/verification_page.dart`
- Create: `lib/new_ui/auth/auth_flow_models.dart`
- Reuse: `lib/models/Syno/Api/auth.dart`
- Reuse: `lib/new_ui/auth/server_account_store.dart`
- Test: `test/new_ui/auth/auth_flow_controller_test.dart`
- Test: `test/new_ui/auth/login_page_test.dart`
- Test: `test/new_ui/auth/verification_page_test.dart`

**Interfaces:**
- Controller consumes Server plus optional existing Account.
- Controller calls the existing `Auth.login(account:, password:, optCode:)` through an injectable callback for testing.
- Controller produces explicit UI states: credentials, verification, authenticated, failure.
- Final authenticated result contains the persisted Account/context identity for later active-context activation.

- [ ] **Step 1: Write failing auth state-machine tests**

Cover:
- 400 remains credentials stage;
- 403 enters verification;
- 404 remains verification;
- 414 enters/remains verification with email context;
- verification retry forwards the entered `optCode`;
- no Account persistence occurs before final success;
- successful new login creates one Account;
- successful login for existing Server + username updates, not duplicates;
- saved Account 119 reauth first reuses stored account/password;
- saved credential rejection exposes Stage 1 with same account identity.

- [ ] **Step 2: Run controller tests and verify failure**

Run:
`flutter test test/new_ui/auth/auth_flow_controller_test.dart`

Expected: FAIL before implementation.

- [ ] **Step 3: Implement the minimal auth flow controller**

Do not duplicate `Auth` protocol logic. The controller owns only:
- stage transitions;
- retained credential values;
- persistence timing;
- update-vs-insert identity;
- success handoff payload.

- [ ] **Step 4: Write widget tests for Stage 1**

Assert:
- account/password fields;
- password visibility control;
- set-default control;
- full-width primary Login action;
- existing Account reauth pre-fills the account identity without creating a second account.

- [ ] **Step 5: Implement Modern Material 3 Login page**

Follow frozen Task 2 typography/spacing/component rules.

Do not use the DSM custom login background as the full-screen visual identity.

- [ ] **Step 6: Write and implement Stage 2 widget tests**

Assert:
- verification input;
- appropriate 403/404/414 messaging;
- back returns to Stage 1 without clearing account/password;
- retry uses the captured code.

- [ ] **Step 7: Run auth tests**

Run:
`flutter test test/new_ui/auth`

Expected: PASS.

- [ ] **Step 8: Run targeted analyze**

Run:
`flutter analyze lib/new_ui/auth test/new_ui/auth`

Expected: no issues.

- [ ] **Step 9: Commit**

Commit only Batch 2 files.

**Batch 2 Exit Gate**
- staged auth semantics executable;
- OTP forwarding proven;
- persistence timing/update-vs-insert proven;
- no UI shell handoff yet.

---

## Batch 3 — Add / Edit Server Modern UI

**Contracts:** `T4-SRV-01`, `T4-SRV-02`, `T4-TLS-01`

**Purpose:** Replace the legacy add/edit server page for the supported ordinary endpoint path.

**Files:**
- Create: `lib/new_ui/auth/server_form_controller.dart`
- Create: `lib/new_ui/auth/server_form_page.dart`
- Reuse: `ApiModel.info()`, `DsmApi`, `ServerAccountStore`
- Test: `test/new_ui/auth/server_form_controller_test.dart`
- Test: `test/new_ui/auth/server_form_page_test.dart`

**Interfaces:**
- Form input: scheme/HTTPS toggle, host, optional port, certificate-validation toggle, remark.
- Output: persisted validated `Server`.
- On new Server success, caller continues to Login Stage 1.
- On edit success, caller returns to management screen without deleting Accounts.

- [ ] **Step 1: Write failing endpoint parsing/default tests**

Cover:
- HTTP domain default 5000;
- HTTPS domain default 5001;
- explicit port wins;
- IPv4 accepted;
- bracketed IPv6 accepted;
- empty/invalid host rejected locally;
- no QuickConnect interpretation.

- [ ] **Step 2: Write failing validation/persistence tests**

Assert:
- `ApiModel.info`/probe success before save;
- failed probe does not save;
- edit failure leaves previous Server untouched;
- new validated Server may persist with zero Accounts;
- edit retains all associated Accounts.

- [ ] **Step 3: Implement server form controller**

Keep endpoint composition and validation in one focused class.

- [ ] **Step 4: Write and implement Material 3 form widget tests**

UI contains only the approved fields and one final primary action.

Do not add LAN discovery or QuickConnect controls.

- [ ] **Step 5: Run focused tests and analyze**

Run:
`flutter test test/new_ui/auth/server_form_controller_test.dart test/new_ui/auth/server_form_page_test.dart`

Run:
`flutter analyze lib/new_ui/auth/server_form_controller.dart lib/new_ui/auth/server_form_page.dart`

Expected: PASS / no issues.

- [ ] **Step 6: Commit**

Commit only Batch 3 files.

**Batch 3 Exit Gate**
- supported endpoint forms proven;
- zero-account Server behavior proven;
- edit preserves Accounts;
- no QuickConnect dependency.

---

## Batch 4 — Server / Account Selector, Default, Delete and Logout

**Contracts:** `T4-ACC-01`, `T4-ACC-02`, `T4-AUTH-03`, `T4-DEL-01`

**Purpose:** Deliver the complete Modern server/account management surface and explicit logout behavior.

**Files:**
- Create: `lib/new_ui/auth/server_account_page.dart`
- Create: `lib/new_ui/auth/server_account_controller.dart`
- Create: `lib/new_ui/auth/logout_controller.dart`
- Reuse: Batch 1 store, Batch 2 auth flow, Batch 3 server form
- Test: `test/new_ui/auth/server_account_controller_test.dart`
- Test: `test/new_ui/auth/server_account_page_test.dart`
- Test: `test/new_ui/auth/logout_controller_test.dart`

**Interfaces:**
- One normal card = one joined Server + Account.
- Zero-account Server = explicit non-enterable management item.
- Card tap returns/selects an exact saved context.
- Card long-press exposes only applicable secondary actions.

- [ ] **Step 1: Write failing selector identity tests**

Cover:
- one Server + two Accounts renders two normal context items;
- both show same address and different users;
- zero-account Server renders one no-account management item, not a fake Account card;
- card tap returns exact serverId/accountId pair.

- [ ] **Step 2: Write failing management mutation tests**

Cover:
- set/clear default;
- delete Account leaves Server;
- deleting last Account leaves zero-account Server;
- delete Server removes only its Accounts;
- edit Server action is server-scoped.

- [ ] **Step 3: Implement selector/controller and Material 3 cards**

Normal cards show only:
- device/NAS name;
- address;
- user;
- low-emphasis default indicator when applicable.

No legacy gauges or login artwork.

- [ ] **Step 4: Write failing logout tests**

Assert:
- attempts `Auth.logout`;
- optional forget path calls `Auth.forget`;
- remote/network failure still clears local SID and exits locally;
- Server, Account, password and default remain.

- [ ] **Step 5: Implement logout controller and confirmation UI hook**

Reuse existing `Auth.logout/forget`; do not create another remote logout protocol.

- [ ] **Step 6: Run auth-management tests**

Run:
`flutter test test/new_ui/auth`

Expected: PASS.

- [ ] **Step 7: Commit**

Commit only Batch 4 files.

**Batch 4 Exit Gate**
- full management surface works in widget/controller tests;
- default/delete/logout invariants proven.

---

## Batch 5 — Startup, Reauth and Shell Integration

**Contracts:** `T4-SESS-01`, `T4-AUTH-02`, plus all relationship contracts

**Purpose:** Replace Task 3's temporary legacy startup builders and remove Task 4 paths that bypass active-context activation.

**Files:**
- Modify: `lib/new_ui/app/modern_ui_root.dart`
- Modify: `lib/new_ui/startup/modern_startup.dart`
- Modify: `lib/new_ui/app/dsm_new_ui_shell.dart` only for the minimal account-management/logout entry hook
- Modify: `lib/new_ui/app/new_ui_app_shell.dart` or `new_ui_primary_page.dart` only if required for the approved “我的” account-management entry
- Modify legacy Task 4 pages only when needed to prevent stale alternate Task 4 wiring:
  - `lib/pages/server/select_server.dart`
  - `lib/pages/login/login.dart`
  - `lib/pages/setting/dialogs/logout_dialog.dart`
  - `lib/pages/setting/setting.dart`
- Test: `test/new_ui/auth/server_auth_relationship_test.dart`
- Modify: `test/new_ui/startup/modern_startup_test.dart`
- Modify: `test/new_ui/wiring/production_wiring_test.dart` only for behaviorally meaningful top-level entry assertions

**Interfaces:**
- `ModernUiRoot` uses Modern add-server and selector builders.
- Successful Login/Reauth/selection invokes Task 3 `DsmActiveContextAdapter.activate`.
- Authenticated/offline results enter `DsmNewUiShell` with the returned status/contextId.
- Reauth-needed routes to the Task 4 auth flow for the exact Account, not a generic selector fallback.

- [ ] **Step 1: Write failing end-to-end relationship tests**

Cover:
- cold start with no Server → Modern add-server page;
- launcher-selection enabled → Modern account selector;
- unique default valid SID → active-context activation → shell;
- unique default 119 → exact saved Account reauth flow;
- network failure → offline shell, not Login;
- successful new Login → persist → active-context activation → shell;
- account A → account B clears old capability state and enters B context;
- successful auth cannot open shell without activation.

- [ ] **Step 2: Replace temporary legacy startup builders**

Modify `ModernUiRoot` so Task 4 startup surfaces are Modern pages.

- [ ] **Step 3: Extend startup reauth handoff**

`ModernStartup` must preserve the exact Account/Server identity when activation returns `reauthNeeded`.

Do not degrade this to generic selection.

- [ ] **Step 4: Add the “我的” account-management entry**

Keep the rest of legacy Settings as fallback. Only replace the server/account switch/logout entry path needed by Task 4.

- [ ] **Step 5: Remove or neutralize obsolete bypass wiring**

Any retained legacy Login/SelectServer path that can still be reached from migrated Task 4 entry points must not push a bare `ModernUiShellEntry` after authentication.

Prefer routing migrated entry points to Task 4 controllers instead of broadly rewriting legacy pages.

- [ ] **Step 6: Run the complete relationship suite**

Run:
`flutter test test/new_ui/auth test/new_ui/session test/new_ui/startup test/new_ui/app test/new_ui/shell test/new_ui/wiring`

Expected: PASS.

- [ ] **Step 7: Run complete Flutter tests**

Run:
`flutter test`

Expected: all tests pass.

- [ ] **Step 8: Run targeted Modern UI analyze**

Run:
`flutter analyze lib/new_ui test/new_ui`

Expected: no issues.

- [ ] **Step 9: Push and verify Android CI**

Expected:
- dependency restore success;
- all Flutter tests pass;
- targeted analyze passes;
- beta debug APK builds with stable development signing;
- artifact uploaded.

- [ ] **Step 10: Commit**

Commit only integration/wiring/relationship-test changes.

**Batch 5 Exit Gate**
- all Task 4 automated contracts proven;
- no migrated Task 4 path bypasses active-context activation;
- CI APK exists under stable signing identity.

---

## Batch 6 — Real DSM Gate and Task Closure

**Contracts:** All Task 4 contracts + `APK-IDENTITY-01`

**Purpose:** Prove product behavior on the user's actual Android device and DSM, then close Task 4.

**Files:**
- Create after successful gate: `docs/modern-ui/acceptance/2026-10-08-task-4-server-auth-acceptance.md`
- Modify: `docs/modern-ui/2026-10-06-dsm-helper-modern-ui-master-plan.md`
- No production changes unless the Gate exposes a reproducible Task 4 blocker.

- [ ] **Step 1: Direct APK upgrade test**

Without uninstalling the currently installed Modern UI APK:
- install the Task 4 CI APK;
- verify Android accepts the update;
- verify previously persisted app data remains.

If signature mismatch requires uninstall, Batch 0 is not accepted.

- [ ] **Step 2: HTTP real DSM flow**

Verify:
- add/edit ordinary domain/IP endpoint;
- login;
- save Account;
- reopen saved Account;
- persistence after restart.

- [ ] **Step 3: HTTPS / self-signed real DSM flow**

Verify both certificate-policy settings according to the user's NAS certificate environment.

- [ ] **Step 4: Default-account flow**

Verify:
- set one default;
- restart → direct restore path;
- clear default;
- restart → selector.

- [ ] **Step 5: Account/server management**

Verify:
- multiple saved Accounts if available;
- delete Account leaves Server;
- zero-account Server can add Account again;
- edit Server retains Accounts;
- delete Server removes only that Server's Accounts.

- [ ] **Step 6: Reauth / offline distinction**

Verify:
- DSM temporarily unreachable does not force Login;
- explicit session invalidation or logout causes reauth rather than reuse of stale SID.

- [ ] **Step 7: OTP / 2FA Gate when available**

If the user's DSM can enable/provide OTP or email verification:
- verify Stage 2;
- wrong code stays Stage 2;
- correct code succeeds without re-entering Stage 1 credentials.

If unavailable, record as unexercised due environment rather than silently marking tested.

- [ ] **Step 8: Logout**

Verify:
- logout returns to selector;
- saved Account remains;
- default flag remains;
- next use reauthenticates rather than accepting the explicitly logged-out SID.

- [ ] **Step 9: Create acceptance record**

Record:
- final Task 4 HEAD;
- CI run number/ID/conclusion;
- APK artifact identity;
- signing certificate fingerprint;
- automated test results;
- each real-device Gate result;
- any explicitly unavailable OTP case.

- [ ] **Step 10: Update Master Plan**

Mark Task 4 complete only after all applicable Gate items pass.

- [ ] **Step 11: Final diff and remote commit verification**

Confirm documentation-only closure contains no accidental production changes.

- [ ] **Step 12: PR to `modern-ui`**

Create PR only after the Task 4 Gate passes. Re-check changed files and required CI before merge.

**Batch 6 Exit Gate**
- stable APK direct upgrade proven;
- ordinary HTTP/HTTPS DSM login proven;
- persistence/default/logout/reauth/account/server management proven;
- OTP proven where available or explicitly recorded unavailable;
- Task 4 acceptance record and Master Plan updated;
- PR ready for integration.

---

## Batch Dependency Order

```text
B0 Stable signing
 ↓
B1 Persistence + TLS + context foundation
 ↓
B2 Login / OTP / reauth controller
 ↓
B3 Add / edit Server
 ↓
B4 Server / Account management + logout
 ↓
B5 Startup / shell integration + relationship regression
 ↓
B6 Real DSM Gate + acceptance + PR
```

No later Batch may assume an earlier Batch is complete from chat history alone. Every new execution window must re-read the remote branch HEAD, this plan, the Task 4 Feature Design, and the relevant code/tests.

## Self-Review Result

- Spec coverage: all Task 4 design sections map to B0–B6.
- Contract coverage: every `T4-*` contract has at least one owning Batch and executable proof.
- Scope control: QuickConnect, schema migration, secure-storage rewrite and Task 5 remain excluded.
- Type/interface consistency: active-context TLS policy is introduced once in B1 and consumed by B3/B5.
- Review Focus coverage:
  - zero-account/multiple-default recovery → B1/B4;
  - endpoint/offline classification → B3/B5;
  - OTP forwarding → B2;
  - remote logout failure → B4;
  - self-signed HTTPS policy → B1 + B6.
- Proportion: plan fixes implementation decisions and verification gates without embedding full production method bodies.
