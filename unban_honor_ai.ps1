# Run this script from an elevated PowerShell window if you want to undo ban_honor_ai.ps1.

$ErrorActionPreference = 'Continue'

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  throw 'Please run this script as Administrator.'
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
  $key = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$exe"
  if (Test-Path -LiteralPath $key) {
    Remove-Item -LiteralPath $key -Recurse -Force
  }
}

$services = @(
  'HnPCAIService',
  'HnPCInferEngine',
  'MagicAnimationService'
)
foreach ($svc in $services) {
  if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
    Set-Service -Name $svc -StartupType Automatic -ErrorAction SilentlyContinue
  }
}

Get-CimInstance Win32_Service | Where-Object { $services -contains $_.Name } |
  Select-Object Name,State,StartMode,PathName | Format-Table -AutoSize

