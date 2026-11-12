#Requires -RunAsAdministrator
#Requires -Version 5.1
<#
.SYNOPSIS
    Installs the ALProject4 deploy agent on this Business Central server.

.PARAMETER ServerInstance
    BC service instance name on this machine, e.g. BC140 or POSM.

.PARAMETER SourcePath
    UNC path to the shared drop folder, e.g. \\build-server\ALDeploy\ALProject4

.PARAMETER Tenant
    Tenant to install for. Default is 'default'.

.PARAMETER PollIntervalMinutes
    How often the scheduled task checks for updates. Default is 10.

.PARAMETER InstallPath
    Local folder where agent files are stored. Default is C:\ALDeploy\ALProject4.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ServerInstance,

    [Parameter(Mandatory = $true)]
    [string]$SourcePath,

    [string]$Tenant = 'default',
    [int]$PollIntervalMinutes = 10,
    [string]$InstallPath = 'C:\ALDeploy\ALProject4'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$taskName = 'ALProject4-DeployAgent'
$agentScriptName = 'ALProject4DeployAgent.ps1'
$sourceAgentScript = Join-Path $PSScriptRoot $agentScriptName

if (-not (Test-Path -LiteralPath $sourceAgentScript)) {
    throw "Agent script not found: $sourceAgentScript"
}

Write-Host "Installing ALProject4 deploy agent to $InstallPath"

New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $InstallPath 'logs') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $InstallPath 'staging') -Force | Out-Null

Copy-Item -LiteralPath $sourceAgentScript -Destination (Join-Path $InstallPath $agentScriptName) -Force

$config = [ordered]@{
    ServerInstance        = $ServerInstance
    Tenant                = $Tenant
    SourcePath            = $SourcePath.TrimEnd('\')
    PollIntervalMinutes   = $PollIntervalMinutes
    SkipVerification      = $true
    ForceSync             = $true
    LogPath               = Join-Path $InstallPath 'logs'
}

$configPath = Join-Path $InstallPath 'agent-config.json'
$config | ConvertTo-Json | Set-Content -Path $configPath -Encoding UTF8

$agentPath = Join-Path $InstallPath $agentScriptName
$action = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$agentPath`""

$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes $PollIntervalMinutes) -RepetitionDuration ([TimeSpan]::MaxValue)

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -MultipleInstances IgnoreNew

$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

Register-ScheduledTask `
    -TaskName $taskName `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -RunLevel Highest `
    -User 'SYSTEM' `
    -Description 'Pulls ALProject4 .app packages from the shared drop folder and installs them on this BC server.' | Out-Null

Write-Host "Scheduled task '$taskName' registered (every $PollIntervalMinutes minutes)."
Write-Host "Running agent once now for verification..."

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $agentPath -ConfigPath $configPath

Write-Host ''
Write-Host 'Agent installed successfully.'
Write-Host "Config: $configPath"
Write-Host "Logs:   $(Join-Path $InstallPath 'logs')"
Write-Host ''
Write-Host 'Manual run:'
Write-Host "  powershell -NoProfile -ExecutionPolicy Bypass -File `"$agentPath`""
