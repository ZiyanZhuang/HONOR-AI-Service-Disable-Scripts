# HONOR AI Blocker / 荣耀 AI 组件禁用脚本

PowerShell scripts for disabling selected HONOR Magic AI / PC AI background components on Windows.

用于在 Windows 上禁用部分荣耀 Magic AI / 荣耀电脑管家 AI 后台组件的 PowerShell 脚本。

## 中文说明

### 项目用途

一些荣耀电脑的 AI 组件会在后台常驻运行，例如 AI 搜索、MagicText、PC AI 推理服务、LLM 服务等。它们可能会：

- 反复自动启动，无法通过普通任务管理器彻底关闭
- 占用 `C:\ProgramData\Comms` 下的文件，导致缓存或日志无法删除
- 生成较大的日志、崩溃转储或诊断包
- 在不使用 AI 功能的情况下仍占用磁盘空间和后台资源

本项目提供两个脚本：

- `ban_honor_ai.ps1`：禁用、拦截并清理已知荣耀 AI 组件
- `unban_honor_ai.ps1`：撤销启动拦截，并把相关服务恢复为自动启动

原仓库中的旧脚本仍保留，方便兼容早期用法：

- `disable_honor_ai_service_fixed.bat`
- `disable_honor_ai_service_from_bat.ps1`

### 快速使用

以管理员身份打开 PowerShell，然后运行：

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\ban_honor_ai.ps1
```

如果脚本不在当前目录，请先切换目录。例如：

```powershell
cd C:\Path\To\HONOR-AI-Service-Disable-Scripts
Set-ExecutionPolicy -Scope Process Bypass -Force
.\ban_honor_ai.ps1
```

恢复方式：

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\unban_honor_ai.ps1
```

### `ban_honor_ai.ps1` 做了什么

脚本会按顺序执行以下操作：

1. 检查当前 PowerShell 是否为管理员权限。
2. 停止并禁用已知荣耀 AI 服务。
3. 结束已知荣耀 AI 进程。
4. 使用 Windows Image File Execution Options 机制阻止相关 AI 可执行文件再次启动。
5. 禁用名称、路径或启动命令中匹配 AI 关键词的计划任务。
6. 删除已知 AI 缓存、模型缓存和运行数据目录。
7. 输出剩余进程和服务状态，方便确认是否仍有组件在运行。

### 被禁用的服务

当前脚本目标服务：

| 服务名 | 显示名 | 说明 |
|---|---|---|
| `HnPCAIService` | HONOR AI Service | 荣耀 AI 后台服务 |
| `HnPCInferEngine` | HONOR PCManager AI Inference Service | 荣耀电脑管家 AI 推理服务 |
| `MagicAnimationService` | MagicAnimation Service | MagicAnimation 相关服务 |

### 被结束或拦截的进程

当前脚本目标进程 / 可执行文件：

| 进程或文件名 | 可能用途 |
|---|---|
| `AISearchUI.exe` | AI 搜索界面 |
| `AISupportCenter.exe` | AI 支持中心 |
| `MagicText.exe` | MagicText 主进程 |
| `MagicTextHelper.exe` | MagicText 辅助进程 |
| `HNPCInferEngineService.exe` | AI 推理引擎服务 |
| `HNPCInferServer.exe` | AI 推理服务端 |
| `HNPCLLMServer.exe` | 本地 LLM 服务 |
| `HnPCAIService.exe` | 荣耀 AI 服务 |
| `MagicAnimationService.exe` | MagicAnimation 服务 |

### 被清理的数据目录

脚本会尝试删除以下目录：

```text
C:\ProgramData\Comms\MagicAI
C:\ProgramData\Comms\HNPCAIService
C:\ProgramData\Comms\HNPCInferServer
C:\ProgramData\Comms\HNModelCache
C:\ProgramData\Comms\MagicAnimation
C:\ProgramData\Comms\HNPCInferEngine
C:\ProgramData\Comms\HNModels
C:\ProgramData\Comms\DownloadModelCache
C:\ProgramData\Comms\modelmarket
C:\ProgramData\Comms\HnAgentStudio
C:\ProgramData\Comms\MagicClaw
```

这些路径通常包含 AI 日志、SQLite 数据库、模型缓存、下载缓存、运行临时文件或诊断残留。

### 不会主动禁用的内容

脚本有意限定在 AI 相关组件，不会主动禁用以下类型的荣耀功能：

- 荣耀更新服务
- 荣耀电脑管家主服务
- 多屏协同 / 设备互联基础组件
- 显示增强、性能中心、电源管理等基础组件
- Windows 系统服务
- 第三方安全软件服务

如果荣耀软件更新后重新安装 AI 组件，可能需要重新运行 `ban_honor_ai.ps1`。

### 启动拦截机制说明

脚本使用 Windows 的 Image File Execution Options 机制，在注册表中为目标可执行文件写入 `Debugger` 值：

```text
HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\<exe name>
Debugger = C:\Windows\System32\systray.exe
```

这样，当系统或荣耀软件尝试启动对应 AI 可执行文件时，Windows 会改为启动 `systray.exe`，从而阻止原程序启动。

`unban_honor_ai.ps1` 会删除这些 IFEO 注册表项。

### 常见问题

#### 1. 提示“Please run this script as Administrator.”

请以管理员身份运行 PowerShell。右键 PowerShell，选择“以管理员身份运行”。

#### 2. 提示文件正在被另一进程使用

说明荣耀 AI 组件仍在运行并持有文件句柄。请先运行：

```powershell
.\ban_honor_ai.ps1
```

如果仍然无法删除，重启后再运行一次脚本。

#### 3. 禁用后荣耀电脑管家还能用吗

脚本不主动禁用电脑管家主服务，但荣耀软件内部组件之间可能存在耦合。AI 搜索、MagicText、AI 字幕、YOYO、本地推理等功能可能不可用。

#### 4. 如何恢复

运行：

```powershell
.\unban_honor_ai.ps1
```

如果荣耀 AI 文件已经被删除，恢复启动拦截后，可能仍需要通过荣耀电脑管家更新、修复安装或重新安装相关组件。

### 风险说明

请在运行前阅读脚本内容。本项目会修改：

- Windows 服务启动类型
- 运行中的进程
- 计划任务状态
- `HKLM` 注册表项
- `C:\ProgramData\Comms` 下的应用数据

使用风险由用户自行承担。

## English

### Purpose

Some HONOR laptops ship with AI-related background components such as AI Search, MagicText, PC AI inference services, and local LLM services. These components may:

- restart automatically after being closed from Task Manager
- keep files locked under `C:\ProgramData\Comms`
- create large logs, crash dumps, or diagnostic packages
- consume disk space or background resources even when the AI features are not needed

This repository provides two scripts:

- `ban_honor_ai.ps1`: disables, blocks, and cleans known HONOR AI components
- `unban_honor_ai.ps1`: removes the executable blocks and restores service startup types

Legacy scripts from the original repository are kept for compatibility:

- `disable_honor_ai_service_fixed.bat`
- `disable_honor_ai_service_from_bat.ps1`

### Quick Start

Open PowerShell as Administrator and run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\ban_honor_ai.ps1
```

If the script is not in your current directory, change to the repository folder first:

```powershell
cd C:\Path\To\HONOR-AI-Service-Disable-Scripts
Set-ExecutionPolicy -Scope Process Bypass -Force
.\ban_honor_ai.ps1
```

To undo the startup blocks and restore the targeted service startup settings:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\unban_honor_ai.ps1
```

### What `ban_honor_ai.ps1` Does

The script performs these steps:

1. Verifies that PowerShell is running as Administrator.
2. Stops and disables known HONOR AI services.
3. Terminates known HONOR AI processes.
4. Blocks known HONOR AI executables through Windows Image File Execution Options.
5. Disables scheduled tasks whose names, paths, or actions match AI-related HONOR keywords.
6. Deletes known AI cache, model cache, and runtime data directories.
7. Prints remaining process and service state for verification.

### Targeted Services

| Service name | Display name | Description |
|---|---|---|
| `HnPCAIService` | HONOR AI Service | HONOR AI background service |
| `HnPCInferEngine` | HONOR PCManager AI Inference Service | HONOR PC Manager AI inference service |
| `MagicAnimationService` | MagicAnimation Service | MagicAnimation-related service |

### Targeted Processes And Executables

| Process / executable | Likely role |
|---|---|
| `AISearchUI.exe` | AI Search UI |
| `AISupportCenter.exe` | AI support center |
| `MagicText.exe` | MagicText main process |
| `MagicTextHelper.exe` | MagicText helper |
| `HNPCInferEngineService.exe` | AI inference engine service |
| `HNPCInferServer.exe` | AI inference server |
| `HNPCLLMServer.exe` | Local LLM server |
| `HnPCAIService.exe` | HONOR AI service |
| `MagicAnimationService.exe` | MagicAnimation service |

### Data Paths Removed

The script attempts to delete:

```text
C:\ProgramData\Comms\MagicAI
C:\ProgramData\Comms\HNPCAIService
C:\ProgramData\Comms\HNPCInferServer
C:\ProgramData\Comms\HNModelCache
C:\ProgramData\Comms\MagicAnimation
C:\ProgramData\Comms\HNPCInferEngine
C:\ProgramData\Comms\HNModels
C:\ProgramData\Comms\DownloadModelCache
C:\ProgramData\Comms\modelmarket
C:\ProgramData\Comms\HnAgentStudio
C:\ProgramData\Comms\MagicClaw
```

These paths commonly contain logs, SQLite databases, model caches, download caches, runtime temporary files, or diagnostic residue.

### What It Does Not Intentionally Disable

The script is scoped to AI-related names. It does not intentionally disable:

- HONOR update services
- the main HONOR PC Manager service
- device collaboration or multi-screen collaboration base components
- display enhancement, performance center, or power management components
- Windows system services
- third-party security services

HONOR software updates may recreate services, files, scheduled tasks, or registry state. Re-run `ban_honor_ai.ps1` after updates if needed.

### Blocking Mechanism

The script uses Windows Image File Execution Options by writing a `Debugger` value for target executable names:

```text
HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\<exe name>
Debugger = C:\Windows\System32\systray.exe
```

When Windows tries to launch a blocked executable, it launches `systray.exe` instead, preventing the original AI executable from starting.

`unban_honor_ai.ps1` removes these IFEO registry keys.

### Troubleshooting

#### "Please run this script as Administrator."

Run PowerShell as Administrator.

#### "The file is being used by another process."

An HONOR AI process is still holding the file handle. Run:

```powershell
.\ban_honor_ai.ps1
```

If deletion still fails, reboot Windows and run the script again.

#### Will HONOR PC Manager still work?

The script does not intentionally disable the main PC Manager service, but HONOR components may be internally coupled. AI Search, MagicText, AI subtitles, YOYO, and local inference features may stop working.

#### How do I restore the components?

Run:

```powershell
.\unban_honor_ai.ps1
```

If application files were deleted, removing the startup blocks may not fully restore the feature. You may need to repair or reinstall HONOR PC Manager components.

### Disclaimer

Review the scripts before running them. This project changes:

- Windows service startup configuration
- running processes
- scheduled task state
- `HKLM` registry keys
- application data under `C:\ProgramData\Comms`

Use at your own risk.
