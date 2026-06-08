# FitGlass

一款 **iOS 26.5** 健身 App 脚手架：Nike Training 风格 UI + 液态玻璃（Liquid Glass）、中英双语（可在 App 内切换）、PDF / Word 训练计划导入、以及**跳转 Claude App 用 Pro 账号** AI 生成训练计划。

> ⚠️ iOS App 必须在 **macOS + Xcode 26+** 上编译 / 签名 / 运行。本仓库用 [XcodeGen](https://github.com/yonaskolb/XcodeGen) 以纯文本（`project.yml`）定义工程，因此可以在 **Windows 编写**，在 **Mac 或云端 CI 构建**。

## 环境要求
- Xcode 26 或更高（iOS 26.5 SDK）
- XcodeGen：`brew install xcodegen`
- Apple Developer 账号（真机 / 上架需要）

## 在 Mac 上生成并运行
```bash
brew install xcodegen          # 仅首次
xcodegen generate              # 由 project.yml 生成 FitGlass.xcodeproj
open FitGlass.xcodeproj
# Xcode 中选择 iOS 26.5 模拟器 → Run (⌘R)
```
在 `project.yml` 把 `DEVELOPMENT_TEAM` 设为你的 Team ID 后即可真机运行。

## 纯逻辑单测（任意装有 Swift 的机器，含 Windows）
解析逻辑（Claude JSON 解析、docx 文本抽取、prompt 构造）放在独立的 **`PlanParsingKit`** 包，仅依赖 Foundation：
```bash
cd PlanParsingKit
swift test
```
> Windows 安装 Swift：<https://www.swift.org/install/windows/> 。注意：docx 的 zip 解压相关测试在个别平台可能需 macOS/Linux。

## 无 Mac 时的 CI 构建
GitHub Actions（`macos-latest` runner）或 Codemagic：
```bash
xcodegen generate
xcodebuild -scheme FitGlass -destination 'generic/platform=iOS Simulator' build
```

## 目录结构
| 路径 | 说明 |
|---|---|
| `Sources/FitGlass/App` | App 入口、根标签栏 |
| `Sources/FitGlass/DesignSystem` | 液态玻璃组件、主题（Nike 风深色） |
| `Sources/FitGlass/Features` | Home / Library / PlanDetail / Import / AIGenerate / Progress / Settings |
| `Sources/FitGlass/Models` | SwiftData 数据模型 |
| `Sources/FitGlass/Services` | 生成（Claude 跳转）、导入、本地化 |
| `Sources/FitGlass/Resources` | `Info.plist`、`Assets.xcassets`、`Localizable.xcstrings` |
| `PlanParsingKit` | 纯 Foundation 解析包（可跨平台单测） |
| `project.yml` | XcodeGen 工程定义 |

## AI 生成（Claude 跳转，零 API 成本）
App 不调用任何付费 API。流程：
1. App 依据你的目标 / 器械 / 经验生成**结构化 prompt**（要求 Claude 只输出严格 JSON）。
2. 通过**系统分享菜单**或「复制 + 打开 Claude」把 prompt 交给 Claude App（用你的 Pro 账号）。
3. 把 Claude 返回的 JSON **粘回 App**，自动解析成训练计划并入库。

详见 `Sources/FitGlass/Features/AIGenerate` 与 `PlanParsingKit`。AI 层是可插拔协议 `WorkoutPlanGenerator`，日后可无痛切换到端侧 Apple Foundation Models 或云端 API。

## 自动化往返（Apple 快捷指令，可选）
让 Claude 返回的 JSON 直接进 App、免手动粘贴。App 暴露了一个 App Intent **「Import training plan」**（见 `Sources/FitGlass/Services/Generation/ImportPlanIntent.swift`）。在「快捷指令」App 里串一条：
1. **文本**：填入 App 生成的 prompt（或用 App 内「分享给 Claude」传入）。
2. **Ask Claude**（Claude App 自带动作）：发送 prompt，得到 JSON 回复。
3. **Import training plan**（本 App 动作）：把回复作为「Plan JSON」传入，自动解析并保存。

也可用 URL 回调：`fitglass://import?json=<URL 编码的 JSON>`（见 `App/DeepLinkInbox.swift`）。两条自动化路径任选其一；手动「复制 → 打开 Claude → 粘回」始终作为可靠兜底。

## 首次构建排错（Windows 写、Mac 首编最可能遇到的点）
代码未在本机编译过；首次在 Xcode 26 上若报错，集中在以下少数几处，且都好修：

- **液态玻璃 API 签名**：所有玻璃效果只经过一个出入口 `Sources/FitGlass/DesignSystem/LiquidGlass.swift` 的 `glassSurface(_:tint:interactive:)`。若 `Glass` / `.tint` / `.interactive` / `glassEffect(_:in:)` 在你的 SDK 里签名略有出入，**只改这一个方法**即可全局生效；`GlassEffectContainer` 用在 Home/PlanDetail/Progress/Handoff 几处。
- **Xcode / SDK 版本**：需 Xcode 26（iOS 26.5 SDK）。模拟器选 iOS 26.x。
- **ZIPFoundation 初始化**：`Sources/FitGlass/Services/Import/DocumentImporter.swift` 用的是 0.9.x 的可失败初始化 `Archive(url:accessMode:)`。若你升到会抛错的 1.x 版本，改成 `try Archive(...)` 即可。
- **App 内语言切换**：依赖 `Bundle.main` 类替换（`Services/Localization/BundleLanguage.swift`）。若某版 iOS 改了字符串查找路径导致不即时生效，兜底是 iOS「设置 → App → 语言」按 App 设定语言（`Info.plist` 已声明 `CFBundleLocalizations`）。
- **App Intents**：`ImportPlanIntent` 需 `import AppIntents`（系统框架，自动链接，无需在 `project.yml` 加依赖）。

CI（`.github/workflows/ci.yml`）会在每次推送时跑 `swift test` + `xcodebuild build`，是验证以上的最快闸门。

## 重命名提示
占位标识：显示名 `FitGlass`、Bundle ID `com.example.fitglass`、URL scheme `fitglass://`。改名时同步更新 `project.yml` 与 `Sources/FitGlass/Resources/Info.plist`。
