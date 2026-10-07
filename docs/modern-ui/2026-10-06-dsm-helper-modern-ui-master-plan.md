# DSM Helper Modern UI — Master Plan

> Status: Active  
> Created: 2026-10-06  
> Repository: `qyxx2/dsm_helper`  
> Legacy baseline: `dev@8c104e9a783a1acaf366a250e5fcd1d623f14eb2`  
> Integration branch: `modern-ui`  
> Initial working branch: `feature/t0-foundation`

## 1. Goal

在现有 DSM Helper 项目的成熟实现之上新增一套统一、现代、面向 Android 的 Material 3 UI。

本项目不是一次架构重构。默认原则是：

- 现有 DSM API、Model、Provider、Database、Utils 和业务逻辑能直接复用就直接复用。
- 现有 UI 在迁移期间保留，作为行为参照和尚未迁移页面的 fallback。
- 新 UI 与旧 UI 并行存在，逐页替换入口。
- 没有真实阻塞、明确 bug 或新功能需求时，不主动修改旧实现。
- 不为了“架构漂亮”引入 Repository、Bloc/Riverpod、SDK 重写或大规模目录重构。
- 新功能优先新增在新 UI / 新功能目录；如需接旧实现，只做完成目标所需的最小改动。

最终目标不是清理旧项目，而是以最小风险获得：
1. 一套统一的 Material 3 视觉体系。
2. 更合理的信息密度、字体和控件尺寸。
3. 保留当前成熟 DSM 能力。
4. 后续可以继续扩展新功能。
5. 每一步都可构建、可实机验证、可回滚、可追溯。

---

## 2. Repository Baseline

当前仓库已确认存在：

- `dev`
- `master`

二者已发生分叉，当前比较结果为：

- `dev` ahead of `master`: 87 commits
- `dev` behind `master`: 13 commits

因此本项目禁止在开始阶段对 `master` / `dev` 做整理性 merge、rebase 或历史重写。

本项目冻结的 legacy source baseline：

```text
dev@8c104e9a783a1acaf366a250e5fcd1d623f14eb2
```

后续新 UI 开发以 `modern-ui` 为唯一稳定集成线。

---

## 3. Change Boundary

### 3.1 默认冻结区域

除非某个已确认需求或 blocker 必须修改，否则以下区域保持原行为：

```text
lib/apis/**
lib/models/**
lib/database/**
lib/providers/**
lib/utils/**
lib/pages/**          # legacy UI
```

“冻结”表示默认不改，不表示绝对禁止修改。

允许修改 legacy 区域的条件只有：

1. 新 UI 无法复用现有功能且没有更小的接入方式。
2. 真实构建阻塞。
3. 真实功能 bug 阻塞当前 Task。
4. 新功能明确需要 legacy 层提供最小新入口。
5. 安全或兼容性问题使当前功能无法继续使用。

任何此类修改都必须：
- 明确说明 blocker。
- 只改最小范围。
- 不顺带重构相邻代码。
- 有对应回归验证。

### 3.2 新代码优先区域

```text
lib/new_ui/**
test/new_ui/**
docs/modern-ui/**
.github/workflows/**
```

必要时允许对：
- `lib/main.dart`
- Android 构建文件
- 路由/启动接线

做最小修改。

---

## 4. Working Model

GitHub 是唯一正式代码事实源。

### Assistant responsibilities

- 读取远端仓库真实状态。
- 制定 Task / Batch / Contract。
- 创建工作分支。
- 直接修改远端代码。
- 检查真实 diff。
- 使用小而清晰的 commit。
- 提交后再次读取远端 commit，确认 SHA 和实际修改范围。
- 创建 PR。
- 检查 GitHub Actions。
- 查看失败 job/log。
- 修复能够远端确定的问题。
- 检查 APK Artifact 是否成功生成。
- 对可自动验证内容完成自动验收。

### User responsibilities

本地环境主要用于真实设备 / 真实 DSM 验证，不作为正式修改源。

建议工作方式：

```text
git pull
→ Android Studio / ARM64 Ubuntu
→ 安装 GitHub Actions APK
→ 连接真实 DSM
→ 实测
→ 报告结果 / 截图 / 行为差异
```

除非另行约定，本地不承担正式源码修改。

### Verification split

Assistant / CI 负责：
- diff 范围
- commit / branch / PR 状态
- dependency resolution
- unit test
- widget test
- new UI static analysis
- Android APK build
- Actions logs
- Artifact 生成
- 能在 CI 中机械验证的 contract

User real-device validation 负责：
- APK 安装和启动
- LAN DSM 连接
- 登录 / SID
- OTP / 2FA
- QuickConnect
- 自签名 HTTPS
- File Station 真实行为
- Docker / Storage / VMM / Package 等真实 DSM 行为
- Android 返回键、键盘、系统栏、生命周期
- 视觉密度、动画、手感
- 真机分辨率和系统缩放表现

核心原则：

> CI 证明代码成立；实机验证证明产品成立。

---

## 5. Branch / Commit / PR Rules

稳定集成线：

```text
modern-ui
```

每个实现单元：

```text
feature/<task-or-batch>
        ↓
small atomic commits
        ↓
PR → modern-ui
        ↓
CI
        ↓
real-device gate when required
        ↓
merge
```

规则：

1. 每个 Task / Batch 使用独立 branch。
2. 禁止直接在 `dev` / `master` 上开发。
3. 禁止无关格式化或 cleanup 混入功能 commit。
4. 每次提交后二次核对远端真实 commit。
5. PR 合并前检查 changed files 与计划边界。
6. 若实机 Gate 未通过，不合并依赖该实机行为的 Task。
7. 后续 Task 只依赖已通过 Gate 的前置 Task。

---

## 6. Contract Strategy

本项目使用轻量合同体系，不复制 MPD-Server 的重型流程。

合同分两层。

### Layer A — Global Contracts

Task 1 一次性冻结后续所有新 UI 共同依赖的公共行为，例如：

- DSM request
- batch request
- stream
- API discovery
- login / logout / OTP
- DSM session
- server/account persistence
- shared providers
- legacy page fallback
- theme isolation
- navigation handoff

### Layer B — Feature Contracts

每个具体 Feature Task 开始前，仅冻结该功能真正使用的 legacy 能力。

例如 File Task 只冻结：
- list
- path navigation
- search
- rename
- delete
- share
- upload/download
- background tasks

禁止为了“完整”提前把整个 `models/Syno/**` 建成庞大合同库。

### Contract Gap rule

遇到旧实现行为不明确时：

1. 优先读取当前 legacy code。
2. 若代码本身就是当前产品事实行为，则将“保持 legacy 行为”冻结。
3. 若存在多个互相冲突实现或无法判定的产品语义，标记 Contract Gap。
4. Contract Gap 不得由实现阶段自行猜测。
5. 只有会阻塞当前 Task 的 Gap 才需要在当前阶段解决。

---

## 7. Project Tasks

## Task 0 — Foundation / Working Environment

### Objective

建立稳定、可追溯、远端优先的开发和验证循环，不修改 DSM 功能或新 UI 产品行为。

### Steps

#### T0.1 Baseline Freeze

- 冻结 `dev@8c104e9a783a1acaf366a250e5fcd1d623f14eb2`。
- 保留原 `master` / `dev`。
- 创建 `modern-ui`。
- 创建 Task 0 工作分支。
- 建立永久可引用的 legacy baseline 标识；优先 tag，若当前远端工具不能安全创建 tag，则保留等价 immutable baseline reference 并记录。

#### T0.2 Create Master Plan

创建本文件作为新 UI 项目唯一主计划：

```text
docs/modern-ui/2026-10-06-dsm-helper-modern-ui-master-plan.md
```

后续 Task 状态和重大边界变化必须回写本 Plan，不另建竞争性总计划。

#### T0.3 Freeze Workflow Rules

在本 Plan 中冻结：
- branch 模型
- commit / PR 规则
- assistant / user 测试职责
- legacy change boundary
- CI / real-device Gate

#### T0.4 Development CI

建立独立的开发 CI，不依赖原作者发布 secrets。

至少验证：

```text
checkout
→ fixed Java
→ fixed compatible Flutter
→ flutter pub get
→ flutter test
→ new UI targeted analyze when directory exists
→ Android development APK build
→ upload APK artifact
```

CI 必须能够被 feature PR 触发。

#### T0.5 Build Baseline Compatibility

当前已知与 Task 0 实测基线：
- `pubspec.yaml`: Dart SDK `>=3.4.3 <4.0.0`
- legacy release workflow: Flutter `3.13.6`
- Task 0 development CI: Flutter `3.22.3`
- Java: `17`
- Android Gradle Plugin: `7.2.0`
- Gradle: `7.5`
- Kotlin: `1.9.22`（与 `background_downloader 8.5.2` Android plugin 对齐）
- compileSdk: `34`
- targetSdk: `33`
- Android build 原本依赖 `android/key.properties`，CI 使用临时 development keystore
- legacy `test/widget_test.dart` 没有可执行测试，因此 Task 0 CI 在没有真实测试时明确记录并跳过；一旦新增测试则执行 `flutter test`
- 为避免无 lockfile 导致的 2026 依赖漂移，Task 0 仅锁定已实际导致 baseline build 失败的关键依赖版本
- Flutter Maven repository 使用 canonical `https://storage.googleapis.com/download.flutter.io`

Task 0 已通过实际 CI 找到“最少改 legacy code”的可构建组合。

优先目标仍是兼容当前 Dart 约束和 Android 工程，而不是无条件升级到最新 Flutter。

#### T0.6 Development Signing / APK Artifact

开发 APK 构建不得依赖原作者私有 signing secret。

目标：
- Development APK 可由 Actions 独立生成。
- 不改变生产签名语义。
- 尽量允许新版与原版同时安装，若需要 package/application ID 区分则只做构建层最小调整。
- APK 作为 Actions Artifact 保存。

#### T0.7 Baseline Real-Device Gate

用户使用 ARM64 Ubuntu / Android Studio / Android 真机验证 baseline development APK。

至少检查：

```text
install / launch
server selection/add
DSM connect
login
dashboard
File Station basic browse
basic navigation
```

若 baseline 本身存在问题，记录为 `LEGACY-BASELINE` issue，不自动归因于后续新 UI。

### Task 0 Exit Gate

必须同时满足：
- baseline reference 可明确回溯。
- `modern-ui` 存在。
- Master Plan 已提交。
- 开发 CI 可自动触发。
- CI 不依赖原作者发布 secret。
- dependency restore 成功。
- automated tests 成功。
- APK build 成功。
- APK Artifact 可取得。
- baseline 实机基本流程通过，或已有明确 legacy exception 记录。

---

## Task 1 — Project Specification + Legacy Interface / Protocol Freeze

### Objective

在开始新 UI 实现前，建立唯一项目规格书，并冻结新 UI 需要依赖的 legacy 公共接口、协议和全局合同。

Task 1 只定义“我们要做什么”和“新 UI 可以依赖什么”，不进行大规模 legacy 重构。

### Required Deliverables

#### T1.1 Project Specification

创建唯一项目规格书，例如：

```text
docs/modern-ui/specs/2026-10-xx-dsm-helper-modern-ui-spec.md
```

规格书至少定义：

- 产品目标和非目标。
- Android / Flutter 平台范围。
- legacy implementation reuse policy。
- legacy UI fallback policy。
- 新 UI 总体导航信息架构。
- 主要 Feature 范围。
- 新 UI 与 legacy 页面共存规则。
- Light / Dark 基础要求。
- Android 系统交互要求。
- 数据与状态来源原则。
- 错误、loading、empty、offline 的产品语义。
- DSM session / reconnect 对 UI 的可见语义。
- 扩展功能的边界。
- 明确不进行的重构。
- 兼容性边界和最低支持范围。
- 测试与验收层级。

规格书是后续视觉规范、Feature Contract 和实现决策的产品级权威来源。

#### T1.2 Global Interface / Protocol Inventory

实际读取并核对：
- `lib/apis/**`
- `lib/models/**`
- `lib/providers/**`
- `lib/database/**`
- login / server / home / dashboard 关键 legacy page
- Android / Flutter 启动路径

识别新 UI 公共依赖。

#### T1.3 Global Contract Matrix

创建轻量全局矩阵，至少包含：

```text
ID
Capability
Legacy authority
Input
Success result
Failure semantics
New UI usage
Must remain unchanged
Validation
```

第一批至少覆盖：
- AUTH login/logout/OTP
- DSM entry/batch/stream
- API discovery/version
- server/account persistence
- session setup
- common providers
- legacy navigation fallback
- Material 3 / legacy theme isolation

#### T1.4 Freeze UI/Legacy Isolation Contract

必须明确：
- 新 Material 3 Theme 不得意外污染尚未迁移的 legacy page。
- legacy page 从 new UI 打开时保留原可用视觉/行为。
- 新页面逐一替换 legacy entry。
- 对应新页面实机验收前不删除 legacy page。

### Task 1 Exit Gate

- 项目规格书完成。
- Global Contract Matrix 完成。
- 无阻塞 Task 2/3 的未解决 Contract Gap。
- legacy 公共调用边界已经足够支持新 UI Foundation。
- 不要求完整冻结全部 Synology Model。

---

## Task 2 — Visual Design Specification

### Objective

冻结 Material 3 新 UI 的唯一视觉规范，解决原 UI 的不统一、字体/控件偏大和信息密度低问题。

### Freeze

- ColorScheme
- Typography
- spacing scale
- radius
- elevation/surface
- icon policy
- NavigationBar
- TopAppBar
- cards
- list density
- buttons
- forms
- dialogs
- bottom sheets
- loading/empty/error states
- light/dark
- Android system bars
- adaptive/responsive rules
- system font scaling behavior

### Exit Gate

新页面不再自行决定基础字号、padding、radius、颜色和列表高度。

---

## Task 3 — New UI Foundation / Shell

### Scope

- `lib/new_ui/**` 基础目录。
- Material 3 Theme。
- New App Shell。
- New Home / NavigationBar。
- LegacyPageHost / legacy fallback。
- Theme isolation。
- 必要的路由接线。
- 暂不大规模替换 feature 页面。

### Exit Gate

可以从新 Material 3 Shell 进入至少一个新页面和多个 legacy fallback 页面，且两套 Theme 不互相污染。

---

## Task 4 — Server / Account / Login / OTP

### Scope

重做：
- server selection
- add/edit server
- account selection
- login
- OTP/2FA

直接复用现有：
- server database
- API discovery
- Auth
- DsmApi
- QuickConnect behavior（能直接复用的部分）

### Gate

真实 DSM：
- LAN
- HTTPS
- login
- OTP if available
- account persistence

---

## Task 5 — Dashboard

### Scope

第一套完整的新核心页面。

复用现有：
- System
- Utilization
- Storage
- Notify
- CurrentConnection
- TaskScheduler
- providers / batch calls

重点验证新视觉的信息密度和整体方向。

---

## Task 6 — Applications Hub + Settings Shell

### Scope

- 新 Applications 聚合页。
- 新 Settings 主页面。
- 功能详情可暂时跳转 legacy page。
- 建立后续模块迁移入口。

此 Task 不要求重做所有应用详情。

---

## Task 7A — File Station: Browse Foundation

### Scope

- share/root list
- directory navigation
- file list/grid
- breadcrumb/path
- sorting
- selection foundation

仅冻结本批实际需要的 File contracts。

---

## Task 7B — File Station: File Operations

### Scope

- search
- select
- rename
- delete
- favorite/share
- move/copy where already supported

不改变 legacy backend semantics。

---

## Task 7C — File Station: Transfer / Preview / Background Tasks

### Scope

- upload
- download
- background task status
- media/file preview entry
- external share intent related entry when needed

完成 File Station 主要新 UI 替换。

---

## Task 8 — Transfer

### Scope

- new transfer overview
- upload/download status
- transfer settings
- reuse existing transfer implementation

---

## Task 9 — Resource Monitor + Storage

### Reason for grouping

二者共享大量系统资源、容量和监控数据语义，视觉上也共享 chart / metric / capacity components。

### Scope

- resource overview
- CPU / memory / network / disk charts
- storage pool / volume / disk / cache presentation

必要时可拆为 T9A / T9B。

---

## Task 10A — Docker / Container Manager: Containers

### Scope

- host overview
- container list
- status
- start/stop/restart/reset/delete

---

## Task 10B — Docker / Container Detail

### Scope

- overview
- logs
- processes
- detail actions

---

## Task 10C — Docker / Container Manager: Advanced

### Scope

- projects
- images
- network
- registry
- project detail

根据实际工程量允许继续细分。

---

## Task 11 — Package Center + Download Station

二者属于相对独立、已有成熟 legacy 实现、适合直接换皮的功能模块。

如果实现量超出单批限制，拆为 T11A / T11B。

---

## Task 12 — Virtual Machine Manager

### Scope

- summary
- guest
- host
- storage
- network
- image/log
- supported power actions

---

## Task 13A — Control Panel: Read / Overview

优先迁移低风险、只读或信息型页面。

---

## Task 13B — Control Panel: Mutation

迁移修改型功能：
- shared folder
- network/settings
- task actions
- services
- other supported mutations

每类 mutation 必须先有 feature contract。

---

## Task 14 — Photos / Moments / Media / Secondary Features

包含优先级较低、与核心 NAS 管理路径依赖较少的模块。

根据最终产品需求可继续细分或延后。

---

## Task 15 — Final Cutover / Legacy UI Retirement

### Scope

- 检查所有主导航是否指向 new UI。
- legacy pages 不再作为默认入口。
- 保留必要 fallback。
- 删除确认无引用且无回退价值的 legacy UI 必须单独审计，不是默认动作。
- 最终 Android regression。
- 建立后续 feature expansion 入口和规则。

---

## 8. Dependency Graph

```text
T0 Foundation
  ↓
T1 Spec + Contracts
  ↓
T2 Visual Spec
  ↓
T3 New UI Shell
  ├────────→ T4 Server/Login → T5 Dashboard → T9 Resource/Storage
  │
  ├────────→ T6 Apps/Settings → T10 Docker
  │                        ├→ T11 Package/Download
  │                        ├→ T12 VMM
  │                        └→ T13 Control Panel
  │
  ├────────→ T7A File Browse → T7B File Ops → T7C File Transfer → T8 Transfer
  │
  └────────→ T14 Secondary Features

Validated feature set
  ↓
T15 Final Cutover
```

T4 并非所有 Feature 的硬技术依赖，但它是完整真实登录链路和新 UI 产品路径的重要 Gate，因此涉及真实 DSM 数据的新核心页面应优先在 T4 通过后验收。

---

## 9. Per-Feature Execution Template

每个 Feature Task / Batch 固定执行：

1. 读取当前远端真实代码和前置 Task 状态。
2. 读取本 Master Plan、Project Spec、Visual Spec。
3. 阅读对应 legacy page / model / provider / api。
4. 列出本 Feature 实际依赖。
5. 创建/更新 Feature Contract rows。
6. 检查 Contract Gap。
7. Gap 不阻塞则只实现当前范围。
8. 优先新增 `lib/new_ui/**`。
9. legacy 修改只在 blocker 情况下做最小 patch。
10. 自动测试。
11. GitHub Actions APK build。
12. diff / commit / remote SHA 二次确认。
13. 需要真实 DSM 或视觉验证时进入用户实机 Gate。
14. Gate 通过后 PR merge。

---

## 10. Scope Control Rules

禁止默认执行：

- 重写 DSM SDK。
- 全局 Model 重构。
- Provider → Riverpod / Bloc 等状态管理迁移。
- Drift database 重构。
- 全量 legacy static warning cleanup。
- 旧 UI 统一格式化。
- 与当前 Task 无关的 legacy bug cleanup。
- 为“现代化”无条件升级所有依赖。
- 未完成新页面前删除旧页面。
- 单个 Task 同时迁移多个大型无关 Feature。

若某 Task 实际范围明显超出可安全一次处理的上下文，则必须先拆 Batch，不允许硬做成单次大提交。

---

## 11. Definition of Done

一个新 UI Feature 被视为完成，需要：

- 对应合同已冻结。
- 功能范围与 legacy 行为一致，除非规格书明确改变。
- 自动测试通过。
- APK 构建通过。
- diff 无越界修改。
- 远端 commit 已二次确认。
- 需要真实 DSM 的行为已经实机验证。
- 需要视觉验收的页面已经真机确认。
- legacy fallback / replacement 状态已明确。
- Master Plan 状态已按需更新。

---

## 12. Current Status

### Completed

- Repository imported to GitHub.
- Legacy source baseline selected: `dev@8c104e9a783a1acaf366a250e5fcd1d623f14eb2`.
- Immutable-equivalent baseline branch created: `legacy-baseline-2026-10-06`.
- `modern-ui` integration branch created.
- `feature/t0-foundation` Task 0 branch created.
- Master Plan created.
- Development CI created and verified.
- Development CI no longer depends on original release signing secrets.
- Compatible baseline verified: Flutter 3.22.3 / Java 17 / Kotlin 1.9.22 / AGP 7.2.0 / Gradle 7.5 / compileSdk 34.
- Dependency restore gate passed.
- Legacy automated-test gate behavior verified; current legacy baseline contains no executable Flutter tests.
- New UI targeted analyze gate verified.
- Android beta debug APK build passed.
- GitHub Actions run `37454365753` / run number `10` completed successfully.
- Artifact `dsm-helper-modern-ui-android-debug` generated successfully.
- Artifact digest: `sha256:fb3bacc3f475d07b213f39ef8e9f418af324c578fda1ed7925e6757c6dba3710`.

### Completed

Task 0 — Foundation / Working Environment is complete.

Real-device baseline Gate results:
- APK installs and launches successfully.
- DSM connection succeeds against a real Synology NAS.
- Login succeeds.
- Dashboard loads and displays data.
- File Station can browse directories and files.
- Main navigation works.
- Legacy dark theme has visible graphical / rendering defects. These are recorded as `LEGACY-BASELINE-VISUAL-01` and are non-blocking for Task 0 because the project will replace the legacy visual layer with the new Material 3 UI rather than repair the old theme.

Task 0 acceptance record:
```text
docs/modern-ui/acceptance/2026-10-06-task-0-foundation-acceptance.md
```

### Completed

Task 1 — Project Specification + Legacy Interface / Protocol Freeze is complete.

Task 1 acceptance record:
```text
docs/modern-ui/acceptance/2026-10-07-task-1-spec-contracts-acceptance.md
```

Task 1 authoritative outputs:
```text
docs/modern-ui/specs/2026-10-07-dsm-helper-modern-ui-spec.md
docs/modern-ui/contracts/2026-10-07-global-interface-protocol-inventory.md
docs/modern-ui/contracts/2026-10-07-global-contract-matrix.md
```

Task 1 Exit Gate:
- Project Specification approved.
- Global interface/protocol inventory complete.
- Global Contract Matrix complete.
- UI/legacy theme and fallback isolation boundary frozen.
- No unresolved Contract Gap blocks Task 2 or Task 3.
- No production code was changed by Task 1 completion work.

### Active

```text
No implementation Task is active.
```

### Next

```text
Task 2 — Visual Design Specification
```

Task 2 is unblocked by the completed Task 1 Exit Gate but has not started.
