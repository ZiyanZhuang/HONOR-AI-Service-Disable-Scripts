# HONOR AI Service Disable Scripts (HnPCAIService Blocker) 🚫

一个轻量级的批处理脚本，用于停止、禁用和清理 Windows 系统上的 **HONOR AI 服务程序 (HnPCAIService.exe)**。

## ✨ 核心功能

* **进程管理**: 自动结束 HnPCAIService 相关进程。
* **服务控制**: 停止并禁用 Windows 服务 `HNPCAIService`。
* **启动项清理**: 移除注册表中的自动启动项。
* **任务调度**: 禁用和删除相关的计划任务。
* **状态验证**: 检查禁用操作是否成功。

## 📥 如何快速使用 (推荐)

### 方法 1: 使用修复版批处理脚本 (.bat)

这是最简单、兼容性最好的方法。

1.  右键点击 `disable_honor_ai_service_fixed.bat` 文件。
2.  选择 **"以管理员身份运行" (Run as administrator)**。
3.  等待脚本执行完成。

### 方法 2: 使用 PowerShell 脚本 (.ps1)

提供更多高级功能，如强制模式和重新启用。

```powershell
# 1. 如果被阻止，先运行以下命令解除限制：
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 2. 运行禁用脚本：
.\disable_honor_ai_service.ps1

# 重新启用服务：
.\disable_honor_ai_service.ps1 -Enable
