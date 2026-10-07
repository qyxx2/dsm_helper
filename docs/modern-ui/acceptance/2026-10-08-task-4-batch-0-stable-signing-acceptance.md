# Task 4 Batch 0 — Stable Development APK Signing Acceptance

> Status: In progress  
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

- [ ] user confirms the four repository secrets exist;
- [ ] workflow no longer generates an ephemeral key;
- [ ] CI run 1 succeeds;
- [ ] CI run 2 succeeds;
- [ ] package id confirmed as `top.apaipai.dsm_helper`;
- [ ] run 1 signing SHA-256 fingerprint recorded;
- [ ] run 2 signing SHA-256 fingerprint matches run 1;
- [ ] no keystore/private-key artifact appears in Git diff.

## Final certificate fingerprint

Pending.
