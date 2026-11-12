#Requires -Version 5.1
<#
.SYNOPSIS
    Pulls ALProject4 from a shared drop folder and installs it on this BC server.

.DESCRIPTION
    Run manually or via scheduled task. Compares manifest.json on the share
    against the installed app version, then Publish / Sync / Install when newer.

.PARAMETER ConfigPath
    Path to agent-config.json. Defaults to the config next to this script.

.PARAMETER WhatIf
    Report actions without publishing or installing.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$ConfigPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $ConfigPath) {
    $ConfigPath = Join-Path $PSScriptRoot 'agent-config.json'
}

function Write-AgentLog {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'WARN', 'ERROR')]
        [string]$Level = 'INFO'
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[$timestamp] [$Level] $Message"
    Write-Host $line

    if ($script:LogFile) {
        Add-Content -Path $script:LogFile -Value $line -Encoding UTF8
    }
}

function Import-BCAppManagementModule {
    $candidates = @(
        "${env:ProgramFiles}\Microsoft Dynamics 365 Business Central\*\Service\Microsoft.Dynamics.Nav.Apps.Management.psd1",
        "${env:ProgramFiles}\Microsoft Dynamics NAV\*\Service\Microsoft.Dynamics.Nav.Apps.Management.psd1",
        "${env:ProgramFiles(x86)}\Microsoft Dynamics 365 Business Central\*\Service\Microsoft.Dynamics.Nav.Apps.Management.psd1"
    )

    foreach ($pattern in $candidates) {
        $modulePath = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue |
            Sort-Object FullName -Descending |
            Select-Object -First 1 -ExpandProperty FullName

        if ($modulePath) {
            Import-Module $modulePath -Force
            Write-AgentLog "Loaded BC app management module: $modulePath"
            return
        }
    }

    throw 'Business Central Apps Management module not found. Install BC Admin tools on this server.'
}

function Read-AgentConfig {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Config file not found: $Path. Copy agent-config.example.json to agent-config.json and edit it."
    }

    $config = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json

    foreach ($required in @('ServerInstance', 'Tenant', 'SourcePath')) {
        if (-not $config.$required) {
            throw "Config setting '$required' is required."
        }
    }

    if (-not $config.LogPath) {
        $config | Add-Member -NotePropertyName LogPath -NotePropertyValue 'C:\ALDeploy\ALProject4\logs' -Force
    }

    return $config
}

function Get-InstalledAppVersion {
    param(
        [string]$ServerInstance,
        [string]$Tenant,
        [string]$AppName,
        [string]$Publisher
    )

    $app = Get-NAVAppInfo -ServerInstance $ServerInstance -Tenant $Tenant -Name $AppName -Publisher $Publisher -ErrorAction SilentlyContinue |
        Sort-Object Version -Descending |
        Select-Object -First 1

    if ($app) {
        return [version]$app.Version
    }

    return $null
}

function Install-AppPackage {
    param(
        [object]$Config,
        [object]$AppEntry,
        [string]$PackagePath,
        [switch]$DryRun
    )

    $serverInstance = [string]$Config.ServerInstance
    $tenant = [string]$Config.Tenant
    $appName = [string]$AppEntry.name
    $publisher = [string]$AppEntry.publisher
    $version = [string]$AppEntry.version
    $skipVerification = [bool]$Config.SkipVerification
    $forceSync = [bool]$Config.ForceSync

    if ($DryRun) {
        Write-AgentLog "[WhatIf] Would publish, sync, and install $publisher $appName $version on $serverInstance ($tenant)."
        return
    }

    $publishParams = @{
        ServerInstance   = $serverInstance
        Path             = $PackagePath
        SkipVerification = $skipVerification
        Force            = $true
    }

    Write-AgentLog "Publishing $publisher $appName $version to $serverInstance..."
    Publish-NAVApp @publishParams

    Write-AgentLog "Syncing schema for $appName..."
    $syncParams = @{
        ServerInstance = $serverInstance
        Name           = $appName
        Version        = $version
        Tenant         = $tenant
        Force          = $forceSync
    }
    Sync-NAVApp @syncParams

    Write-AgentLog "Installing $appName for tenant $tenant..."
    Install-NAVApp -ServerInstance $serverInstance -Name $appName -Tenant $tenant -Force

    Write-AgentLog "Installed $publisher $appName $version successfully."
}

$config = Read-AgentConfig -Path $ConfigPath
New-Item -ItemType Directory -Path $config.LogPath -Force | Out-Null
$script:LogFile = Join-Path $config.LogPath ("agent-{0:yyyyMMdd}.log" -f (Get-Date))

Write-AgentLog "ALProject4 deploy agent started."
Write-AgentLog "ServerInstance=$($config.ServerInstance) Tenant=$($config.Tenant) Source=$($config.SourcePath)"

$manifestPath = Join-Path $config.SourcePath 'manifest.json'
if (-not (Test-Path -LiteralPath $manifestPath)) {
    throw "Manifest not found on share: $manifestPath"
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
if (-not $manifest.apps -or $manifest.apps.Count -eq 0) {
    throw 'Manifest contains no apps.'
}

Import-BCAppManagementModule

$stagingPath = Join-Path $PSScriptRoot 'staging'
New-Item -ItemType Directory -Path $stagingPath -Force | Out-Null

$updatedAny = $false

foreach ($appEntry in @($manifest.apps)) {
    $appName = [string]$appEntry.name
    $publisher = [string]$appEntry.publisher
    $targetVersion = [version]$appEntry.version
    $packageFile = [string]$appEntry.file

    $installedVersion = Get-InstalledAppVersion `
        -ServerInstance $config.ServerInstance `
        -Tenant $config.Tenant `
        -AppName $appName `
        -Publisher $publisher

    if ($installedVersion -and $installedVersion -ge $targetVersion) {
        Write-AgentLog "$appName already at $($installedVersion.ToString()) (share has $($targetVersion.ToString())). Skipping."
        continue
    }

    $sourcePackage = Join-Path $config.SourcePath $packageFile
    if (-not (Test-Path -LiteralPath $sourcePackage)) {
        throw "Package file missing on share: $sourcePackage"
    }

    $localPackage = Join-Path $stagingPath $packageFile
    Copy-Item -LiteralPath $sourcePackage -Destination $localPackage -Force
    Write-AgentLog "Copied package to $localPackage"

    Install-AppPackage -Config $config -AppEntry $appEntry -PackagePath $localPackage -DryRun:$WhatIfPreference
    $updatedAny = $true
}

if (-not $updatedAny) {
    Write-AgentLog 'No updates required.'
}

Write-AgentLog 'Deploy agent finished.'
