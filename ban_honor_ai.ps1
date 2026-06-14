# Run this script from an elevated PowerShell window.
# It disables selected HONOR Magic AI / PC AI services and blocks their executable entry points.

$ErrorActionPreference = 'Continue'

function Assert-Admin {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal]::new($identity)
  if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Please run this script as Administrator.'
  }
}

function Stop-And-DisableService {
  param([Parameter(Mandatory=$true)][string]$Name)
  $svc = Get-Service -Name $Name -ErrorAction SilentlyContinue
  if (-not $svc) {
    [pscustomobject]@{Kind='Service';Name=$Name;Action='missing';Status='OK'}
    return
  }
  try {
    if ($svc.Status -ne 'Stopped') {
      Stop-Service -Name $Name -Force -ErrorAction Stop
    }
  } catch {
    sc.exe stop $Name | Out-Null
    Start-Sleep -Seconds 2
  }
  try {
    Set-Service -Name $Name -StartupType Disabled -ErrorAction Stop
    [pscustomobject]@{Kind='Service';Name=$Name;Action='disabled';Status='OK'}
  } catch {
    sc.exe config $Name start= disabled | Out-Null
    [pscustomobject]@{Kind='Service';Name=$Name;Action='disable attempted';Status=$_.Exception.Message}
  }
}

function Stop-ProcessByName {
  param([Parameter(Mandatory=$true)][string]$Name)
  $procs = Get-Process -Name $Name -ErrorAction SilentlyContinue
  if (-not $procs) {
    [pscustomobject]@{Kind='Process';Name=$Name;Action='not running';Status='OK'}
    return
  }
  foreach ($p in $procs) {
    try {
      Stop-Process -Id $p.Id -Force -ErrorAction Stop
      [pscustomobject]@{Kind='Process';Name=$Name;Action="stopped PID $($p.Id)";Status='OK'}
    } catch {
      taskkill.exe /PID $p.Id /F | Out-Null
      [pscustomobject]@{Kind='Process';Name=$Name;Action="taskkill PID $($p.Id)";Status=$_.Exception.Message}
    }
  }
}

function Add-IfeoBlock {
  param([Parameter(Mandatory=$true)][string]$ExeName)
  $key = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$ExeName"
  New-Item -Path $key -Force | Out-Null
  New-ItemProperty -Path $key -Name Debugger -Value 'C:\Windows\System32\systray.exe' -PropertyType String -Force | Out-Null
  [pscustomobject]@{Kind='IFEO';Name=$ExeName;Action='blocked';Status='OK'}
}

function Disable-MatchingScheduledTasks {
  $pattern = 'HONOR|HNMagicAI|HNPCAI|HNPCInfer|MagicAI|MagicAnimation|MagicText|AISearch|AISupport|HNPCLLM|BrainMemory'
  $tasks = Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object {
    $actions = ($_.Actions | ForEach-Object { "$($_.Execute) $($_.Arguments)" }) -join ' '
    ($_.TaskName + ' ' + $_.TaskPath + ' ' + $actions) -match $pattern
  }
  foreach ($task in $tasks) {
    try {
      Disable-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -ErrorAction Stop | Out-Null
      [pscustomobject]@{Kind='Task';Name="$($task.TaskPath)$($task.TaskName)";Action='disabled';Status='OK'}
    } catch {
      [pscustomobject]@{Kind='Task';Name="$($task.TaskPath)$($task.TaskName)";Action='disable failed';Status=$_.Exception.Message}
    }
  }
}

function Remove-TargetPath {
  param([Parameter(Mandatory=$true)][string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    [pscustomobject]@{Kind='Path';Name=$Path;Action='missing';Status='OK'}
    return
  }
  try {
    Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction Stop
    [pscustomobject]@{Kind='Path';Name=$Path;Action='deleted';Status='OK'}
  } catch {
    [pscustomobject]@{Kind='Path';Name=$Path;Action='delete failed';Status=$_.Exception.Message}
  }
}

Assert-Admin

$results = @()

$services = @(
  'HnPCAIService',
  'HnPCInferEngine',
  'MagicAnimationService'
)
foreach ($svc in $services) {
  $results += Stop-And-DisableService -Name $svc
}

Start-Sleep -Seconds 3

$processes = @(
  'AISearchUI',
  'AISupportCenter',
  'MagicText',
  'MagicTextHelper',
  'HNPCInferEngineService',
  'HNPCInferServer',
  'HNPCLLMServer',
  'HnPCAIService',
  'MagicAnimationService'
)
foreach ($proc in $processes) {
  $results += Stop-ProcessByName -Name $proc
}

$exeBlocks = @(
  'AISearchUI.exe',
  'AISupportCenter.exe',
  'MagicText.exe',
  'MagicTextHelper.exe',
  'HNPCInferEngineService.exe',
  'HNPCInferServer.exe',
  'HNPCLLMServer.exe',
  'HnPCAIService.exe',
  'MagicAnimationService.exe'
)
foreach ($exe in $exeBlocks) {
  $results += Add-IfeoBlock -ExeName $exe
}

$results += Disable-MatchingScheduledTasks

$dataPaths = @(
  'C:\ProgramData\Comms\MagicAI',
  'C:\ProgramData\Comms\HNPCAIService',
  'C:\ProgramData\Comms\HNPCInferServer',
  'C:\ProgramData\Comms\HNModelCache',
  'C:\ProgramData\Comms\MagicAnimation',
  'C:\ProgramData\Comms\HNPCInferEngine',
  'C:\ProgramData\Comms\HNModels',
  'C:\ProgramData\Comms\DownloadModelCache',
  'C:\ProgramData\Comms\modelmarket',
  'C:\ProgramData\Comms\HnAgentStudio',
  'C:\ProgramData\Comms\MagicClaw'
)
foreach ($path in $dataPaths) {
  $results += Remove-TargetPath -Path $path
}

$remaining = Get-Process -ErrorAction SilentlyContinue | Where-Object {
  $processes -contains $_.ProcessName
} | Select-Object Id,ProcessName,Path

$serviceState = Get-CimInstance Win32_Service | Where-Object {
  $services -contains $_.Name
} | Select-Object Name,State,StartMode,PathName

'RESULTS'
$results | Format-Table -AutoSize
'REMAINING_PROCESSES'
$remaining | Format-Table -AutoSize
'SERVICE_STATE'
$serviceState | Format-Table -AutoSize

