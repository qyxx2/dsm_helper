# Task 7B Batch 1 — Operation Authority & Safety Acceptance

> **Result: PASS — automated B1 Exit Gate only (2026-10-13).**  
> Repository: `qyxx2/dsm_helper` · branch: `feature/t7b-file-operations`  
> B1 base: `2b6e2020fc275c525a50cbf306e5ed355bc31693` (planning-only).  
> **Final implementation HEAD:** `f24e00950b16698570ff4a642d32736c25ba6ec0`.  
> **Final code CI:** Modern UI Android CI **#355**, run **`38244000842`**, `completed / success`, on exactly that SHA.  
> **No live DSM file operation was executed or claimed as verified.** B1 creates detached contracts and adapter seams only; no Modern/legacy page uses these new actions.

## 1. Completed B1 steps and authority finding

- **1.1 — Preflight:** Audited Task 7B Feature Design, Batch Plan, Contract Matrix and Task 7A B5 acceptance, then read `DsmApi.entry`, `Utils.post`, `LegacySessionBridge`, login/server session handoff, File Station legacy models/API methods, Task 7A browse controller and CI.
- **1.2 — RED:** Added behavior tests for immutable exact-path targets, duplicate names/copied model objects, missing/unloaded/partial paths, root/current-folder exclusion, nullable/read-only ACL, special paths, action cardinality, context switch/disposal, DSM 119 vs Dio failures, actual method/version/payload and task-id/link response separation.
- **1.3 — GREEN:** Added `FileOperationSelection`, `FileOperationTarget`, `FileOperationEligibility` and `FileOperationDataSource` under `lib/new_ui/files`. Selection is an immutable snapshot of *selected loaded entries*, preserving DSM paths and `contextId`; ineligible actions are rejected before any request. A `production` adapter captures the current `Api.dsm` instance/SID/host and requires an active-context guard. It drops late results after context invalidation/disposal and signals DSM 119 at most once. Separate results distinguish immediate ack, a server-created share link and accepted nonempty task ID.
- **1.4 — Verification:** All added contract/adapter tests passed inside the final complete CI test suite; targeted `lib/new_ui` / `test/new_ui` analyze passed. A *separate invocation* of the plan's two-file targeted Flutter command was **not executed** because this assistant environment does not contain Flutter/Dart. Full `flutter test` includes both new test files.
- **1.5 — Scope:** Checked final remote diff from B1 base: **9 commits ahead, 0 behind, exactly 4 new files** (below). No Shell, legacy code, workflow, Android build, dependencies, or other Tasks changed. No operations were added to a visible user path.

**Authoritative session finding:** `Api.dsm.entry` uses the currently bound `DsmApi` transport, its SID, base URL, SSL/Dio configuration and typed `DsmException`/Dio errors. `DsmApi.entry` unconditionally supplies `body['_sid'] = sid`, so B1 must **not** pass `Utils.sid` as a separate data field. By contrast `Utils.post` constructs another Dio instance using mutable `Utils.baseUrl`, `Utils.cookie`, `Utils.sid`; its Dio failures are converted to generic `success:false` maps. `LegacySessionBridge` updates the globals at ordinary login/session handoff, but synchrony must not be presumed across A→B or in-flight calls. **B1 uses only `Api.dsm.entry` with explicit action/method/version/payload and guards the bound instance.** No new SID cache, HTTP transport or authentication authority was introduced.

### Literal request-shape comparison with existing legacy code

| Action | DSM family, method, version | Existing payload fields retained in B1 |
| --- | --- | --- |
| Rename | `SYNO.FileStation.Rename / rename / 2` | `path: '"<path>"'`, `name: '"<name>"'`. |
| Create folder | `SYNO.FileStation.CreateFolder / create / 2` | `force_parent: "false"`, quoted `folder_path` and `name`. |
| Delete start | `SYNO.FileStation.Delete / start / 2` | JSON array `path`, `accurate_progress: "true"`; nonempty `taskid` means *started/accepted*, not deleted. |
| Favorite add / delete | `SYNO.FileStation.Favorite / add|delete / 2` | Exact `path`; add name `<item name> - <share>`, no guessed local membership. |
| Ordinary share link | `SYNO.FileStation.Sharing / create / 3` | JSON `path` array; no `file_request` field (equivalent to legacy `fileRequest:false`). Response must include a nonempty actual `links[0].url`. |
| Copy / move start | `SYNO.FileStation.CopyMove / "start" / 3` | `overwrite:"true"`, exact JSON `path`, `dest_folder_path`, `accurate_progress:"true"`; `remove_src=false` for copy, `true` for move. **Adapter seam only, not approved live dispatch/UI.** |

The adapter sends `api`, `method`, `version` and payload to `DsmApi.entry`; that method owns the live `_sid` on the canonical transport. Unit tests recorded exact supplied fields using injectable fakes and a recording `DsmApi`.

## 2. RED → GREEN and final CI evidence

| Stage | Commit / GitHub CI | Observed result |
| --- | --- | --- |
| Tests/RED | `393f4b624254c2bc191e076c553ad5625fd2c80b` / **#345**, run `38242019894` | `completed / failure`; **371 tests passed, 13 failed** because `FileOperationSelection.capture` / the production adapter were unimplemented. This is a missing-behavior RED, not a test syntax or fixture compilation failure. |
| GREEN implementation | Subsequent B1 commits through `f24e00950b16698570ff4a642d32736c25ba6ec0` | Added immutable policy, active `DsmApi` adapter, return/error taxonomy, root and read-only regression cases. The final edit removed a redundant `DsmResponse` import flagged by analyzer, without changing feature semantics. |
| Final GREEN | **#355**, run `38244000842`, source **`f24e00950b16698570ff4a642d32736c25ba6ec0`** | `completed / success`. **Full `flutter test`: 386 passed** (including 15 new B1 tests); `flutter analyze lib/new_ui test/new_ui`: **No issues found**; `flutter build apk --debug --flavor beta`: **success**; package/signature verification and APK upload: **success**. |

[RED CI #345](https://github.com/qyxx2/dsm_helper/actions/runs/38242019894) · [Final GREEN CI #355](https://github.com/qyxx2/dsm_helper/actions/runs/38244000842)

**Final artifact:** `dsm-helper-modern-ui-android-debug`, artifact ID **`11745020138`**, [GitHub Actions artifact](https://github.com/qyxx2/dsm_helper/actions/runs/38244000842/artifacts/11745020138). GitHub artifact digest: `sha256:682e3970e700b93bedd5b38e661c19e51ee8ca098bafc0c650a57e2239e5ba74`. Package: `top.apaipai.dsm_helper`. Fixed development certificate SHA-256: `0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2`. This is CI identity evidence; it does not assert a new physical overlay-install test.

## 3. Files and acceptance boundary

Exactly these four added files relative to `2b6e2020`:
```text
lib/new_ui/files/file_operation_contract.dart
lib/new_ui/files/file_operation_data_source.dart
test/new_ui/files/file_operation_contract_test.dart
test/new_ui/files/file_operation_data_source_test.dart
```

**Closed at the B1 foundation:** `T7B-OPS-01` (selected loaded, immutable exact-path/context targets), `T7B-OPS-02` (canonical live session/DSM action request & result types), `T7B-OPS-03` (eligibility/cardinality/nullable ACL preflight), and B1 error-state/119 foundation. No new user-facing actions, route changes, writes or background job polling.

**Not tested / not authorized by B1:** real DSM rename/create/delete/favorite/share/CopyMove; actual remote access grants and task completion; A→B concurrent live NAS stress; remote/virtual `scheme://` mutation; overwrite behavior; live Android/DSM UI and physical upgrade installation. These require their owning later Batch/Gate. Current adapter availability **is not permission** to enable destructive UI: B4 controls delete confirmation/task-start semantics; B5 **still BLOCKED** until user-approved collision/overwrite policy and expendable real-DSM verification. B2 search, B3 favorite/link UI, B6 integration and Task 7C remain unstarted by this acceptance.

**Known constraints:** Nullable/missing ACL yields server-check-required, never a fabricated grant; inferred permissions cannot substitute for the DSM response. Raw quoted legacy name/path representation was preserved as requested; no independent live DSM proof for names containing literal quotation characters. A request already sent before account change cannot be remotely canceled; only its local completion is suppressed. Future UI owners must pass the real active `contextId`/guard and invalidate on disposal. Special/virtual paths remain blocked.

**B1 Exit Gate: PASS (automated, detached adapter scope).** **Real-device Gate: NOT REQUIRED** for this unmounted non-user-path B1; no additional test is being silently counted. This record is documentation-only under `CI-DOCS-01`, and does not replace source HEAD/CI #355. **STOP: do not start B2, merge, or perform live file writes under this authorization.**
