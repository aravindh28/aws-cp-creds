# AWS Academy Credentials Updater with Multi-Profile Support (Windows PowerShell)

param(
    [Alias("profile")]
    [string]$ProfileName
)

# Validate profile name if provided
if ($ProfileName) {
    if ($ProfileName -notmatch '^[a-zA-Z0-9_-]+$') {
        Write-Host "Error: Invalid profile name '$ProfileName'"
        Write-Host "Profile names can only contain letters, numbers, hyphens, and underscores"
        exit 1
    }
}

Write-Host "Checking clipboard content..."

# Get clipboard content
$Clipboard = Get-Clipboard -Raw

# Check if clipboard is empty
if ([string]::IsNullOrWhiteSpace($Clipboard)) {
    Write-Host "Error: Clipboard is empty"
    exit 1
}

# Normalize line endings to LF for consistent processing
$Clipboard = $Clipboard -replace "`r`n", "`n"
$Clipboard = $Clipboard.TrimEnd("`n")

# Determine profile name
if ($ProfileName) {
    $TargetProfile = $ProfileName
    Write-Host "Using profile from command line: [$TargetProfile]"
    # Strip any existing profile header from clipboard
    $ClipboardLines = $Clipboard -split "`n" | Where-Object { $_ -notmatch '^\[[a-zA-Z0-9_-]+\]$' }
    $Clipboard = $ClipboardLines -join "`n"
} else {
    # Extract profile name from clipboard
    if ($Clipboard -match '(?m)^\[([a-zA-Z0-9_-]+)\]') {
        $TargetProfile = $Matches[1]
        Write-Host "Detected profile: [$TargetProfile]"
    } else {
        $TargetProfile = "default"
        Write-Host "No profile found in clipboard, using [default]"
    }
}

# Validate required fields with actual values
$MissingFields = @()
if ($Clipboard -notmatch 'aws_access_key_id\s*=\s*\S+') {
    $MissingFields += "aws_access_key_id"
}
if ($Clipboard -notmatch 'aws_secret_access_key\s*=\s*\S+') {
    $MissingFields += "aws_secret_access_key"
}
if ($Clipboard -notmatch 'aws_session_token\s*=\s*\S+') {
    $MissingFields += "aws_session_token"
}

if ($MissingFields.Count -gt 0) {
    Write-Host "Error: Invalid credentials format"
    Write-Host "Missing fields: $($MissingFields -join ', ')"
    exit 1
}

# Prepare content to write - ensure profile header is included
if ($Clipboard -match "(?m)^\[$([regex]::Escape($TargetProfile))\]") {
    $ContentToWrite = $Clipboard
} else {
    $ContentToWrite = "[$TargetProfile]`n$Clipboard"
}

# Path to credentials file
$CredsFile = Join-Path $env:USERPROFILE ".aws\credentials"
$AwsDir = Join-Path $env:USERPROFILE ".aws"

# Helper: restrict file permissions to current user only
function Set-OwnerOnly($FilePath) {
    $Acl = Get-Acl $FilePath
    $Acl.SetAccessRuleProtection($true, $false)
    $Acl.Access | ForEach-Object { $Acl.RemoveAccessRule($_) } | Out-Null
    $Rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $env:USERNAME, "FullControl", "Allow"
    )
    $Acl.SetAccessRule($Rule)
    Set-Acl -Path $FilePath -AclObject $Acl
}

# Ensure .aws directory exists
if (-not (Test-Path $AwsDir)) {
    New-Item -ItemType Directory -Path $AwsDir -Force | Out-Null
}

# If credentials file doesn't exist, create it
if (-not (Test-Path $CredsFile)) {
    $ContentToWrite | Set-Content -Path $CredsFile -NoNewline
    Set-OwnerOnly $CredsFile
    Write-Host "Credentials updated: [$TargetProfile]"
    exit 0
}

# Read existing file and update the target profile
$ExistingContent = Get-Content -Path $CredsFile -Raw
if ([string]::IsNullOrEmpty($ExistingContent)) {
    $ContentToWrite | Set-Content -Path $CredsFile -NoNewline
    Set-OwnerOnly $CredsFile
    Write-Host "Credentials updated: [$TargetProfile]"
    exit 0
}

# Normalize existing content line endings
$ExistingContent = $ExistingContent -replace "`r`n", "`n"
$ExistingLines = $ExistingContent.TrimEnd("`n") -split "`n"

$OutputLines = @()
$InTargetProfile = $false
$ProfileFound = $false

foreach ($line in $ExistingLines) {
    # Check if this is a profile header
    if ($line -match '^\[[a-zA-Z0-9_-]+\]$') {
        $CurrentProfile = $line -replace '[\[\]]', ''

        if ($CurrentProfile -eq $TargetProfile) {
            # Found target profile - write new credentials instead
            $InTargetProfile = $true
            $ProfileFound = $true
            $OutputLines += $ContentToWrite -split "`n"
        } else {
            # Different profile - stop skipping if we were in target
            $InTargetProfile = $false
            $OutputLines += $line
        }
    } else {
        # Not a profile header - keep line only if not in target profile
        if (-not $InTargetProfile) {
            $OutputLines += $line
        }
    }
}

# If profile wasn't found, append it
if (-not $ProfileFound) {
    $OutputLines += ""
    $OutputLines += ($ContentToWrite -split "`n")
}

# Write the updated content
($OutputLines -join "`n") | Set-Content -Path $CredsFile -NoNewline
Set-OwnerOnly $CredsFile

Write-Host "Credentials updated: [$TargetProfile]"
