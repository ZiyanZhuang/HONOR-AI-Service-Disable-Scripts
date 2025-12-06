# Requires Administrator privileges
# ------------------------------------------------------------------

Write-Host "====================================" -ForegroundColor Yellow
Write-Host "   HONOR AI Service Disable Script (PowerShell)" -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Yellow
Write-Host ""

# 1. Check administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "[ERROR] Administrator privileges required" -ForegroundColor Red
    Write-Host "Please right-click script and select 'Run as administrator'" -ForegroundColor Red
    Start-Sleep -Seconds 5
    exit 1
} else {
    Write-Host "[OK] Administrator privileges detected" -ForegroundColor Green
}

Write-Host ""
Write-Host "Disabling HONOR AI Service..." -ForegroundColor Cyan
Write-Host ""

# Define target names
$ProcessName1 = "HnPCAIService.exe"
$ProcessName2 = "HNPCAIService.exe"
$ServiceName = "HNPCAIService"
[cite_start]$TaskNamePattern = "HONOR\AI*" # Matches pattern used in BAT 

# --- 2. Terminate related processes ---
Write-Host "[1/5] Terminating processes..."
try {
    # Stop-Process is more robust than taskkill
    Get-Process -Name $ProcessName1, $ProcessName2 -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "[OK] Processes terminated (if running)" -ForegroundColor Green
} catch {
    Write-Host "[WARNING] Could not stop process. Error: $($_.Exception.Message)" -ForegroundColor Yellow
}

# --- 3. Stop and Disable Windows services ---
Write-Host "[2/5] Stopping and disabling service..."
try {
    # Stop the service
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    # Set the service startup type to Disabled
    Set-Service -Name $ServiceName -StartupType Disabled -ErrorAction Stop
    Write-Host "[OK] Service stopped and set to Disabled" -ForegroundColor Green
} catch {
    # If the service doesn't exist, this is the expected behavior 
    Write-Host "[WARNING] Service '$ServiceName' may not exist or could not be configured." -ForegroundColor Yellow
}

# --- 4. Disable scheduled tasks ---
Write-Host "[3/5] Processing scheduled tasks..."
try {
    # Using schtasks directly as in the BAT script for broad pattern matching 
    cmd /c "schtasks /change /tn `"$TaskNamePattern`" /disable >NUL 2>&1"
    cmd /c "schtasks /delete /tn `"$TaskNamePattern`" /f >NUL 2>&1"
    Write-Host "[OK] Scheduled tasks disabled/deleted" -ForegroundColor Green
} catch {
    Write-Host "[WARNING] Error processing scheduled tasks." -ForegroundColor Yellow
}

# --- 5. Clean registry startup entries ---
Write-Host "[4/5] Cleaning registry..."
$RegPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
)
$RegValues = @("HNPCAIService", "HnPCAIService")

try {
    foreach ($Path in $RegPaths) {
        foreach ($Value in $RegValues) {
            # Check if the registry key exists and remove the value
            Remove-ItemProperty -Path $Path -Name $Value -Force -ErrorAction SilentlyContinue
        }
    }
    Write-Host "[OK] Registry cleaned" -ForegroundColor Green
} catch {
    Write-Host "[WARNING] Error cleaning registry." -ForegroundColor Yellow
}


# --- 6. Verify disable status ---
Write-Host "[5/5] Verifying status..."
[cite_start]Start-Sleep -Seconds 2 # Wait for processes to exit 

# Check if process is running 
if (Get-Process -Name $ProcessName1, $ProcessName2 -ErrorAction SilentlyContinue) {
    Write-Host "[WARNING] Service still running detected" -ForegroundColor Yellow
} else {
    Write-Host "[SUCCESS] Service successfully disabled" -ForegroundColor Green
}

Write-Host ""
Write-Host "====================================" -ForegroundColor Yellow
Write-Host "        Disable Complete!" -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "If service restarts, you may need to:" -ForegroundColor Cyan
Write-Host "1. Run this script again" -ForegroundColor Cyan
Write-Host "2. Check for other related processes" -ForegroundColor Cyan
Write-Host "3. Consider uninstalling HONOR software" -ForegroundColor Cyan
Write-Host ""

# Pause equivalent in PowerShell [cite: 8]
$Host.UI.WriteLine("Press Enter to exit...")
$null = $Host.UI.ReadLine()
