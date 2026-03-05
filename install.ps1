# install.ps1 - One-command setup for aws-cp-creds (Windows)

Write-Host "Installing AWS Academy Credentials Auto-Updater..."

# Download the script from GitHub
Write-Host "Downloading update-aws-creds.ps1..."
$ScriptPath = Join-Path $env:USERPROFILE "update-aws-creds.ps1"

try {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/aravindh28/aws-cp-creds/main/update-aws-creds.ps1" -OutFile $ScriptPath -UseBasicParsing -ErrorAction Stop
} catch {
    Write-Host "Error: Failed to download update-aws-creds.ps1"
    Write-Host $_.Exception.Message
    exit 1
}

if (-not (Test-Path $ScriptPath) -or (Get-Item $ScriptPath).Length -eq 0) {
    Write-Host "Error: Downloaded update-aws-creds.ps1 is missing or empty"
    exit 1
}

Write-Host "Script installed to $ScriptPath"

# Check execution policy
$Policy = Get-ExecutionPolicy -Scope CurrentUser
if ($Policy -eq "Restricted" -or $Policy -eq "AllSigned") {
    Write-Host ""
    Write-Host "WARNING: Your PowerShell execution policy ($Policy) may prevent the script from running." -ForegroundColor Yellow
    Write-Host "To fix this, run the following command:" -ForegroundColor Yellow
    Write-Host "  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Cyan
    Write-Host ""
}

# Ensure PowerShell profile exists
if (-not (Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File -Force | Out-Null
    Write-Host "Created PowerShell profile at $PROFILE"
}

# Check if function already exists in profile
$ProfileContent = Get-Content -Path $PROFILE -Raw -ErrorAction SilentlyContinue
if ($ProfileContent -and $ProfileContent -match 'function\s+aws-cp-creds') {
    Write-Host "Function 'aws-cp-creds' already exists in your PowerShell profile"
} else {
    # Add a wrapper function (PowerShell aliases can't forward parameters, so we use a function)
    $FunctionBlock = @"

# AWS Academy Credentials Auto-Updater
function aws-cp-creds {
    & "`$env:USERPROFILE\update-aws-creds.ps1" @args
}
"@
    Add-Content -Path $PROFILE -Value $FunctionBlock
    Write-Host "Function 'aws-cp-creds' added to your PowerShell profile"
}

Write-Host ""
Write-Host "Installation complete."
Write-Host "Open a new PowerShell window, or run: . `$PROFILE"
