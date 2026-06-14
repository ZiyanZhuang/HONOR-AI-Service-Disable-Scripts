# HONOR AI Blocker

PowerShell scripts for disabling selected HONOR Magic AI / PC AI background components on Windows.

This project is intended for users who see HONOR AI services repeatedly starting, locking files under `C:\ProgramData\Comms`, producing large logs or crash dumps, or consuming disk space after the AI features are not wanted.

## What It Does

`ban_honor_ai.ps1`:

- stops and disables known HONOR AI services
- terminates known HONOR AI processes
- adds Image File Execution Options blocks for known HONOR AI executables
- disables matching scheduled tasks
- removes known AI cache/data directories under `C:\ProgramData\Comms`

`unban_honor_ai.ps1`:

- removes the Image File Execution Options blocks
- restores the known HONOR AI services to automatic startup

Legacy scripts from the original repository are kept for compatibility:

- `disable_honor_ai_service_fixed.bat`
- `disable_honor_ai_service_from_bat.ps1`

## Targeted Components

Services:

- `HnPCAIService`
- `HnPCInferEngine`
- `MagicAnimationService`

Processes / executables:

- `AISearchUI.exe`
- `AISupportCenter.exe`
- `MagicText.exe`
- `MagicTextHelper.exe`
- `HNPCInferEngineService.exe`
- `HNPCInferServer.exe`
- `HNPCLLMServer.exe`
- `HnPCAIService.exe`
- `MagicAnimationService.exe`

Data/cache paths:

- `C:\ProgramData\Comms\MagicAI`
- `C:\ProgramData\Comms\HNPCAIService`
- `C:\ProgramData\Comms\HNPCInferServer`
- `C:\ProgramData\Comms\HNModelCache`
- `C:\ProgramData\Comms\MagicAnimation`
- `C:\ProgramData\Comms\HNPCInferEngine`
- `C:\ProgramData\Comms\HNModels`
- `C:\ProgramData\Comms\DownloadModelCache`
- `C:\ProgramData\Comms\modelmarket`
- `C:\ProgramData\Comms\HnAgentStudio`
- `C:\ProgramData\Comms\MagicClaw`

The script is intentionally scoped to AI-related names. It does not intentionally disable HONOR update, device collaboration, display, performance, or PC Manager base services.

## Usage

Open PowerShell as Administrator:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\ban_honor_ai.ps1
```

To undo the startup blocks and service startup changes:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\unban_honor_ai.ps1
```

## Notes

- Run from an elevated PowerShell window.
- The block mechanism uses Windows Image File Execution Options and points blocked executables to `C:\Windows\System32\systray.exe`.
- Some files may still require a reboot before they can be deleted if a protected service keeps handles open.
- HONOR software updates may recreate services, files, or scheduled tasks. Re-run the script after updates if needed.

## Disclaimer

Use at your own risk. This script changes service startup configuration, scheduled tasks, registry keys, running processes, and application data. Review the script before running it.

