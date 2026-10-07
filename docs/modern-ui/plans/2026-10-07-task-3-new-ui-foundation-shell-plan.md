# DSM Helper Modern UI — Task 3 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: use Superpowers TDD while implementing each batch; verify each RED before production code and each GREEN with the repository CI gate.

**Goal:** Establish the Material 3 New UI foundation and five-destination shell while preserving legacy behavior behind an explicit, theme-isolated fallback boundary.

**Architecture:** Keep the existing DSM/API/model/provider/database authorities intact. The New UI owns Material 3 presentation, primary navigation, shell lifecycle/intent orchestration, and startup routing decisions; unmigrated features remain full legacy routes hosted by `LegacyPageHost`, never visually restyled in place.

**Tech Stack:** Flutter 3.22.3, Dart >=3.4.3 <4.0.0, Provider, existing Drift persistence, existing `flutter_sharing_intent`, existing DSM API/model layer.

**Specs:**
- `docs/modern-ui/specs/2026-10-07-dsm-helper-modern-ui-spec.md`
- `docs/modern-ui/specs/2026-10-07-dsm-helper-modern-ui-visual-design.md`
- `docs/modern-ui/contracts/2026-10-07-global-contract-matrix.md`

## Global Constraints

- Do not begin Task 4 or redesign any feature page.
- Prefer `lib/new_ui/**` and `test/new_ui/**`; legacy/shared edits require a concrete Task 3 routing/startup blocker and remain minimal.
- New UI uses the frozen Material 3 tokens; legacy fallback keeps existing `lightTheme` / `darkTheme`.
- Five primary destinations are 概览 / 文件 / 应用 / 任务 / 我的 and retain independent navigation stacks.
- No tablet/landscape/foldable architecture is introduced.
- Network failure must not be converted into authentication invalidation.
- CI cannot substitute for Android Back, system bars, lifecycle/auth, IME, or real share/torrent intent verification.

## Review Focus

1. Theme switching while a nested route is open must not recreate/reset the shell navigation tree.
2. A hosted legacy page must see legacy-compatible theme values while the surrounding shell remains New UI Material 3.
3. Back must pop only the active tab/legacy route and leave inactive tab stacks intact.
4. Lifecycle launch-auth must cover the current route and reveal the exact same route after successful local authentication.
5. Initial and warm external intents must be dispatched once without duplicate Upload/AddDownloadTask navigation.

---

## Batch A — Material 3 Theme + Legacy Isolation

**Files:**
- Create: `lib/new_ui/theme/new_ui_theme.dart`
- Create: `lib/new_ui/legacy/legacy_page_host.dart`
- Create: `test/new_ui/theme/new_ui_theme_test.dart`
- Create: `test/new_ui/legacy/legacy_page_host_test.dart`

**Interfaces:**
- `NewUiTheme.light()` / `NewUiTheme.dark()` produce the frozen Material 3 themes.
- `NewUiTheme.resolveMode(int legacyMode)` maps legacy 0/1/2 to Light/Dark/System without changing persisted semantics.
- `LegacyPageHost({required Widget child, Brightness? brightness})` creates a local legacy `Theme` boundary only around the hosted route.

- [ ] RED: add theme/token and theme-isolation tests; verify they fail because Task 3 production interfaces do not yet exist.
- [ ] GREEN: implement the smallest New UI theme builder and legacy theme host needed by the tests.
- [ ] Verify targeted tests, full `flutter test`, and targeted `flutter analyze lib/new_ui test/new_ui`.
- [ ] Diff-review Batch A for frozen token fidelity and no legacy production edits.

## Batch B — Shell, Navigation, Back, Lifecycle, Notifications, Intents

**Files:**
- Create: `lib/new_ui/shell/new_ui_shell.dart`
- Create: `lib/new_ui/shell/primary_destination.dart`
- Create: `lib/new_ui/shell/primary_root_page.dart`
- Create: `lib/new_ui/navigation/root_back_policy.dart`
- Create: `lib/new_ui/lifecycle/launch_auth_gate.dart`
- Create: `lib/new_ui/intents/external_intent.dart`
- Create: `lib/new_ui/legacy/legacy_destinations.dart`
- Create tests under `test/new_ui/shell/**`, `test/new_ui/navigation/**`, `test/new_ui/lifecycle/**`, and `test/new_ui/intents/**`.

**Interfaces:**
- `NewUiShell` owns one nested `Navigator` key per primary destination and a Material 3 `NavigationBar`.
- Each nested navigator starts on a shell-only `PrimaryRootPage`; it may push a full-route `LegacyPageHost`. The New UI App Bar therefore disappears while a legacy page with its own App Bar is active.
- Shell root App Bars expose the global DSM notification entry without depending on Dashboard widget lifetime.
- `RootBackPolicy` preserves current-tab-first Back behavior and a deterministic legacy-compatible root exit confirmation window.
- `LaunchAuthGate` reuses legacy `AuthPage(launch: false)` as an isolated route, so successful authentication pops back to the exact prior route.
- External-intent classification/once-dispatch is pure and testable; the concrete adapter reuses `flutter_sharing_intent` and legacy Upload/AddDownloadTask destinations.

- [ ] RED: add relationship tests for independent stacks, legacy handoff/theme boundary, notification entry, Back, lifecycle gate, and exactly-once intent dispatch.
- [ ] GREEN: implement only the shell/orchestration required by those contracts.
- [ ] Verify targeted tests, full test suite, targeted analyze, changed-file scope, and that no feature implementation was introduced.

## Batch C — Startup Resolver, Context Restore, Minimal Legacy Wiring

**Files:**
- Create: `lib/new_ui/startup/startup_resolver.dart`
- Create: `lib/new_ui/session/active_context_coordinator.dart`
- Create tests under `test/new_ui/startup/**` and `test/new_ui/session/**`.
- Modify only if required by the verified routing blocker:
  - `lib/main.dart`
  - `lib/pages/splash/splash.dart`
  - `lib/pages/server/select_server.dart`
  - `lib/pages/login/login.dart`

**Interfaces:**
- Startup resolver is pure: launcher-selection on → legacy selector; otherwise exactly one default account with a valid server relation → restore candidate; zero/multiple defaults or broken relation → selector.
- Active-context coordinator reuses the single `Api.dsm` authority, API discovery, and NormalUser probe. Connectivity failure is classified as offline/stale; DSM auth-invalid code 119 is reauth-needed; no fallback account is silently selected.
- Existing legacy server/login flows change only their successful Home destination to `NewUiShell`.
- Legacy Splash retains its downloader/startup responsibilities but delegates the frozen default-account decision/context setup to New UI startup code.

- [ ] RED: add 0/1/2-default startup tests and context-result relationship tests.
- [ ] GREEN: implement startup/context adapters and the minimal routing patches.
- [ ] Verify the full test suite and targeted analysis.
- [ ] Run the existing Android development CI, require the beta debug APK artifact, and inspect the complete Task 3 diff.

## Automated Exit Review

Before a real-device gate:
- every Task 3-owned Global Contract Matrix row has an implementation/test mapping or an explicit shared/later-task boundary;
- no Task 4 feature UI exists;
- no New UI token leaked into legacy theme definitions;
- all tests and targeted analysis pass;
- Android development APK builds and artifact exists;
- commit/changed-files evidence matches Task 3 scope.

## Real-Device Gate

Required before Task 3 final acceptance/merge:
- install/launch the CI APK;
- verify portrait shell and Light/Dark system-bar behavior;
- verify each primary destination and at least two legacy fallback routes;
- verify Android Back through nested fallback and primary root;
- background/resume with launch-auth off and on; unlock returns to the same route;
- verify one ordinary SEND/SEND_MULTIPLE handoff and one torrent VIEW handoff without duplication;
- verify no duplicate App Bar and no visible New UI theme bleed inside legacy fallback.

Only after this gate passes may the final Task 3 acceptance document and Master Plan completion state be committed and the PR merged to `modern-ui`.
