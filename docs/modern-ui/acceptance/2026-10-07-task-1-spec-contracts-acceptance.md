# DSM Helper Modern UI — Task 1 Acceptance

> Task: Task 1 — Project Specification + Legacy Interface / Protocol Freeze  
> Date: 2026-10-07  
> Integration target: `modern-ui`  
> Task branch: `feature/t1-spec-contracts`  
> Audit starting HEAD: `0cbbaf4921ffd08fec13bb6ff9f096f026f32c2d`

## 1. Accepted deliverables

### Project Specification

`docs/modern-ui/specs/2026-10-07-dsm-helper-modern-ui-spec.md`

Status: **Approved before the interface/protocol audit.**  
Task 1 did not redesign already-frozen product semantics.

### Global Interface / Protocol Inventory

`docs/modern-ui/contracts/2026-10-07-global-interface-protocol-inventory.md`

Status: **Complete.**

Coverage includes:

- DSM entry / batch / stream;
- API discovery/version;
- login / logout / OTP / session;
- server/account persistence and QuickConnect;
- cold-start/session restore;
- shared providers;
- dashboard/resource/status;
- DSM notifications;
- applications;
- File Station / transfer common entry points;
- navigation / legacy fallback;
- Material 3 / legacy theme isolation;
- Android Back/lifecycle/share/torrent/platform intent paths.

### Global Contract Matrix

`docs/modern-ui/contracts/2026-10-07-global-contract-matrix.md`

Status: **Complete.**

The matrix freezes cross-module/global contracts only. Detailed future feature operations remain intentionally unfrozen until their Feature Tasks.

## 2. Product Semantic Gap decisions

Two blocking product-semantic questions were raised during the audit and resolved by explicit user choice.

### CG-PROD-01 — multi-account device-card mapping

Decision: **A**

Frozen result:

- New UI card identity is `Server + Account`.
- The same NAS with multiple saved accounts produces multiple directly enterable cards.
- Server edit/delete remains server-scoped; account behavior remains account-scoped.

### CG-PROD-02 — automatic cold-start account choice

Decision: **A**

Frozen result when launcher-selection is disabled:

- exactly one `Account.isDefault == true` → use that `Server + Account` as restore candidate;
- zero default accounts → server/account selection;
- multiple default accounts → server/account selection;
- no “last used” account is invented as a competing authority.

Task 4 must preserve the unique-default invariant when changing the default account.

## 3. Technical gaps recorded

The audit found technical debt / missing New UI orchestration, but no Task 2/3 backend blocker.

Recorded gaps:

- active DSM/session setup is currently page-scattered;
- batch failure semantics need feature-specific proof before treating empty results as valid data;
- current DSM data providers do not encode last-valid/stale/error state;
- `LegacyPageHost` and theme isolation do not exist yet, as expected before Task 3;
- legacy saved-account OTP controller does not forward its OTP argument to `Auth.login`;
- legacy Splash does not implement the approved default-account restore rule;
- Android external-share reception is coupled to legacy Home;
- legacy File Station selection does not mechanically prove stable identity across sort/layout/refresh;
- server-deletion account cleanup contains a wrong-column query and must be corrected in Task 4 before safe delete is exposed.

All are recorded with later-task ownership. None requires Task 1 production-code changes.

## 4. Isolation contract acceptance

The following boundary is frozen:

- New Material 3 theme may not globally restyle legacy fallback pages.
- Legacy fallback pages use legacy-compatible ThemeData inside `LegacyPageHost`.
- New UI shell owns primary navigation and global App Bar.
- A hosted legacy page must not receive a duplicate New UI App Bar.
- Existing legacy pages remain available until the corresponding migrated page has passed its own acceptance gate.
- Migration replaces entries one by one; it does not authorize cleanup of unrelated legacy UI.

## 5. Task 1 Exit Gate

| Gate | Result | Evidence |
|---|---|---|
| Project Specification approved | PASS | `docs/modern-ui/specs/2026-10-07-dsm-helper-modern-ui-spec.md` |
| Global Interface / Protocol Inventory complete | PASS | Task 1 inventory document |
| Global Contract Matrix complete | PASS | Task 1 matrix document |
| Theme / navigation / Legacy fallback boundary clear | PASS | Project Spec + G-THEME-01/02 + G-LEGACY-01 + G-NAV-* |
| No blocking Contract Gap for Task 2 | PASS | No unresolved Product Semantic Gap; technical debts do not affect visual-spec work |
| No blocking Contract Gap for Task 3 | PASS | Required context/theme/intent integration is achievable with thin adapters around existing public authorities |
| No unsupported inference | PASS | Legacy code was inspected; ambiguous product semantics were stopped and explicitly decided |
| No duplicate DSM/session authority introduced | PASS | Documents require reuse of `Api.dsm`, API discovery, Drift persistence and existing Auth/model capabilities |
| No out-of-scope production change | PASS | Task 1 completion changes are documentation-only |
| Full Synology model catalog avoided | PASS | Inventory records common/global boundaries; future feature details remain Feature Contracts |

**Task 1 Exit Gate result: PASS.**

## 6. Verification boundary

Task 1 is documentation/contract work only.

Therefore:

- no production implementation was added;
- no New UI shell/theme was implemented;
- no Task 2 work was started;
- no real-device gate is newly required for these docs;
- repository/PR CI is still required before merge to confirm the branch remains healthy.

## 7. Handoff

Task 1 formally unblocks:

`Task 2 — Visual Design Specification`

Task 2 is **not started by this acceptance**.

Task 3 remains downstream of Task 2 according to the Master Plan. When Task 3 begins, it must inherit the global matrix rather than redefining startup, session, navigation, theme isolation, network/auth, notification, lifecycle, or external-intent semantics.
