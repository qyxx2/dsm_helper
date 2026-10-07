# DSM Helper Modern UI — Global Interface / Protocol Inventory

> Task: Task 1 — Project Specification + Legacy Interface / Protocol Freeze  
> Date: 2026-10-07  
> Branch audited: `feature/t1-spec-contracts`  
> Audit baseline HEAD: `0cbbaf4921ffd08fec13bb6ff9f096f026f32c2d`  
> Integration base: `modern-ui@fb5132b46b26c0411670425206e76ca1d1670629`

## 1. Purpose and boundary

This inventory records the real legacy capabilities that the Modern UI may depend on. It freezes capability and authority boundaries, not accidental private method names or legacy presentation structure.

Classification:

- **Direct reuse** — the existing public capability is already a usable authority.
- **Minimal adapter** — the underlying authority is reusable, but New UI needs a small orchestration/state boundary around it.
- **Feature-specific audit required** — the capability exists, but exact operation semantics belong to the later feature task.
- **Real blocker** — no safe legacy/public path exists for an already-approved global product requirement.
- **Legacy-only presentation** — implementation is a presentation detail and must not become a New UI dependency.

Old code size, style, or architecture alone is not a rewrite reason.

## 2. Evidence scope actually inspected

The audit inspected the current Task 1 branch and relevant implementation under:

- `lib/apis/**` — all 6 files.
- `lib/models/**` — the complete model tree was enumerated; all model source files were read for public async/API capabilities, with the global and cross-feature models inspected in detail.
- `lib/providers/**` — all 9 providers.
- `lib/database/**` — schema/extension authority plus generated Drift output boundary.
- login/auth/session, server/account selection, splash/startup, Home/navigation, Dashboard/resource/status, notifications, File Station/transfer, Applications, settings/theme and Android manifest/platform integration.
- Android `MainActivity` and intent filters.

The generated `lib/database/tables.g.dart` is not treated as an independent contract authority; `tables.dart` is the schema/source authority.

## 3. DSM transport and API discovery

| Capability | Legacy authority / evidence | Disposition | Frozen boundary |
|---|---|---|---|
| DSM single request | `lib/apis/dsm_api/dsm_api.dart::DsmApi.entry` | Direct reuse + Minimal adapter for state classification | Uses `/webapi/entry.cgi`, injects `api`, `method`, version and `_sid`; success parses `DsmResponse`; DSM error throws `DsmException`. New UI must not create a second DSM transport authority. |
| DSM batch request | `DsmApi.batch`, `BaseModel` | Feature-specific audit required | Existing compound request support is reusable. Top-level failure currently collapses to an empty result and per-member failure handling is weak; a later feature that relies on batch must prove its failure mapping instead of assuming single-request semantics. |
| DSM stream | `DsmApi.stream` | Direct reuse | Returns the Dio response stream using the same base URL/session transport. Feature-specific consumers own stream lifecycle/error semantics. |
| Raw HTTP utilities | `lib/utils/http_util.dart` inherited by `DsmApi` | Direct reuse inside existing authority | GET/POST/PUT/DELETE and headers are transport implementation. New UI should call the DSM/model capability rather than invent a competing HTTP client. |
| API discovery/version | `lib/models/api_model.dart::ApiModel.info`, `ApiModel.apiInfo` | Direct reuse + Minimal adapter | `SYNO.API.Info` discovers max/min versions; `DsmApi.entry` defaults to discovered version. Active DSM context setup must populate discovery before APIs that depend on it. |
| Response/error envelope | `DsmResponse`, `DsmException` | Direct reuse | DSM protocol errors stay distinct from Dio/network failures. Code 119 is the observed legacy authentication/session-invalid signal. |
| Encryption helper | `dsm_encrypt.dart` | Legacy-only / no capability | Empty class; it is not a usable contract and must not be cited as an encryption authority. |

### Transport technical notes

1. `DsmApi` stores `baseUrl`, `deviceId`, and `sid` and initializes the Dio instance with those values.
2. Request headers also carry `did` and `sid`; DSM entry requests additionally carry `_sid`.
3. Network failures surface through Dio rather than `DsmException`; this supports the approved separation between connectivity failure and authentication invalidation.
4. `DsmApi.batch` needs feature-level hardening before any feature treats an empty list as a successful empty data set. This is **not** a Task 2/3 blocker.

## 4. Authentication, OTP, logout and session

| Capability | Legacy authority / evidence | Disposition | Frozen boundary |
|---|---|---|---|
| Login | `lib/models/Syno/Api/auth.dart::Auth.login` | Direct reuse | `SYNO.API.Auth/login`, session `webui`, device token and sync token enabled, remember-me enabled. |
| OTP / 2FA / email verification input | `Auth.login(... optCode)`; `login.dart` handles 403/404/414 | Direct reuse protocol; New UI presentation replaces legacy dialog | The underlying Auth capability already accepts an OTP code. 403/404/414 remain distinct staged-auth outcomes. |
| Logout | `Auth.logout` | Direct reuse | Calls `SYNO.API.Auth/logout`. Logout is explicit user action; network failure is not logout. |
| Forget trusted device | `Auth.forget` | Direct reuse | Calls `SYNO.Core.TrustDevice/delete`. |
| Session validity probe used by legacy selection | `NormalUser.get` and error 119 handling in `select_server.dart` | Minimal adapter | A successful authenticated API call can confirm the session; 119 means reauthentication. A network error must not be reclassified as 119. |
| Login-page DSM identity data | `SessionDataModel`, raw `SYNO.Core.Desktop.SessionData` query in `login.dart` | Feature-specific audit required | Hostname/welcome/logo are reusable data; DSM login background is presentation and is not a New UI visual authority. |
| Saved-account OTP retry controller | `select_server.dart::login` | Feature-specific defect | The controller accepts `otpCode` but does not forward it to `Auth.login`. Underlying protocol support is intact, so Task 4 must not reuse this controller behavior as authority. |

## 5. Server/account persistence and active context

### 5.1 Persistence authority

`lib/database/tables.dart` is the authority:

- `Servers`: id, groupId, SSL, QCID, domain, port, certificate-check flag, remark, MAC, hostname/background metadata.
- `Accounts`: id, `serverId`, account, password, creation/login time, `isDefault`, deviceId, sid, ikMessage and synoToken.
- `table_extension.dart` defines the canonical legacy server URL from scheme/domain/port.
- `DbUtils.db` exposes the shared Drift database.

Disposition: **Direct reuse** for stored data + **Minimal adapter** for active-context orchestration.

### 5.2 Approved Task 1 account identity decision

The Modern UI device-card identity is:

`Server + Account`

A server with multiple saved accounts produces one directly-enterable device card per saved account. A device card is therefore a login context, not merely a physical NAS record.

Server edit/delete remains server-scoped; account actions remain account-scoped.

### 5.3 Approved Task 1 cold-start default decision

When “启动时选择服务器/账号” is disabled:

- exactly one saved `Account.isDefault == true` → that `Server + Account` is the automatic restore candidate;
- no default account → open server/account selection;
- more than one default account → ambiguity is not guessed; open server/account selection.

Task 4 must make “set default account” maintain the single-default invariant. Task 1 does not modify the database to enforce it.

### 5.4 Existing startup implementation

`Splash.queryServers` currently sends users to server selection and does not implement the approved default-account restore path. The required data and public DSM operations already exist, so this is **Minimal adapter**, not a backend rewrite blocker.

### 5.5 Persistence defect to carry forward

`Database.deleteAccountByServerId` currently filters `accounts.id == serverId` instead of `accounts.serverId == serverId`. This is a real legacy defect in server-deletion cleanup, but it is **Feature-specific audit required for Task 4**, not a Task 2/3 blocker. Task 1 does not patch it.

## 6. QuickConnect / server discovery

`lib/models/synology/qcid_model.dart` exposes QuickConnect resolution and ping/pong probing. `AddServer` composes that with `DsmApi` and `ApiModel.info`.

Disposition: **Feature-specific audit required**.

The capability exists and may be reused in Task 4. Its controller/UI flow is not a global Task 1 contract.

## 7. Shared providers and global/page state

All current providers were inspected:

- `DarkModeProvider`
- `SettingProvider`
- `InitDataProvider`
- `SystemInfoProvider`
- `UtilizationProvider`
- `StorageProvider`
- `ExternalDeviceProvider`
- `BackgroundTaskProvider`
- `AudioPlayerProvider`

Disposition:

- settings/persistence-backed values: **Direct reuse where semantics match**;
- DSM data providers: **Feature-specific audit required**;
- New UI stale/loading/error classification: **Minimal adapter/state layer required**.

The current DSM data providers generally hold the latest model value only; they do not encode “last valid + refreshing + stale + failure” as required by the approved spec. New UI may add presentation/state metadata, but it must not create a second DSM backend authority.

## 8. Dashboard / resource / status sources

Real reusable sources include:

- `InitDataModel.get` → `SYNO.Core.Desktop.Initdata`
- `System.info` / batch construction → `SYNO.Core.System`
- `Utilization.get` → `SYNO.Core.System.Utilization`
- `Storage.loadInfo` → `SYNO.Storage.CGI.Storage/load_info`
- external USB/eSATA models and batch requests
- existing task scheduler/log/current-connection models where the later Dashboard scope needs them.

`dashboard.dart` polls utilization using the persisted refresh-duration setting and polls several other sources on fixed legacy periods.

Disposition: models/protocol **Direct reuse**; Dashboard polling/composition **Feature-specific audit required**.

The exact New UI grouping, retry/stale presentation, and which source belongs on Overview are Task 5 concerns.

## 9. DSM notifications

Authority:

- `DsmNotify.notify` → `SYNO.Core.DSMNotify/notify` with load action.
- `DsmNotify.clean` → same API with apply/clean-all.
- `DsmNotifyStrings.get` → localized DSM notification strings.
- legacy Dashboard exposes the notification entry and refreshes notifications.

Disposition: **Direct reuse** for notification data/protocol; **Minimal adapter** for shell-global entry and lifecycle.

The global New UI notification entry must not depend on the legacy Dashboard widget being mounted.

## 10. Applications discovery and ordering

Authority:

- DSM desktop application order originates from `InitDataModel.userSettings.desktop.validAppviewOrder`, falling back to `appviewOrder`.
- `ApplicationEnum` is the legacy mapping from DSM package/application IDs to locally supported app destinations.
- `Applications` filters DSM order to supported mappings.

Disposition: **Feature-specific audit required**.

The DSM order is reusable data. The legacy grid, button styling and route widget presentation are **Legacy-only presentation**. Task 6 determines Common/All grouping and route mapping without redefining the global shell.

## 11. File Station and transfer common entry points

Reusable File Station protocol/model capabilities include:

- share/root/file/favorite/virtual-folder listing;
- create folder, rename, delete, compress/extract;
- favorite operations;
- directory size and MD5 tasks;
- sharing;
- background-task list/status/cancel;
- DSM download URLs derived from active `DsmApi.baseUrl/sid`.

Transfer infrastructure includes:

- `background_downloader` `FileDownloader`;
- SQLite persistent downloader storage initialized from `Splash`;
- `DownloadFileEvent` bus from File Station into `DownloadTab`;
- downloader status/progress records and Android notifications.

Disposition: **Feature-specific audit required** for Tasks 7/8.

Global Task 1 only freezes these points:

- file/transfer backend capability already exists;
- active DSM identity/session must remain the source for DSM file URLs;
- a feature must not bypass session authority;
- current UI selection storage (`selectedFiles.contains(file)`) is not sufficient proof of the new identity-preserving selection contract.

Upload-tab/task aggregation is incomplete in the legacy presentation and is not promoted to a global authority.

## 12. Navigation, startup and fallback

### Existing navigation facts

- `Home` uses five legacy tabs in an `IndexedStack`.
- Only the File tab currently owns a nested `Navigator` via `FilePage`.
- named top-level routes in `MaterialApp` expose several legacy applications.
- helper navigator extensions expose push/pushNamed/pop/popUntil.
- Back handling in legacy Home explicitly delegates into the File navigator and otherwise uses double-back exit.

Disposition:

- legacy page widgets/routes as fallback destinations: **Direct reuse through a host boundary**;
- legacy Home as the future shell: **Legacy-only presentation**;
- independent New UI tab stacks: **New UI shell responsibility**, not derivable from current Home.

`LegacyPageHost` must be the explicit handoff boundary. A legacy page must not be wrapped in a second New UI App Bar or silently restyled.

## 13. Theme boundary

Authority/evidence:

- legacy `lightTheme` and `darkTheme`;
- `AppTheme` ThemeExtension;
- `DarkModeProvider` persists `dark_mode` values 0/1/2;
- `main.dart` currently installs legacy light/dark ThemeData globally and currently uses `ThemeMode.system`.

Disposition:

- legacy ThemeData for fallback rendering: **Direct reuse**;
- New UI Material 3 theme: separate Task 2/3 authority;
- isolation between them: **Minimal host adapter**.

Task 3 must scope legacy pages under legacy ThemeData rather than allowing New UI Material 3 tokens to leak into them. Existing public ThemeData is sufficient; no legacy theme rewrite is required.

## 14. Android lifecycle, Back and platform/intents

### Platform evidence

`AndroidManifest.xml` declares:

- launcher activity;
- `SEND` and `SEND_MULTIPLE` for arbitrary shared files;
- `VIEW` for `application/x-bittorrent`;
- storage/media/notification/install-package permissions used by existing features.

`Home` uses `flutter_sharing_intent` for cold and warm external share delivery:

- a single torrent opens Download Station add-task flow;
- other shared files open File Station upload flow.

File Station can launch Android `ACTION_VIEW` for external video playback.

`MainActivity` is a `FlutterFragmentActivity` and contains only window/system-bar compatibility flags; there is no custom platform-channel authority to preserve.

Disposition:

- manifest intent capability and plugins: **Direct reuse**;
- handlers currently tied to legacy `Home`: **Minimal adapter** when New UI shell becomes primary;
- feature-specific file/media intent routing: **Feature-specific audit required**.

### Lifecycle / launch security

Legacy Home preserves an “安全启动” capability using persisted launch-auth settings and opens `AuthPage` when backgrounding if protection is enabled. Successful local authentication returns to the prior navigation context.

Disposition: **preserve legacy capability through a Minimal adapter**. It is compatible with the approved rule that ordinary resume preserves current navigation; the security gate may cover the current route but must not reset it.

## 15. Capability disposition summary

| Area | Disposition |
|---|---|
| DSM entry | Direct reuse + state adapter |
| DSM batch | Feature-specific audit required |
| DSM stream | Direct reuse |
| API discovery/version | Direct reuse + context adapter |
| Auth login/logout/OTP | Direct reuse |
| saved-account legacy OTP controller | Feature-specific defect; do not reuse controller semantics |
| server/account Drift persistence | Direct reuse |
| active Server+Account/session setup | Minimal adapter |
| cold-start default restore | Minimal adapter |
| QuickConnect | Feature-specific audit required |
| shared provider values | Direct reuse where semantics match |
| stale/loading/error state | Minimal New UI state layer |
| dashboard models | Direct reuse; composition feature-specific |
| notifications | Direct reuse + global-shell adapter |
| applications discovery/order | Feature-specific audit required |
| File Station / transfer | Feature-specific audit required |
| legacy page fallback | Direct reuse through LegacyPageHost |
| legacy Home shell | Legacy-only presentation |
| legacy themes | Direct reuse inside fallback boundary |
| New UI/legacy theme isolation | Minimal host adapter |
| Android share/torrent intents | Direct reuse capability + shell adapter |
| Android external playback | Feature-specific audit required |

## 16. Contract Gap status from inventory

### Product semantic gaps resolved in Task 1

1. **PG-01 multi-account device-card identity — RESOLVED**  
   Approved: one card per `Server + Account`.

2. **PG-02 cold-start automatic account choice — RESOLVED**  
   Approved: exactly one default account is required for automatic restore; none/multiple defaults fall back to selection.

### Technical interface gaps / debts

- **TG-01 active-context orchestration is page-scattered** — Minimal adapter required; public safe pieces exist. **Non-blocking for Task 2/3.**
- **TG-02 batch failure surface is weak** — audit before a New UI feature relies on batch success/empty semantics. **Non-blocking for Task 2/3.**
- **TG-03 current data providers lack stale/error metadata** — add New UI state metadata without replacing DSM authority. **Non-blocking.**
- **TG-04 legacy theme requires host scoping under the New UI shell** — public legacy ThemeData exists. **Non-blocking.**
- **TG-05 saved-account OTP controller drops its OTP argument** — Task 4 must use `Auth.login` directly/correctly. **Feature-specific; non-blocking.**
- **TG-06 current Splash does not implement approved default-account restore** — safe persistence/session primitives exist. **Minimal adapter; non-blocking.**
- **TG-07 external-share handling is coupled to legacy Home** — move orchestration to New UI shell without changing Android intent authority. **Non-blocking.**
- **TG-08 File Station legacy selection uses in-memory object containment** — Task 7 must prove stable identity across sort/list-grid/refresh. **Feature-specific.**
- **TG-09 server deletion account cleanup query uses the wrong account column** — Task 4 blocker for safe server deletion, not a Task 2/3 blocker.

### Real blockers for Task 2 / Task 3

**None found.**

No inspected global requirement requires private-state access, a second DSM/session authority, or a production-code rewrite merely to proceed to Visual Spec / New UI Foundation.
