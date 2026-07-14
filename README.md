# 止界

止界是一个极简 macOS 菜单栏工具，用来控制指针是否可以通过 Universal Control 跨越到其他 Mac 或 iPad。

## 功能

- 一个“允许指针跨设备”开关。
- 启动时读取当前状态，切换后立即重启 Universal Control 进程使设置生效。
- 关闭窗口后继续驻留菜单栏，可从菜单栏切换、重新显示窗口或退出。
- 支持 Apple 芯片与 Intel Mac。

止界不会监听其他应用，也不包含开机启动功能。

## 系统要求

- macOS 12.3 或更高版本。
- 支持 Universal Control 的 Mac；跨设备功能本身还需要符合 Apple 的系统、设备和账户要求。

## 安装

1. 从 GitHub Releases 下载 `Jiezhi-v1.0.2.dmg`。
2. 打开 DMG，将“止界”拖入 Applications 文件夹。
3. v1.0.2 使用 ad-hoc 签名且**未经过 Apple notarization（公证）**。首次启动请在 Finder 中右键“止界”，选择“打开”，再在系统提示中确认。

## 使用

启动止界，在窗口中切换“允许指针跨设备”：

- 开：允许 Universal Control 将指针移动到其他设备。
- 关：将指针限制在当前设备边界。

菜单栏图标在关闭状态下会变淡。点击图标仍可切换状态、显示窗口或退出。

## 从源码构建

需要完整 Xcode、[XcodeGen](https://github.com/yonaskolb/XcodeGen) 以及 macOS 自带的命令行工具：

```bash
xcodegen generate
open Jiezhi.xcodeproj
```

工程名与 scheme 均为 `Jiezhi`，最低部署版本为 macOS 12.3。

生成 Universal Release DMG：

```bash
./scripts/build-release.sh
```

默认使用 `/Applications/Xcode-beta.app/Contents/Developer`。可通过环境变量覆盖：

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer VERSION=1.0.2 ./scripts/build-release.sh
```

产物位于 `dist/`，包括 DMG 和 SHA-256 校验文件。

## 实现与兼容性风险

macOS 没有公开 API 可直接切换 Universal Control。止界通过 `Process` 依次执行：

```text
/usr/bin/defaults -currentHost write com.apple.universalcontrol Disable -bool true|false
/usr/bin/killall UniversalControl
```

该偏好键和进程名均属于未公开实现细节，Apple 可能在未来 macOS 更新中修改或移除它们。止界不会请求管理员权限，仅修改当前用户、当前 Mac 的偏好。

## 许可证

[MIT](LICENSE)
