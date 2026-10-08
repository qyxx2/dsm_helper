# Task 4 Batch 1 — Persistence / TLS / Context Foundation Acceptance

> Status: PASS  
> Date: 2026-10-08  
> Task: Task 4 — Server / Account / Login / OTP  
> Batch: 1 — Persistence, TLS and Context Foundation  
> Branch: `feature/t4-server-auth`

## Contracts

- `T4-ACC-02`
- `T4-TLS-01`
- `T4-DEL-01`
- supports `T4-SESS-01`

## TDD evidence

### Persistence RED

Commit:

`6f46213a9b511e671f972be02770e635de7ee458`

GitHub Actions run #127 / ID `37718574293`: expected failure.

The test suite failed because the desired interfaces did not yet exist:

- `lib/new_ui/auth/server_account_store.dart` missing;
- `ServerAccountStore` missing;
- `Database.forTesting` missing.

### Persistence GREEN

Commit:

`ed55eb9ea6c880eaf7d2e818e6eb22b6463fbc3e`

Implemented only the tested persistence foundation:

- `Database.forTesting(QueryExecutor)` for real in-memory Drift tests;
- corrected `deleteAccountByServerId` to filter on `accounts.serverId`;
- minimal `ServerAccountStore`;
- transactional Server delete;
- transactional unique-default set;
- zero-default clear;
- rollback when default target does not exist.

Run #128 / ID `37718749769`: success.

### TLS RED

Commit:

`8419c4f356835edd7b501ea11d1ea2f882acc45d`

GitHub Actions run #129 / ID `37718967182`: expected failure.

The test suite failed on the deliberately missing feature contract:

- `StartupSavedContext.checkSsl`;
- `ActiveContextRequest.checkSsl`;
- `DsmApi(checkSsl: ...)`;
- injectable `DsmActiveContextAdapter` discovery/probe actions.

### TLS GREEN

Commit:

`85220aee17cf6aa81209385e87f8783d33988fb3`

Implemented the minimum per-Server TLS propagation:

```text
Server.checkSsl
→ LegacyStartupAdapter
→ StartupSavedContext
→ ActiveContextRequest
→ DsmActiveContextAdapter
→ DsmApi
→ HttpUtil / per-instance IOHttpClientAdapter
```

Behavior:

- `checkSsl=true` keeps Dio's normal system certificate validation;
- `checkSsl=false` installs a permissive certificate callback only on that `DsmApi` instance;
- no global DSM TLS bypass was introduced;
- `main.dart` / `ExtendedNetworkImageProvider` certificate handling was not changed.

## Final automated Gate

GitHub Actions:

- workflow: `Modern UI Android CI`
- run number: `130`
- run ID: `37719176272`
- head: `85220aee17cf6aa81209385e87f8783d33988fb3`
- conclusion: `success`

Verified steps:

- [x] stable signing key restored;
- [x] dependencies resolved;
- [x] complete `flutter test` step passed;
- [x] targeted new UI analyze passed;
- [x] Android beta debug APK built;
- [x] package id assertion passed: `top.apaipai.dsm_helper`;
- [x] signing certificate assertion passed: `0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2`;
- [x] artifact uploaded.

Artifact:

- ID: `11525193522`
- name: `dsm-helper-modern-ui-android-debug`
- digest: `sha256:d3ef57f7b8e95d42a43ffafdeaed99d9de25376fab3000bf76ce3fffb97fd6b9`

## Diff boundary

Compared with Batch 0 accepted HEAD `eb6c90d0866ae82ebf7a95f1eef9e15e331aca4e`, Batch 1 changed only:

- DSM transport TLS plumbing;
- Task 3 active-context/startup TLS propagation;
- the confirmed legacy account-delete predicate bug;
- the narrow Task 4 persistence store;
- relationship/unit tests for those contracts.

No QuickConnect work, schema migration, credential-storage rewrite, unrelated legacy cleanup, or Task 5 implementation was included.

## Exit Gate

**PASS**

- Server delete cascade is executable and proven.
- Default-account uniqueness and zero-default behavior are executable and proven.
- Per-Server `checkSsl` reaches the actual DSM transport instance.
- Existing Task 3 startup/session behavior remains green.
- Full CI including APK build and stable install identity is green.

Task 4 may proceed to Batch 2 — Login / OTP / Reauthentication Controller.
