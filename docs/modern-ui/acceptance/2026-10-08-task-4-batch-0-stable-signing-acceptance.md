# Task 4 Batch 0 — Stable Development APK Signing Acceptance

> Status: PASS  
> Date: 2026-10-08  
> Task: Task 4 — Server / Account / Login / OTP  
> Batch: 0 — Stable Development APK Signing  
> Branch: `feature/t4-server-auth`

## Contract

Implements project contract `APK-IDENTITY-01`.

## Required acceptance properties

- beta/debug user-installable package remains `top.apaipai.dsm_helper`;
- Android CI no longer executes `keytool -genkeypair` for each workflow run;
- CI reconstructs one stable development keystore from GitHub repository secrets;
- keystore/private key is never committed to Git;
- development signing remains independent of the original production signing identity;
- two independent CI runs produce APKs signed by the same certificate;
- the SHA-256 signing certificate fingerprint is recorded here after verification;
- the next real-device Gate must directly install over the previous Modern UI APK without uninstalling it.

## Repository secret contract

Required GitHub Actions repository secrets:

- `MODERN_UI_DEV_KEYSTORE_B64`
- `MODERN_UI_DEV_STORE_PASSWORD`
- `MODERN_UI_DEV_KEY_ALIAS`
- `MODERN_UI_DEV_KEY_PASSWORD`

The secret values are intentionally not recorded in this repository or acceptance record.

## Verification evidence

Pending:

- [x] user confirms the four repository secrets exist;
- [x] workflow no longer generates an ephemeral key;
- [x] CI run 1 succeeds — run #126 / ID `37713701457`, attempt 1;
- [x] CI run 2 succeeds — run #126 / ID `37713701457`, attempt 2;
- [x] package id confirmed as `top.apaipai.dsm_helper` by run #126 identity assertion;
- [x] run 1 signing SHA-256 fingerprint: `0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2`;
- [x] run 2 signing SHA-256 fingerprint matches run 1: `0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2`;
- [x] no keystore/private-key artifact appears in the Batch 0 Git diff; the repository's pre-existing `keystore/file_station.keystore` is unchanged and is not the Modern UI development signing key.

## Stable development certificate fingerprint

User-generated certificate:

`0B:8E:6E:07:65:CF:BA:89:E1:56:F3:03:7B:66:C9:E9:38:2D:91:F7:88:E5:E9:BE:50:51:6D:F0:23:13:D9:A2`

CI run #126 attempt 1 independently reported the normalized equivalent:

`0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2`

Run #126 attempt 2 independently reproduced the same normalized certificate fingerprint and package id. Batch 0 stable-signing Gate is satisfied.

## CI evidence

- Run #126 / ID `37713701457`, attempt 1: success.
- Run #126 / ID `37713701457`, attempt 2: success.
- Package id in both verified runs: `top.apaipai.dsm_helper`.
- Signing certificate in both verified runs: `0b8e6e0765cfba89e156f3037b66c9e9382d91f788e5e9be50516df02313d9a2`.
- Attempt 1 artifact ID: `11522804053`, digest `sha256:4af0d45ffe7a2039dc11a54a859748295c8f53eab4fb080ac53224785fc8fe3b`.
- Attempt 2 artifact ID: `11524996441`, digest `sha256:6ec69f6248362dc49939872edae697d3922e9267530bb98cd1a573edde23f6e9`.

Artifact digests differ because APK build bytes are not required to be bit-for-bit reproducible; install identity is defined by the canonical application id and signing certificate.
