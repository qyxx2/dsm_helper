# DSM Helper Modern UI — Task 6 Applications Hub + Settings Shell Contract Matrix

> Status: Approved — Batch planning authorized  
> Date: 2026-10-10  
> Task: Task 6 — Applications Hub + Settings Shell  
> Branch: `feature/t6-applications-settings`  
> Base: `modern-ui@1e0c74b9a85b7bd2d0c5f49fc5f7661d7f638c4c`  
> Feature design: `docs/modern-ui/specs/2026-10-10-task-6-applications-settings-feature-design.md`

## 1. Purpose

This matrix freezes Task 6 behavior not already fully defined by global contracts.

Inherited authorities remain binding, especially:

- `G-SESS-01`
- `G-NAV-01`
- `G-NAV-03`
- `G-NET-01`
- `G-THEME-01`
- `G-THEME-02`
- `G-LEGACY-01`
- `G-NOTIFY-01`
- `G-ANDROID-01`
- `G-PREF-01`
- `APK-IDENTITY-01`
- `CI-DOCS-01`

## 2. Feature Contracts

| ID | Operation / Type | Preconditions | Authorities | Expected State Delta | Must Remain Unchanged | Failure / Rollback | Observable Result | Executable Invariant Proof |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| T6-APP-01 | DSM application source/order | Context-scoped InitData is loaded | `InitDataModel.userSettings.desktop.validAppviewOrder/appviewOrder` | Produce source package sequence | DSM Desktop order/config; session | Empty `validAppviewOrder` falls back to `appviewOrder`; missing InitData is unavailable, not successful empty | Supported apps follow DSM source order | Fixtures for non-empty valid list, empty valid + fallback, loaded empty, unavailable InitData |
| T6-APP-02 | Canonical supported catalog | Source sequence available | Task 6 catalog + existing legacy feature builders/assets | Supported aliases become one canonical item each | Raw DSM source; unsupported entries | Unknown IDs skipped; alias duplicates deduped by first source position | Only launchable supported applications appear | Mixed fixture including LogCenter Instance/BuiltIn, Docker/ContainerManager, unknowns; assert IDs/order/dedupe |
| T6-APP-03 | Application launch | User taps resolved app | Explicit Task 6 destination mapping + `LegacyPageHost` + current `DsmProviderScope` | One legacy feature route is pushed in current context | Other tab stacks, active DSM identity, favorites | Missing mapping is contract failure/unavailable; never guess route name | Existing feature opens; Back returns to Applications | Catalog item for each mapping has non-null builder; relationship test tap/open/back |
| T6-APP-04 | Applications unavailable vs empty | Applications root mounted | context status + context-scoped InitData | Presentation state only | favorites persistence, DSM/session | Missing/bootstrap-failed InitData never becomes “没有应用” | User can distinguish unavailable from genuine zero supported apps | Widget tests for loaded-empty and unavailable snapshots |
| T6-FAV-01 | Favorites persistence | `SpUtil` initialized | key `modern_ui_application_favorites_v1`; canonical application IDs | Ordered local list is read/written | DSM app order; DSM Desktop shortcuts; Task 5 Overview shortcut config | Write failure leaves published favorites unchanged | Restart restores same ordered list | Fake store/controller round-trip; assert no DSM model/API interaction |
| T6-FAV-02 | Favorites current-context projection | Persisted list + current catalog exist | T6-FAV-01 + T6-APP-02 | Compute visible favorites only | Persisted hidden/unavailable/unknown/overflow IDs | Projection never deletes storage entries | Up to 8 available favorites shown in stored order | >8, unavailable and unknown fixtures; assert first 8 eligible and unchanged backing list |
| T6-FAV-03 | Pin / unpin | Supported app visible | favorites controller/store | Pin appends canonical ID; unpin removes selected ID | Other favorites order; DSM state | duplicate pin is no-op; pin rejected when 8 currently visible; failed save publishes no success | Context sheet uses the same background color as NavigationBar in both themes and changes Common | Unit tests for duplicate, limit, remove, save failure; widget feedback test |
| T6-FAV-04 | Reorder visible favorites | Edit surface contains current visible set V | persisted list S + preservation merge | Slots belonging to V receive edited order E | Every non-V stored ID and relative position | E must contain exactly V; invalid edit rejected; save failure retains prior state | Contextual long-press reorder opens existing editor; no persistent Edit button; hidden favorites remain preserved | Hidden/unknown/overflow interleaving fixtures; assert exact merged list |
| T6-APP-05 | Four-column Applications presentation | Resolved catalog available | Project Spec + Task 2 Visual Spec | Presentation only | app order, navigation, DSM state | Long labels/font scale may grow content but must not silently switch to legacy oversized layout | Four launcher columns; max-two-line labels; no per-app Cards | Widget tests at normal and large font, Light/Dark |
| T6-SET-01 | Modern Settings root composition | Shell mounted | Project Spec + existing local/context values | Presentation only | DSM/session/provider state | Missing optional context metadata is omitted; root itself does not fail on network absence | One ungrouped list with compact device/account card (icon personal/logout actions) and uniform text-only settings rows | Widget tests for section order, sparse context and no hero/card wall dependency |
| T6-SET-02 | Theme mode change | Settings root mounted | `DarkModeProvider`, persisted `dark_mode`, `G-THEME-01` | Effective mode becomes System/Light/Dark | navigation stacks, active DSM context, page/business state | Provider/persistence failure must not be reclassified as DSM/session failure | UI redraws in selected mode and later startup restores it | Provider/widget persistence test + nested-route relationship test |
| T6-SET-03 | Account management and logout | Current saved/authenticated context | Task 4 callbacks/controllers; `G-AUTH-02` | Existing Task 4 flow executes | No duplicate account/session authority | Task 6 must not locally clear/recreate auth/session state | My page reaches Server/Account management and established logout confirmation/exit | Inject callbacks; assert exactly one invocation and no Task6 auth controller |
| T6-SET-04 | Legacy settings/detail handoff | User selects unported detail | `LegacyPageHost`, existing detail page, provider wrapper | Push legacy detail/fallback | New shell theme/navigation; unrelated tabs | Legacy failure remains local; Task 6 does not reimplement it opportunistically | Helper/User/About or compatibility root opens and Back returns to My | Light/Dark open/back tests for at least two details + compatibility root |
| T6-SET-05 | Shutdown/reboot boundary | Modern Settings rendered | audited repository facts | No Modern power action | legacy source; active DSM | Presence of legacy UI affordance is not treated as backend support | User is not offered a Modern action that cannot execute | Widget/source boundary test: no shutdown/reboot action/callback in Task 6 Settings surface |
| T6-SET-06 | Dynamic Color boundary | Modern Settings rendered | Task 2 optional-design rule | None | existing ColorScheme/theme mode | Task 6 must not add partial Dynamic Color state/wiring | Only System/Light/Dark mode is managed in Task 6 | Widget test asserts three mode choices and no Dynamic Color control |
| T6-CTX-01 | DSM context switch | A active then Task 4 activates B | `G-SESS-01`, `G-NAV-03`, context-keyed provider scope | Applications catalog recomputes from B; primary stacks reset per global contract | app-local favorites storage | Late/old A provider data never appears under B | B Applications reflects B only; favorites are re-filtered without deletion | A/B unique app fixtures + same persisted favorites; remount/switch relationship test |
| T6-NAV-01 | Applications/Settings child navigation | New root is current primary tab | `NewUiShell`, `LegacyPageHost`, `G-ANDROID-01` | Current tab navigator/legacy child changes | other four primary-tab stacks | Back must not reset/switch unrelated tab | Return from child to same Applications/My state | Navigate child, switch tab, return, Back; assert independent stacks |
| T6-NOTIFY-01 | Global notification entry | Applications or Settings mounted | `G-NOTIFY-01` | Notification fallback opens | root page state, active tab stack after return | root lifetime/data must not own notification capability | Notification entry works from both roots | Shell relationship test from Applications and My |
| T6-SHELL-01 | Formal Applications/My cutover | B1–B4 accepted | `DsmNewUiShell` / `NewUiAppShell` | 应用 and 我的 roots use Modern pages | Overview/Files/Tasks behavior, shell/session authority | Cutover is revertible; legacy source remains | Five-tab shell enters new roots directly | Production wiring test + shell relationship tests + real-device Gate |
| T6-FALLBACK-01 | Legacy source retention | Modern roots cut over | existing `lib/pages/applications/**`, `lib/pages/setting/**` | No deletion required | all legacy detail capabilities | Task 6 cannot delete solely because root is migrated | Compatibility/detail handoffs remain available | Diff review asserts no legacy root deletion |
| T6-APK-01 | User-installable Task 6 Gate | CI build requested | `APK-IDENTITY-01` | APK contains Task 6 | installed app data/login identity | package/signing mismatch blocks Gate | Task 6 APK overlays Task 5 APK | CI identity assertion + user overlay install |

## 3. Canonical Application Alias Rules

The catalog must treat these package IDs as aliases:

```text
Log Center:
  SYNO.SDS.LogCenter.Instance
  SYNO.SDS.LogCenter.BuiltIn

Container management:
  SYNO.SDS.Docker.Application
  SYNO.SDS.ContainerManager.Application
```

Each alias family emits at most one Modern launcher item.

Other supported mappings remain one-to-one unless a future audited DSM alias requires an explicit contract amendment.

## 4. Favorites Preservation Invariant

Let:

- `S` = complete persisted ordered favorite-ID list;
- `C` = IDs available in the current resolved catalog;
- `V` = first eight distinct IDs from `S` that are members of `C`;
- `E` = user-edited order containing exactly the same IDs as `V`.

Visibility:

```text
visibleFavorites = first8(S filtered by C)
```

Reorder merge:

1. iterate `S` left to right;
2. if the slot ID belongs to `V`, replace it with the next ID from `E`;
3. otherwise preserve the original ID untouched;
4. never delete unknown/unavailable/overflow IDs as a side effect of reorder.

Pin/unpin are explicit mutations and are not subject to the reorder-preservation rule.

## 5. Settings Capability Boundary

Task 6 directly owns only the Modern root and the following root-level behavior:

- account/server management entry through Task 4;
- logout entry through Task 4;
- theme mode System/Light/Dark;
- direct legacy handoffs for approved details;
- retained compatibility handoff for other unported legacy settings.

Task 6 does **not** claim a working NAS power authority.

The legacy shutdown/reboot presentation is insufficient evidence because its DSM request path is commented out and no alternate working model/API was found.

## 6. Contract Gap Result

Preflight found no unresolved **blocking** Task 6 Contract Gap.

Resolved:

- incomplete legacy route-name coverage → explicit Modern destination mapping;
- Log Center DSM ID mismatch → canonical alias;
- Docker/Container Manager rename → canonical product-family alias;
- null-vs-empty source ambiguity → non-empty valid-order fallback rule;
- no Applications favorites authority → local ordered canonical-ID preference;
- cross-context favorite loss risk → projection + preservation merge;
- Task 5 shortcut collision risk → favorites are explicitly separate local state;
- Settings could duplicate auth/session → reuse Task 4 callbacks only;
- legacy power buttons without backend → do not expose Modern power action;
- optional Dynamic Color without implementation → remain out of Task 6.

## 7. Preflight Verification

Before Batch planning:

- no production/test file is changed;
- Feature Design and Matrix agree on every Task 6 authority and boundary;
- no TODO/TBD/open-ended product choice remains;
- Master Plan references both Task 6 Preflight documents;
- Task 6 branch is based on the actual accepted `modern-ui` Task 5 merge HEAD.

Under `CI-DOCS-01`, no Android CI run is required for this documentation-only Preflight.
