# DSM Helper Modern UI — Task 3 Acceptance

> Task: Task 3 — New UI Foundation / Shell  
> Date: 2026-10-07  
> Integration target: `modern-ui`  
> Task branch: `feature/t3-new-ui-shell`  
> Starting integration HEAD: `a2e26f84cc014980f52743ab006b65523a32ccc6`  
> Accepted task HEAD: `13a99e390353670a5cd9af61ba7a87281bee3c3f`

## 1. Accepted deliverable

Task 3 establishes the Modern UI foundation and shell while preserving legacy behavior through controlled fallback boundaries.

Accepted implementation includes:

- Material 3 New UI theme and system-bar integration;
- five-destination New UI shell;
- primary-page shell structure;
- controlled `LegacyPageHost` fallback;
- legacy theme isolation;
- legacy named-route compatibility inside the host;
- Android Back behavior for shell and hosted legacy navigation;
- launch-auth gate;
- persisted startup resolution;
- active DSM context activation;
- legacy session bridge;
- DSM provider scope handoff for root-overlay and nested legacy routes;
- external share/torrent intent routing;
- shell-global notification fallback;
- bounded app-service endpoint discovery;
- shared legacy `InitData` bootstrap independent of Dashboard mount order;
- active-context keyed provider lifecycle so NAS/account switches do not reuse stale shared state.

Task 3 does not migrate the Task 4 server/login UI or the Task 6 Applications/Settings feature UI.

## 2. Final corrective finding

The final real-device blocker was caused by a hidden legacy bootstrap dependency.

Legacy `Home` mounted `Dashboard` early through its old navigation structure. `Dashboard.getInitData()` therefore acted as an implicit shared authority by:

1. calling `InitDataModel.get()`;
2. populating `InitDataProvider`;
3. publishing `Utils.version`.

The New UI shell mounts legacy fallbacks only when opened. As a result, cold start followed directly by Applications had a valid DSM session but no shared legacy InitData, so the Applications order was empty until Dashboard had been visited once.

The accepted fix introduces one explicit shared bootstrap authority at the New UI shell boundary. Dashboard now reuses that authority instead of owning the shared initialization implicitly.

## 3. Shared bootstrap and context lifecycle acceptance

The accepted lifecycle is:

```text
active DSM context
→ shared legacy bootstrap
→ DSM version synchronized
→ InitDataProvider populated
→ legacy fallback exposed
```

Additional context-switch protection:

- `ActiveContextResult.contextId` is forwarded into `DsmNewUiShell`;
- the DSM provider subtree is keyed by that context ID;
- switching NAS/account destroys the previous context's providers;
- the new context receives a fresh `InitDataProvider`;
- `Utils.version` is synchronized before provider notification;
- no cross-NAS static InitData cache was introduced;
- offline shell startup does not issue an extra shared InitData probe.

## 4. Automated verification

Final accepted CI:

- Workflow: `Modern UI Android CI`
- Run number: `116`
- Run ID: `37624680181`
- Head SHA: `13a99e390353670a5cd9af61ba7a87281bee3c3f`
- Result: **success**

Mechanical gates:

| Gate | Result | Evidence |
|---|---|---|
| Dependency restore | PASS | CI run 116 |
| Full Flutter tests | PASS | **61 tests passed** |
| New UI targeted analysis | PASS | **No issues found** |
| beta debug APK build | PASS | `app-beta-debug.apk` built successfully |
| APK artifact upload | PASS | Artifact ID `11483638463` |
| Shared bootstrap cold-start relationship | PASS | Applications data available without Dashboard mount |
| Context A → B stale-state relationship | PASS | app order and DSM version replaced by B |
| Offline startup relationship | PASS | shell remains offline and no InitData bootstrap probe occurs |
| Legacy theme isolation regressions | PASS | existing relationship tests |
| Named-route compatibility regressions | PASS | existing relationship tests |
| Android Back regressions | PASS | existing shell/legacy relationship tests |

Final APK artifact:

```text
name: dsm-helper-modern-ui-android-debug
artifact id: 11483638463
size: 189969054 bytes
digest: sha256:35ee6836edaa583ff42a2cbf13331dd4bb5e6b0e41d3717df730627157eb2dd8
source HEAD: 13a99e390353670a5cd9af61ba7a87281bee3c3f
```

## 5. Real-device Gate

User real-device revalidation completed successfully after CI run 116.

Confirmed behavior includes:

- APK installs and launches;
- cold start restores the active NAS context;
- cold start → do not open Dashboard → directly open Applications → application list is populated normally;
- legacy fallback remains usable;
- Back/navigation behavior remains normal;
- no reported regression in the requested Task 3 device checks.

**Task 3 real-device Gate result: PASS.**

## 6. Scope and boundary acceptance

Final corrective work remained bounded to the shared-bootstrap problem.

The final corrective diff did not redesign or migrate:

- Applications;
- Application item behavior;
- LegacyPageHost navigation semantics;
- named-route registry semantics;
- Material 3 visual tokens;
- File Station behavior;
- Task 4 server/account/login UI;
- Task 6 Applications/Settings UI.

The required legacy Dashboard edit is limited to removing its hidden ownership of shared InitData initialization and delegating that shared step to the new bootstrap authority. Dashboard-specific polling and widgets remain Dashboard-owned.

## 7. Task 3 Exit Gate

| Gate | Result |
|---|---|
| New Material 3 shell exists | PASS |
| Five primary destinations exist | PASS |
| New primary page can be entered | PASS |
| Multiple legacy fallbacks can be entered | PASS |
| Material 3 / legacy Theme isolation | PASS |
| Legacy named routes remain usable inside hosted fallback | PASS |
| Android Back behavior remains deterministic | PASS |
| Startup/session/context bridge is production-wired | PASS |
| Shared providers survive hosted fallback boundaries | PASS |
| Shared legacy InitData no longer depends on Dashboard mount order | PASS |
| NAS/account context lifecycle prevents stale shared provider reuse | PASS |
| Offline startup semantics preserved | PASS |
| Automated tests pass | PASS |
| Targeted analysis passes | PASS |
| Android beta debug APK builds | PASS |
| Artifact generated | PASS |
| Required real-device checks pass | PASS |
| No Task 4 / Task 6 implementation entered | PASS |

**Task 3 Exit Gate result: PASS.**

## 8. Post-acceptance APK identity rule

After Task 3 real-device acceptance, a project-wide Android build requirement was added to the Master Plan:

`APK-IDENTITY-01 — Stable install/update identity`

Future user-installable APKs must keep one stable package/application ID and one stable development signing identity so new artifacts can be installed directly over the previous build without uninstalling it.

This rule is prospective and does not invalidate Task 3's functional acceptance. The historical Task 0/Task 3 CI used an ephemeral development signing key; that mechanism must be replaced before the next user-facing APK Gate.

## 9. Handoff

Task 3 — New UI Foundation / Shell is **complete and accepted on its task branch**.

Task 4 — Server / Account / Login / OTP is technically unblocked, but no Task 4 implementation is started by this acceptance record.

Branch integration into `modern-ui` remains a separate finishing action under the repository branch/PR workflow.
