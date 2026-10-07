# DSM Helper Modern UI — Global Contract Matrix

> Task: Task 1 — Project Specification + Legacy Interface / Protocol Freeze  
> Date: 2026-10-07  
> Applies to all later Modern UI tasks unless a later approved product specification explicitly supersedes a row.

## 1. Matrix rules

This matrix freezes only **global / cross-module** behavior. Feature-specific button/API details remain in later Feature Contracts.

Each row names the current legacy authority and the observable invariant that later implementations must prove. A New UI adapter may add orchestration or presentation state, but it must not create a second DSM/session/persistence authority.

## 2. Global contracts

| ID | Type / Operation | Preconditions | Legacy authority | Inputs | Expected State Delta | Must Remain Unchanged | Success / Observable Result | Failure Semantics | New UI Usage | Validation / Executable Invariant Proof |
|---|---|---|---|---|---|---|---|---|---|---|
| G-DSM-01 | DSM single request | Active `DsmApi` context exists; API discovery available when version omitted | `DsmApi.entry`, `ApiModel.apiInfo`, `DsmResponse`, `DsmException` | API, method, args, optional version/GET flag | Remote DSM operation may mutate only according to called API | Active account/server identity; unrelated provider/navigation state | Successful DSM envelope returns parsed data | DSM protocol failure → `DsmException`; transport failure remains transport/network failure | All features call existing DSM/model authority rather than a parallel client | Test success response, DSM error response, timeout/unreachable response; prove timeout is not converted to auth invalidation |
| G-DSM-02 | DSM batch request | Active DSM context; caller knows member contract | `DsmApi.batch`, `BaseModel` | compound model requests, mode, stop_when_error | Remote effects only from requested batch members | Session identity and unrelated local state | Successful top-level compound result maps member responses in order | Existing batch surface is weaker than `entry`; empty result must not automatically mean “successful empty dataset” | Later feature may reuse only after feature-level member/failure audit | Feature contract must include at least one member-error case and prove empty-data vs batch-failure distinction before relying on it |
| G-DSM-03 | DSM stream | Active DSM context | `DsmApi.stream` | URL, query, headers inherited from transport | Stream lifecycle only | Session authority and unrelated app state | Consumer receives response byte stream | Transport/stream errors remain feature-visible; no implicit logout | File/media/log consumers may reuse | Test stream open/read/cancel/error in consuming feature |
| G-API-01 | API discovery/version | Server endpoint selected/reachable | `ApiModel.info`, static `ApiModel.apiInfo`, `DsmApi.entry` version fallback | current DSM base URL | API capability/version map becomes current-server map | Stored server/account records; navigation | Subsequent calls may omit explicit version and use discovered version | Discovery transport failure is connectivity failure; it does not erase saved account/session | Session/context setup must refresh discovery when active server changes | Switch server A→B and prove API map corresponds to B before first version-dependent feature request |
| G-AUTH-01 | Login / staged OTP | Selected `Server + Account`; credentials available; DSM reachable | `Auth.login` | account, password, optional OTP code | On success obtain sid/deviceId/synotoken and update active authenticated context/persistence as Task 4 defines | Other saved accounts; unrelated navigation stacks until successful context transition | Authenticated context established; caller can enter shell | 400 credential failure remains auth failure; 403/404/414 enter staged verification; network failure remains offline/connectivity; 119 is session-invalid when observed during authenticated use | Task 4 owns New UI flow but reuses Auth protocol | Login success; wrong password; OTP-required then success; network loss during login; prove no second auth client |
| G-AUTH-02 | Explicit logout / forget trusted device | Authenticated or locally known account context | `Auth.logout`, `Auth.forget` | optional forget-device decision | Remote session ends; optional DSM trusted-device record removed; New UI leaves authenticated context | Other saved accounts/servers unless user separately deletes them | User lands in server/account selection or login state according to Task 4 flow | Remote logout failure must not be disguised as successful remote confirmation; local exit may still proceed only under explicit Task 4 policy | Settings/account actions | Test logout and logout+forget; prove network timeout is not treated as spontaneous auth invalidation |
| G-SESS-01 | Active session/context setup | A specific saved or newly authenticated `Server + Account` is selected | `Api.dsm`, `ApiModel.apiInfo`, Drift `Servers/Accounts`, `NormalUser.get` legacy probe | server URL, deviceId, sid, account identity | Rebind the single active DSM runtime authority to selected context; refresh capability map; session status becomes valid/offline/reauth-needed based on evidence | Saved records for other contexts; unrelated app preferences | All DSM-dependent features observe one coherent active context | Transport failure → offline/stale; DSM auth-invalid (observed 119) → reauth-needed; do not silently fall back to another account | Task 3 shell consumes context state; Task 4 supplies selection/login UI | Inject A then B; prove `Api.dsm`, API map, shell label and fetched data all refer to B and no A-specific provider value remains visible |
| G-PERSIST-01 | Device-card identity | Saved server/account data exists | Drift `Servers`, `Accounts` | joined Server + Account rows | None for read/list; selected card identifies exactly one login context | Shared Server record remains shared between its accounts | One card = one `Server + Account`; same NAS with two accounts yields two enterable cards | Broken/missing relation is invalid persisted data and must not be guessed into another account | Task 4 server/account page | Fixture with one server + two accounts → two cards with same address but different user; tapping each selects matching account |
| G-PERSIST-02 | Cold-start automatic restore choice | launcher-selection setting off | Drift `Accounts.isDefault`; persisted launcher setting | saved accounts | If exactly one default exists, choose that `Server + Account` as restore candidate | No account flags are changed merely by startup | Exactly one default → restore candidate; zero or >1 defaults → selection page | Ambiguous defaults are not auto-resolved, reordered or “last used” guessed | Task 3 startup router; Task 4 enforces unique-default mutation | Parameterized test: 0 defaults → selection; 1 → overview restore path; 2 → selection |
| G-NAV-01 | Primary navigation | New shell mounted | Approved Project Spec; legacy `Home` only as evidence of current tabs, not authority | primary tab selection, pushes within a tab | Selected tab changes or current tab stack mutates | Every non-selected tab’s navigation stack | Switching tabs returns to each tab’s prior route; no cross-tab stack replacement | Route failure stays local; must not reset unrelated stacks | Task 3 shell | Navigate Overview child, Files child, switch back/forth; assert both stacks preserved independently |
| G-NAV-02 | Cold start / resume | App process starts or resumes | approved Spec; persisted launcher/default context; Android lifecycle | cold start vs background resume | Cold start resolves root; resume restores existing route tree and may refresh data | On resume: current tab/page/navigation; on cold start: no old deep page restoration | Cold start auto-restore lands Overview root; launcher-selection on lands selector; ordinary resume stays on current page | Temporary network failure at cold start may produce offline/stale shell, not forced login | Task 3 startup/lifecycle | Cold start with unique default online/offline; cold start with selector enabled; background/resume from nested Files route; prove nested route survives resume |
| G-NAV-03 | Device/account switch | Shell currently bound to context A; user selects context B | persistence + `Api.dsm`/API discovery + global providers | target `Server + Account` | Active context becomes B; NAS-specific transient state cleared; all primary stacks reset to roots; selected tab becomes Overview | Saved context A remains stored; global non-NAS preferences remain | Overview root displays/fetches B only | Failed setup of B must not expose mixed A/B UI; auth-invalid B enters reauth; connectivity failure uses B offline/stale only when safe | Task 3/4 shared contract | Seed A provider data, switch B, assert no A hostname/resource/file selection/notification remains and route is Overview root |
| G-STATE-01 | Refresh / last-valid-data | A refreshable view has valid data or no data | existing model/provider APIs + approved Spec | manual pull or automatic cadence | On success replace relevant data; while refreshing retain last valid value; on failure mark stale/error without clearing valid value | Navigation, selection and unrelated page state | User sees old valid data plus refreshing/stale state until a new valid result arrives | Network/DSM read failure does not zero-out or fabricate empty values | Dashboard and later refreshable features | Load V1, start refresh, fail → V1 still present + stale; next success V2 → V2 replaces V1 |
| G-NET-01 | Network failure vs auth invalidation | Active context exists | Dio transport behavior; `DsmException`; observed 119 handling | request failure/error code | Connectivity state or auth state changes according to evidence | Saved credentials/session on connectivity failure | Timeout/DNS/unreachable → offline/reconnecting; actual auth invalidation → reauth-needed | Never map generic exception/empty batch result to logout | All DSM-aware New UI | Unit classifier cases + integration request cases; assert timeout keeps selected account and session persistence |
| G-THEME-01 | Theme mode / color-source change | New shell mounted | persisted legacy dark-mode setting for mode compatibility; approved Spec; Task 2 New UI theme | System/Light/Dark and DSM Helper/dynamic color source | Presentation theme changes only | Navigation stacks, active account, providers, file selection, in-flight business state | New pages redraw with selected Material 3 theme without state reset | Theme construction failure must not mutate business/session state | Task 2/3 | Switch light↔dark and color source from a nested route; assert route, active context and page state unchanged |
| G-THEME-02 | Legacy fallback isolation | New Material 3 shell opens unmigrated page | legacy `lightTheme`, `darkTheme`, `AppTheme`; future `LegacyPageHost` | legacy destination + current effective brightness | Legacy page mounted under legacy-compatible theme scope | New shell ThemeData and legacy page’s established behavior must not overwrite each other | Legacy fallback remains usable and visually legacy-compatible; no duplicate New UI App Bar | Failure to construct host is a Task 3 blocker; do not “fix” by globally applying New UI theme to legacy | Task 3 and every fallback handoff | Open multiple legacy pages from New shell in Light/Dark; compare core controls/theme and return; assert New shell theme unchanged |
| G-LEGACY-01 | Legacy page fallback/handoff | Feature not yet migrated; registered/constructible legacy page exists | existing page/widget + current navigation utilities; future `LegacyPageHost` | legacy route/destination | Push legacy destination within controlled host boundary | New shell primary architecture; legacy feature implementation | User can enter, use, Back out; migrated pages replace entries one-by-one | A broken legacy feature is recorded/audited; it is not silently reimplemented during unrelated tasks | Task 3 onward | New Shell → LegacyPageHost → at least two legacy pages → Back; prove no double App Bar and no theme bleed |
| G-NOTIFY-01 | Global DSM notification entry | Shell active, with or without currently mounted Dashboard | `DsmNotify.notify`, `DsmNotify.clean`, `DsmNotifyStrings` | app-bar notification action, refresh/clear later | Notification view state loads/changes independently | Current primary-tab navigation and unrelated dashboard state | App Bar entry opens DSM notifications from any primary tab | Notification load failure follows network/auth global semantics; must not require Dashboard widget lifetime | Task 3 global shell + notification fallback/new page | From each primary tab open notifications; simulate timeout; assert underlying tab route survives and account is not logged out |
| G-FILE-01 | File-selection identity invariant | File Station list/grid has loaded a directory | `FileItem.path`/object data from `FileStationList`; approved Spec | select items; sort; toggle list/grid; refresh; change directory | Selection set changes by stable file identity; directory change clears selection by default | Sorting/layout must not change selected objects; selection must not leak to another directory | Same files remain selected after reorder/layout; entering another directory yields empty selection | Missing selected item after refresh is reconciled explicitly by Task 7 policy, never by list index | Task 7A/7B | Select paths A,C → sort/toggle grid → A,C selected; navigate directory → none selected; test duplicate display names at different paths |
| G-ANDROID-01 | Android Back | App running in New shell or hosted legacy page | Flutter Navigator(s), Android system Back; legacy Back behavior only as evidence | hardware/system Back | Pop the current eligible route/stack first; at primary roots follow Task 3 app-exit policy | Other tab stacks and active DSM context | Back is deterministic and respects current navigator/host | Back must not accidentally switch/delete another stack or log out | Task 3 shell and LegacyPageHost | Nested New page Back; nested legacy Back; File nested navigator Back; primary-root Back; verify other stacks preserved |
| G-ANDROID-02 | Background/resume + local launch-auth gate | Launch-auth preference enabled/disabled; app moves background↔foreground | legacy `AuthPage`, `HelperSetting` persisted launch-auth settings, Android lifecycle | lifecycle state; biometric/gesture result | If gate enabled, cover current UI until local auth succeeds; otherwise resume unchanged | Underlying navigation/context/data | Successful local auth reveals the exact prior route; ordinary resume does not reset shell | Local-auth cancel/failure keeps gate; it does not become DSM logout or select another account | Task 3 shell retains capability using minimal orchestration adapter | Resume nested route with gate off/on; successful biometric/gesture returns to same nested route; failure leaves gate |
| G-ANDROID-03 | External share / torrent intent handoff | Android sends SEND/SEND_MULTIPLE or bittorrent VIEW | manifest intent filters; `flutter_sharing_intent`; legacy Home handling; File Upload / Download Station add-task destinations | incoming files/URI | Route to corresponding feature flow when available; consume event once | Active account and unrelated tab stacks until an explicit destination handoff | Single torrent goes to Download Station add-task; ordinary shared files go to upload flow | Missing feature/invalid file produces explicit recoverable error; intent must not be silently dropped or double-consumed | Task 3 owns shell-level intent reception; Task 7C/11 own destination details | Cold-start and warm intent tests; assert exactly-once routing and no duplicate upload/add-task |
| G-PREF-01 | Global settings persistence | Preference storage initialized | `SpUtil`, `DarkModeProvider`, `SettingProvider`, `HelperSetting` keys | refresh period, launcher selection, launch-auth, theme mode, media preference | Only requested preference changes | DSM session and navigation unless preference’s explicit behavior applies on next lifecycle event | Setting persists and later consumer observes same value | Persistence failure must not fabricate a successful business-state change | Task 2/3/feature settings | Toggle setting, recreate providers/app scope, assert persisted value; launcher setting affects next cold start, not current route immediately |

## 3. Transaction / rollback / retry notes

Only global operations that actually need these semantics are frozen here.

### G-SESS-01 / G-NAV-03 context switch

Context switch is a logical all-or-nothing handoff from the UI perspective:

1. select target `Server + Account`;
2. bind the existing active DSM authority to target identity;
3. refresh target API discovery when required;
4. classify target as authenticated, offline/stale, or reauth-needed;
5. clear A-specific transient New UI/provider state;
6. reset navigation to Overview root.

The UI must never publish a mixed state such as “B selected” while displaying A-specific resource values.

Rollback is not “switch back silently to A”. If target setup cannot be safely classified, remain in an explicit transition/error state and require a deliberate user action.

Retry uses the same target context; it must not duplicate persisted accounts or create another DSM client authority.

### G-STATE-01 refresh

Read refreshes are retryable and must be idempotent from the local UI-state perspective. Failure preserves last valid data.

### G-AUTH-01 login

Credential/OTP retries are explicit staged attempts. A retry must not insert duplicate persisted account rows merely because a prior network/auth stage failed; exact persistence timing belongs to Task 4.

## 4. Resolved Contract Gaps

### CG-PROD-01 — multi-account server-card mapping

**Status: Resolved by user decision A.**

Frozen result: each saved `Server + Account` is an independently enterable device-card context.

### CG-PROD-02 — automatic cold-start account choice

**Status: Resolved by user decision A.**

Frozen result: auto-restore uses an exactly-one-default rule. Zero or multiple defaults go to server/account selection.

## 5. Technical gaps that do not block Task 2 / Task 3

| Gap | Impact | Required later handling |
|---|---|---|
| TG-01 page-scattered active-context orchestration | Risk of mixed DSM/provider state during switch | Task 3/4 implement one thin coordinator around existing `Api.dsm` / API discovery / persistence |
| TG-02 weak batch failure surface | Empty result can be ambiguous | Each feature auditing batch must prove member/top-level failure semantics |
| TG-03 providers lack stale/error metadata | Cannot meet refresh contract by provider value alone | New UI adds state metadata without replacing backend authority |
| TG-04 no LegacyPageHost exists yet | Theme/nav fallback not isolated today | Task 3 implements the host; legacy ThemeData already exists |
| TG-05 legacy saved-account OTP controller drops OTP argument | OTP retry through that controller is unsafe | Task 4 uses underlying `Auth.login(... optCode)` correctly |
| TG-06 legacy Splash ignores approved default restore | Old startup cannot satisfy new contract | Task 3 startup resolver uses persisted default-account rule |
| TG-07 external-share receiver lives in legacy Home | New shell would otherwise miss intents | Task 3 moves orchestration to shell-level boundary |
| TG-08 legacy file selection relies on object containment | Sort/refresh identity invariant not mechanically proven | Task 7 uses stable file identity/path and relationship tests |
| TG-09 account cleanup query on server deletion is wrong | Unsafe server deletion can leave accounts | Task 4 fixes as the minimal feature blocker before enabling delete |

## 6. Exit-gate relationship proofs required by later tasks

Later isolated tests are not enough. At minimum these cross-module proofs must exist before the associated behavior is accepted:

- device switch → DSM authority changes → API discovery corresponds to new server → old NAS UI state cleared → Overview root;
- timeout/unreachable DSM → offline/stale → saved account/session retained → no login redirect;
- auth-invalid response → reauth-needed → no provider mix or silent context switch;
- theme change → navigation/business state preserved;
- New Shell → LegacyPageHost → legacy page works → Back returns to same New UI stack;
- file selection → sort/list-grid → identity preserved → directory change clears selection;
- background/resume with launch-auth → local gate → successful unlock reveals same route;
- Android share intent → exactly one feature handoff without losing active context.

## 7. Task 1 blocking-gap result

**No unresolved Product Semantic Gap or Technical Interface Gap blocks Task 2 or Task 3.**

Task 3 is expected to implement the thin shell/context/theme/intent adapters already within its planned scope. Those adapters compose existing public authorities; they do not require a DSM SDK rewrite, provider rewrite, database rewrite, or private-state bypass.
