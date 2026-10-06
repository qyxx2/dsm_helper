# Task 0 — Foundation / Working Environment Acceptance

> Date: 2026-10-06  
> Branch: `feature/t0-foundation`  
> Legacy source baseline: `dev@8c104e9a783a1acaf366a250e5fcd1d623f14eb2`  
> Integration target: `modern-ui`

## 1. Scope

Task 0 established the project working model, branch baseline, master plan, reproducible Android CI build, development signing path, APK Artifact delivery, and baseline real-device validation.

Task 0 did not redesign the UI or change DSM feature semantics.

## 2. Automated Gate

Final verified development build baseline:

```text
Flutter 3.22.3
Java 17
Kotlin 1.9.22
Android Gradle Plugin 7.2.0
Gradle 7.5
compileSdk 34
targetSdk 33
```

GitHub Actions:

```text
Workflow: Modern UI Android CI
Successful run: #10
Run ID: 37454365753
Commit: 5384aa5a487528af7f6b6281e2fd092db270faa8
Result: success
```

Artifact:

```text
Name: dsm-helper-modern-ui-android-debug
Artifact ID: 11408722401
SHA-256: fb3bacc3f475d07b213f39ef8e9f418af324c578fda1ed7925e6757c6dba3710
```

The later documentation-only run #11 also completed successfully at commit `763ca3e93557b847d3762c423ca54da950177c19`.

Automated checks confirmed:

- dependency resolution succeeds;
- CI does not require the original release signing secret;
- the legacy baseline currently has no executable Flutter tests, and the workflow records this explicitly instead of treating an empty test suite as a false success;
- targeted `flutter analyze` is ready for `lib/new_ui/**` and `test/new_ui/**`;
- beta debug APK builds successfully;
- APK Artifact upload succeeds.

## 3. Real-device Gate

User validation on a real Android device and real Synology DSM environment confirmed:

- APK installs successfully;
- application launches successfully;
- DSM connection succeeds;
- login succeeds;
- Dashboard loads and displays content;
- File Station can browse directories and files;
- main page navigation works without blocking failures.

Result:

```text
PASS
```

## 4. Legacy Baseline Exceptions

### LEGACY-BASELINE-VISUAL-01 — Dark theme graphical defects

The legacy application has multiple visible graphical / rendering problems in dark theme.

Classification:

```text
Legacy baseline visual defect
Non-blocking for Task 0
Do not repair as part of legacy cleanup
```

Reason:

The project goal is to replace the legacy presentation layer with a new Material 3 UI. Repairing the legacy dark theme would not improve the migration foundation and would violate the rule to avoid unrelated legacy cleanup.

Exact visual cases may be catalogued later only when useful for the Material 3 visual specification or for regression comparison.

Other non-fatal legacy bugs observed during real-device use remain baseline behavior unless they block a future Task. They must not be silently attributed to new UI code.

## 5. Final Change Boundary Review

Task 0 final tree changes are limited to:

```text
.github/workflows/android-ci.yml
android/app/build.gradle
android/build.gradle
docs/modern-ui/2026-10-06-dsm-helper-modern-ui-master-plan.md
docs/modern-ui/acceptance/2026-10-06-task-0-foundation-acceptance.md
lib/pages/setting/setting.dart
pubspec.yaml
```

Legacy production behavior was not intentionally redesigned.

The only legacy page source change is a minimal import alias / reference qualification for the existing `Feedback` page to resolve a compiler name collision.

Dependency and Android build changes are limited to versions and settings required to make the imported legacy project build reproducibly in current GitHub Actions.

## 6. Task 0 Exit Gate

- [x] legacy baseline can be referenced precisely;
- [x] `modern-ui` integration branch exists;
- [x] master plan exists;
- [x] development CI triggers automatically;
- [x] CI does not depend on original release signing secrets;
- [x] dependency resolution succeeds;
- [x] automated test behavior is defined;
- [x] Android APK build succeeds;
- [x] APK Artifact is produced;
- [x] real-device install / launch succeeds;
- [x] real DSM connection and login succeed;
- [x] Dashboard baseline succeeds;
- [x] File Station browse baseline succeeds;
- [x] main navigation baseline succeeds;
- [x] legacy visual defects are explicitly classified and recorded.

## 7. Decision

```text
Task 0 ACCEPTED.
feature/t0-foundation is eligible to merge into modern-ui.
Task 1 may start only after that merge is verified.
```
