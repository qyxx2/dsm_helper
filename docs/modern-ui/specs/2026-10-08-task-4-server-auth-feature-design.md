# DSM Helper Modern UI — Task 4 Server / Account / Login / OTP Feature Design

> Status: Approved design, implementation not started  
> Date: 2026-10-08  
> Task: Task 4 — Server / Account / Login / OTP  
> Branch: `feature/t4-server-auth`  
> Integration branch: `modern-ui`  
> Architecture path: Thin Adapter / minimal migration

## 1. Purpose

Task 4 replaces the legacy server/account/login/OTP presentation with the Modern UI while preserving the existing DSM protocol, persistence model and mature legacy behavior wherever possible.

This Task is not an authentication or database rewrite. The implementation must prefer reuse of existing authorities and make legacy changes only for confirmed blockers, data-integrity defects, or wiring defects that prevent the approved Modern UI behavior.

## 2. Authoritative Inputs

Task 4 is governed by:

- `docs/modern-ui/2026-10-06-dsm-helper-modern-ui-master-plan.md`
- `docs/modern-ui/specs/2026-10-07-dsm-helper-modern-ui-spec.md`
- `docs/modern-ui/specs/2026-10-07-dsm-helper-modern-ui-visual-design.md`
- `docs/modern-ui/contracts/2026-10-07-global-interface-protocol-inventory.md`
- `docs/modern-ui/contracts/2026-10-07-global-contract-matrix.md`
- `docs/modern-ui/acceptance/2026-10-07-task-3-new-ui-shell-acceptance.md`
- current repository code on the Task 4 branch.

This document adds only Task 4 feature-level decisions and contracts. It does not redefine frozen global contracts.

## 3. Design Principle

The approved implementation approach is **Thin Adapter / minimal migration**.

Rules:

- Reuse current `Database`, `Servers`, `Accounts`, `Auth`, `DsmApi`, `ApiModel`, and Task 3 active-context infrastructure.
- New Task 4 UI belongs under `lib/new_ui/**`.
- Do not introduce a parallel auth/session authority.
- Do not introduce a new repository/service architecture only for structural cleanliness.
- Do not migrate the Drift schema.
- Do not redesign credential storage in Task 4.
- Do not rewrite legacy DSM API models.
- Do not enter Task 5 or later feature scope.
- Legacy production areas remain frozen except for confirmed Task 4 blockers and the minimum patch required to correct them.

Target control flow:

```text
Modern Server / Account / Login UI
        ↓
existing Database / Auth / DsmApi / ApiModel
        ↓
Task 3 ActiveContextCoordinator / DsmActiveContextAdapter
        ↓
Modern Shell / Overview
```

A successful login or account switch must not bypass Task 3 context activation by manually opening a bare shell.

## 4. Feature Scope

Task 4 covers:

- server/account selection;
- add server;
- edit server;
- account entry and switching;
- login;
- OTP / 2FA / email verification stage;
- saved-session activation;
- reauthentication;
- logout;
- account/server persistence behavior;
- default-account management;
- HTTP/HTTPS endpoint handling;
- self-signed HTTPS behavior through the existing certificate-check setting;
- Modern UI ↔ Task 3 shell/session handoff;
- required relationship tests;
- stable development APK signing before the next user-installed APK Gate.

## 5. Explicit Non-Goals

Task 4 does not:

- redesign the global Material 3 system frozen in Task 2;
- implement Task 5 Dashboard;
- rewrite the DSM SDK or transport architecture;
- migrate Drift schema;
- migrate plaintext legacy credentials to a new secure-storage architecture;
- add LAN discovery;
- add automatic NAS scanning;
- add endpoint migration logic;
- add certificate import/pinning management;
- make QuickConnect a Modern UI Task 4 path.

### QuickConnect boundary

The user does not use QuickConnect for this self-hosted DSM setup.

Therefore Task 4 Modern UI supports only ordinary HTTP/HTTPS domain/IP endpoints. Existing legacy QuickConnect code remains untouched unless a change is mechanically necessary to avoid breaking unrelated legacy fallback behavior.

QuickConnect has no Task 4 Modern UI entry, no Task 4 relationship-test requirement, and no Task 4 real-device acceptance requirement.

## 6. Legacy Authorities Confirmed by Audit

### 6.1 Persistence

Drift remains the source of truth:

- `Servers`
- `Accounts`
- shared `DbUtils.db`

Relevant persisted Server fields remain unchanged, including:

- `ssl`
- `domain`
- `port`
- `checkSsl`
- `remark`
- `hostname`

Relevant persisted Account fields remain unchanged, including:

- `serverId`
- `account`
- `password`
- `isDefault`
- `deviceId`
- `sid`
- `ikMessage`
- `synoToken`
- timestamps.

### 6.2 DSM transport and API discovery

- `DsmApi` remains the DSM request transport authority.
- `ApiModel.info()` remains the API discovery authority.
- `ApiModel.apiInfo` remains the current-context capability map.

### 6.3 Authentication

`Auth` remains the protocol authority:

- `Auth.login(account, password, optCode)`
- `Auth.logout()`
- `Auth.forget()`

Existing DSM auth/error semantics remain authoritative, including:

- 400: credential failure;
- 403: verification/OTP required;
- 404: verification code rejected;
- 414: email verification flow;
- 119 from session probe: authenticated session invalidation.

Ordinary connectivity failures are not authentication invalidation.

### 6.4 Active context

Task 3 remains the active-context authority:

- `ActiveContextCoordinator`
- `DsmActiveContextAdapter`
- `LegacySessionBridge`

Task 4 must reuse this path after login and when selecting an existing account.

## 7. Server / Account Product Semantics

### 7.1 Login-context card identity

One directly enterable device card represents exactly one:

```text
Server + Account
```

If one Server has multiple saved Accounts, Modern UI displays multiple login-context cards sharing the same server address but showing different users.

Each normal device card displays only:

- NAS/device name;
- address;
- user.

It must not contain legacy CPU, memory, storage gauges or DSM login-background artwork.

### 7.2 Card interaction

- Tap card body: enter that saved Server + Account context.
- Long press: open secondary management actions.
- No permanently visible per-card overflow control is required.

Secondary actions include, as applicable:

- edit Server;
- delete Account;
- delete Server;
- set as default;
- clear default.

Server actions remain server-scoped. Account actions remain account-scoped.

### 7.3 Zero-account Server

A persisted Server is allowed to exist without any Account rows.

This preserves the legacy persistence sequence where a validated endpoint may be saved before successful login.

A zero-account Server:

- is not a normal directly enterable `Server + Account` device card;
- is shown as an explicit unlogged/no-account management item;
- may add an account;
- may edit the Server;
- may delete the Server.

This prevents silent data loss and prevents existing orphan Server rows from becoming inaccessible.

### 7.4 Add Server

Modern UI add-server supports:

- HTTP;
- HTTPS;
- domain;
- IPv4;
- IPv6;
- explicit port.

Default ports remain:

- HTTP: 5000
- HTTPS: 5001

The endpoint is validated through the existing API discovery path before persistence.

After endpoint validation, the Server may be persisted before authentication, matching approved legacy timing.

### 7.5 Edit Server

Editing a Server may modify the existing server-scoped endpoint/configuration fields.

Rules:

- validate the edited endpoint before save;
- retain associated Accounts;
- do not proactively delete credentials;
- do not proactively clear every stored Account session solely because the endpoint was edited;
- the next actual activation determines whether the stored session remains valid;
- if DSM reports real authentication invalidation, reauthentication follows the normal Task 4 flow.

## 8. Default Account Semantics

The global cold-start contract is unchanged:

- exactly one default Account → attempt restore of that context;
- zero default Accounts → selection;
- more than one default Account is invalid state and must not be produced by Task 4.

Task 4 management behavior:

- long press on a saved account card may set it as default;
- the current default may be cleared;
- zero defaults is valid;
- setting one account as default must atomically clear all other default flags;
- new-account login retains the existing "set as default" choice.

The implementation must maintain the single-default invariant instead of performing isolated row writes that can create multiple defaults.

## 9. Login and Verification Flow

### 9.1 Stage 1 — credentials

Stage 1 contains only the necessary login inputs:

- account;
- password;
- set-as-default control;
- primary login action.

The existing `Auth.login()` call remains authoritative.

No Account row is created merely because Stage 1 began.

### 9.2 Stage 2 — OTP / email verification

The Modern UI uses a staged flow.

When the existing auth protocol reports verification requirements:

- 403 → enter verification stage;
- 404 → remain in verification stage and report rejected code;
- 414 → remain in verification stage and show the existing email-verification context when available.

Stage 2 rules:

- retain Stage 1 account/password state;
- allow return to Stage 1;
- send the entered code through `Auth.login(... optCode: code)`;
- do not create a second auth service;
- do not create an Account until final authentication succeeds.

### 9.3 New-account persistence

After successful final authentication:

- create a new Account only if that Server + username does not already exist;
- otherwise update the existing Account;
- persist the current returned session/token fields using the existing schema;
- update the password if the successful authentication used a new password;
- enforce default-account invariants;
- then enter the normal Task 3 active-context activation path.

Repeated retries must not create duplicate account rows.

## 10. Saved Account Activation and Reauthentication

When a user taps an existing Server + Account card:

1. bind the saved Server/account context through Task 3 active-context infrastructure;
2. discover APIs;
3. probe the saved session.

Result classification:

### Authenticated

Enter Modern Shell / Overview.

### Connectivity failure

Treat as connectivity/offline, not logout.

Where Task 3/global contracts permit safe shell entry from local state, enter the shell in offline/stale state.

Do not erase Server, Account, password, default state or session merely because the DSM is temporarily unreachable.

### Session invalidation

When DSM explicitly reports session invalidation, including the confirmed 119 path, enter reauthentication.

To preserve legacy behavior and minimize unnecessary prompts:

1. first reuse the persisted account/password to attempt `Auth.login()`;
2. if login succeeds, update the existing Account session and continue;
3. if OTP/email verification is required, enter Stage 2;
4. if credentials are rejected, show Stage 1 so the user can update them;
5. successful reauthentication updates the same Account row instead of inserting a duplicate.

## 11. Logout Semantics

Logout is distinct from deleting an Account.

Approved behavior:

1. attempt remote `Auth.logout()`;
2. if requested, preserve the existing `Auth.forget()` trusted-device option;
3. remote/network failure must not prevent local exit;
4. clear the local saved SID/session state that has been explicitly logged out;
5. preserve:
   - Server;
   - Account row;
   - username;
   - password;
   - default-account flag;
6. return to Server / Account selection.

If that Account remains the unique default account, a later cold start may select it, but it must reauthenticate rather than treating the explicitly logged-out SID as a valid saved session.

## 12. HTTP / HTTPS and Certificate Validation

Task 4 retains the existing per-Server `checkSsl` concept.

Confirmed current defect:

- `Server.checkSsl` is persisted and exposed by the legacy add/edit server page;
- the main `DsmApi` transport currently does not consume that Server setting;
- therefore the setting is not reliably applied to actual DSM requests.

Task 4 must make the minimum transport/context adaptation required so that the selected Server's certificate-validation setting governs its DSM transport.

Do not add:

- certificate store UI;
- custom CA import;
- certificate pinning;
- global TLS redesign.

## 13. Confirmed Legacy Blockers Allowed for Minimum Patch

The current audit confirms these Task 4 blockers:

### T4-BUG-01 — wrong account cleanup predicate

`Database.deleteAccountByServerId(int serverId)` currently filters by Account primary key instead of `accounts.serverId`.

Required correction:

```text
delete accounts where account.serverId == target Server.id
```

### T4-BUG-02 — saved-account OTP not forwarded

The legacy saved-account retry method accepts `otpCode` but calls `Auth.login()` without forwarding it.

Task 4 must not copy this bug. Any retained path that participates in Task 4 must correctly forward the code.

### T4-BUG-03 — Server.checkSsl disconnected from DsmApi

The persisted per-Server setting must be connected to the actual DSM transport with the smallest viable change.

### T4-BUG-04 — default-account invariant not enforced

Setting a default account must not leave another default row set.

### T4-BUG-05 — unconditional account insert

A successful login must not create duplicate rows for the same saved Server + username identity.

### T4-BUG-06 — logout leaves an explicitly invalid local SID

Local logout must clear the saved active session state while retaining the saved Account.

### T4-BUG-07 — login/switch bypasses Task 3 context activation

Successful Task 4 authentication/switching must hand off through Task 3 active-context authority rather than opening a bare shell directly.

Additional legacy production patches are allowed only when an executable test or current code demonstrates an equivalent Task 4 blocker. Unrelated cleanup is prohibited.

## 14. UI and Navigation Boundaries

Task 2 visual rules remain frozen.

Task 4 may decide feature-local composition only.

Required high-level flows:

```text
No saved Server
→ Add Server
→ Login Stage 1
→ optional Stage 2
→ Active Context activation
→ Overview
```

```text
Saved Server + Account
→ account card
→ saved-session activation
→ authenticated / offline shell
   OR
→ reauth
→ optional Stage 2
→ Active Context activation
→ Overview
```

```text
Zero-account Server
→ management item
→ Add Account
→ Login
```

```text
Current Account
→ Logout
→ Server / Account selection
```

The primary-page NAS label is not a new global account switcher. Device/account switching remains in the approved account/server management surface.

## 15. Relationship-Test Requirements

Task 4 must prove cross-module behavior through executable tests, not source-text wiring assertions.

Minimum relationship coverage:

### T4-REL-01 — account card → active context

Selecting a saved Account binds the intended:

- Server endpoint;
- deviceId;
- sid;
- context identity.

Old NAS/account capability state must not leak into the new context.

### T4-REL-02 — auth invalidation vs connectivity

- confirmed session invalidation → reauth;
- ordinary network/DNS/timeout/offline failure → connectivity/offline handling;
- connectivity failure alone must not erase auth persistence.

### T4-REL-03 — OTP forwarding

403/404/414 state transitions are correct and the final code is passed to `Auth.login(optCode: ...)`.

### T4-REL-04 — default invariant

- setting B default clears A;
- clearing B permits zero defaults;
- Task 4 cannot create multiple defaults.

### T4-REL-05 — Server delete cleanup

Deleting Server A removes only Accounts whose `serverId == A.id`.

Accounts belonging to another Server remain unchanged.

### T4-REL-06 — login persistence

- failed authentication creates no Account;
- incomplete OTP creates no Account;
- successful new login creates one Account;
- successful login for an existing Server + username updates that Account;
- retry does not duplicate it.

### T4-REL-07 — logout

Even when remote logout cannot complete:

- local exit succeeds;
- saved SID/session is cleared;
- Server/Account/default remain.

### T4-REL-08 — HTTPS certificate policy

The selected Server's `checkSsl` setting reaches the actual DSM transport behavior.

### T4-REL-09 — shell handoff

Successful login/switch goes through Task 3 active-context activation and does not bypass context preparation with a direct bare-shell push.

## 16. Stable Development APK Identity — APK-IDENTITY-01

Before the first Task 4 APK is provided for user installation, CI must stop generating a fresh signing key per run.

The beta/debug package identity remains:

```text
top.apaipai.dsm_helper
```

Required signing model:

- one stable development keystore/certificate for future user-facing Modern UI development APKs;
- private key is never committed to Git;
- development signing remains independent of the original production signing identity;
- GitHub Actions reconstructs the keystore from repository secret storage;
- the same development certificate is reused across subsequent Task/Batch APKs.

A one-time user-side GitHub Secret setup is expected. Exact Secret names and setup commands belong in the implementation plan before the signing batch executes.

## 17. Final Real-Device Gate

Task 4 cannot be marked complete on automated tests alone.

After CI passes, the real-device / real-DSM Gate must cover applicable paths:

- install the new APK directly over the previous Modern UI APK without uninstall;
- verify existing application data persists through the Android update;
- add/connect to a DSM using ordinary HTTP domain/IP;
- HTTPS connection;
- self-signed HTTPS behavior according to Server certificate-validation setting;
- login;
- OTP/2FA/email verification if available on the user's DSM;
- saved-account entry;
- unique-default cold-start restore;
- zero-default selection behavior;
- account switching;
- Server edit;
- Account delete;
- Server delete;
- logout;
- app restart persistence;
- session invalidation → reauth;
- temporary DSM/network unavailability does not incorrectly force Login.

QuickConnect is explicitly excluded from this Gate.

## 18. Design Approval Record

The following decisions were explicitly approved during Task 4 brainstorming:

1. zero-account Servers may persist and remain manageable;
2. QuickConnect may be ignored for Modern UI Task 4; ordinary HTTP/HTTPS domain/IP is the supported user path;
3. default account is managed from saved account/card secondary actions, with zero-default permitted;
4. logout preserves the saved Account/default state but clears the explicit logged-out local session;
5. implementation approach is Thin Adapter / minimal migration;
6. architecture authority remains existing Database/Auth/DsmApi plus Task 3 active-context infrastructure;
7. Server/Account management design approved;
8. Login/OTP/reauth/logout design approved;
9. endpoint/persistence/bugfix boundary approved;
10. UI flow, relationship tests, stable APK identity and real-device Gate approved.

The user also established the governing implementation preference:

> Keep Task 4 as simple as possible, preserve the original design and reuse existing logic/interfaces unless the legacy design contains an unavoidable or required bug fix.

## 19. Task 4 Feature Contract Matrix

These rows refine the frozen global contracts only where Task 4 owns feature-specific semantics.

| ID | Refines | Operation / trigger | Authority | Expected state delta | Must remain unchanged | Failure / rollback | Executable proof |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `T4-SRV-01` | `G-API-01`, `G-PERSIST-01` | Add/edit ordinary HTTP/HTTPS endpoint | `DsmApi`, `ApiModel.info`, `Servers` | Validated endpoint is saved; edit updates that Server | Accounts and unrelated Servers | Validation failure saves nothing | endpoint-form/controller tests |
| `T4-SRV-02` | `G-PERSIST-01` | Server exists with zero Accounts | `Servers` | Server remains manageable as no-account item | No synthetic Account is created | Missing/failed login leaves Server accessible | selector/store relationship test |
| `T4-ACC-01` | `G-PERSIST-01` | Render/select saved login context | joined `Server + Account` | One card maps to one exact context | Other account/server contexts | Missing joined row is not guessed | selector identity test |
| `T4-ACC-02` | `G-PERSIST-02` | Set/clear default Account | `Accounts.isDefault` | Set clears all others atomically; clear permits zero defaults | Account credentials/session | Transaction failure leaves previous flags intact | real DB transaction test |
| `T4-AUTH-01` | `G-AUTH-01` | New login / OTP / email verification | `Auth.login` | Final success creates or updates exactly one Account | No Account before final success | 400 stays credentials; 403/404/414 stay staged verification as defined | login flow tests incl. `optCode` capture |
| `T4-AUTH-02` | `G-AUTH-01`, `G-SESS-01` | Saved session invalidated with DSM 119 | session probe + persisted Account + `Auth.login` | Reauth updates the same Account session; optional Stage 2 | Server, account identity, default flag | Connectivity failure is not reauth; credential failure exposes Stage 1 | saved-account reauth relationship test |
| `T4-AUTH-03` | `G-AUTH-02` | Explicit logout | `Auth.logout`, optional `Auth.forget`, Account persistence | Local SID/session cleared; returns to selector | Server, Account, username/password, default flag | Remote/network logout failure does not block local exit | logout controller/store test |
| `T4-SESS-01` | `G-SESS-01`, `G-NAV-03` | Login/switch succeeds | Task 3 active-context coordinator | Correct context is activated before shell; old capability state cleared | No parallel session authority | activation failure does not open authenticated shell | shell-handoff relationship test |
| `T4-TLS-01` | `G-DSM-01` | Bind/probe Server with `checkSsl` | `Server.checkSsl` → `DsmApi` | Selected Server certificate policy reaches its DSM transport | Other Server policies | TLS failure remains connectivity/transport failure | adapter capture test + real self-signed DSM Gate |
| `T4-DEL-01` | `G-PERSIST-01` | Delete Server | Drift `Servers` / `Accounts.serverId` | Target Server and only its Accounts are removed | Other Servers/Accounts | Transaction failure must not perform partial cascade | real DB cascade test |

## 20. Planning Gate

Implementation has **not** started.

The next Superpowers step is:

1. user reviews and approves this written design;
2. then create the Task 4 Batch Execution Plan;
3. only after that plan is approved may implementation batches begin.

No Task 4 production-code implementation is authorized by this document alone.
