#Requires -Version 5.1
<#
.SYNOPSIS
    Builds ALProject4 and publishes the .app package to a shared drop folder.

.DESCRIPTION
    Compiles the AL project, copies the main app (and optional dependencies) to a
    UNC or local folder, and writes manifest.json for server agents to consume.

.PARAMETER ProjectPath
    Root folder of the AL project. Defaults to the repo root.

.PARAMETER DropPath
    Shared folder agents read from, e.g. \\build-server\ALDeploy\ALProject4

.PARAMETER AlcPath
    Path to alc.exe. Auto-detected from common AL Language install locations if omitted.

.PARAMETER IncludeDependencies
    Also copy dependency apps listed in app.json from .alpackages to the drop folder.
#>
[CmdletBinding()]
param(
    [string]$ProjectPath,
    [Parameter(Mandatory = $true)]
    [string]$DropPath,

    [string]$AlcPath,
    [switch]$IncludeDependencies
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $ProjectPath) {
    $ProjectPath = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

function Resolve-AlcPath {
    param([string]$ExplicitPath)

    if ($ExplicitPath -and (Test-Path -LiteralPath $ExplicitPath)) {
        return (Resolve-Path -LiteralPath $ExplicitPath).Path
    }

    $candidates = @(
        "${env:ProgramFiles}\Microsoft Dynamics 365 Business Central\*\AL Development Environment\bin\alc.exe",
        "${env:ProgramFiles}\Microsoft Dynamics 365 Business Central\AL Development Environment\bin\alc.exe",
        "${env:ProgramFiles(x86)}\Microsoft Dynamics 365 Business Central\*\AL Development Environment\bin\alc.exe"
    )

    foreach ($pattern in $candidates) {
        $found = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue |
            Sort-Object FullName -Descending |
            Select-Object -First 1 -ExpandProperty FullName

        if ($found) {
            return $found
        }
    }

    $command = Get-Command alc.exe -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    throw 'alc.exe not found. Install the AL Language extension or pass -AlcPath.'
}

function Get-AppFileName {
    param(
        [string]$Publisher,
        [string]$Name,
        [string]$Version
    )

    return ('{0}_{1}_{2}.app' -f $Publisher, $Name, $Version)
}

$appJsonPath = Join-Path $ProjectPath 'app.json'
if (-not (Test-Path -LiteralPath $appJsonPath)) {
    throw "app.json not found in $ProjectPath"
}

$appJson = Get-Content -LiteralPath $appJsonPath -Raw | ConvertFrom-Json
$alc = Resolve-AlcPath -ExplicitPath $AlcPath
$packageCache = Join-Path $ProjectPath '.alpackages'

Write-Host "Building with: $alc"
Write-Host "Project:       $ProjectPath"

$buildOutput = Join-Path $ProjectPath ("{0}_{1}_{2}.app" -f $appJson.publisher, $appJson.name, $appJson.version)
if (Test-Path -LiteralPath $buildOutput) {
    Remove-Item -LiteralPath $buildOutput -Force
}

& $alc /project:"$ProjectPath" /out:"$buildOutput" /packagecachepath:"$packageCache"
if ($LASTEXITCODE -ne 0) {
    throw "AL compilation failed with exit code $LASTEXITCODE"
}

if (-not (Test-Path -LiteralPath $buildOutput)) {
    throw "Build completed but output file was not created: $buildOutput"
}

Write-Host "Built: $buildOutput"

New-Item -ItemType Directory -Path $DropPath -Force | Out-Null

$manifestApps = @(
    [ordered]@{
        name      = [string]$appJson.name
        publisher = [string]$appJson.publisher
        version   = [string]$appJson.version
        file      = Get-AppFileName -Publisher $appJson.publisher -Name $appJson.name -Version $appJson.version
    }
)

$mainDropFile = Join-Path $DropPath $manifestApps[0].file
Copy-Item -LiteralPath $buildOutput -Destination $mainDropFile -Force
Write-Host "Copied main app to: $mainDropFile"

if ($IncludeDependencies -and $appJson.dependencies) {
    foreach ($dependency in @($appJson.dependencies)) {
        $dependencyFile = Get-AppFileName -Publisher $dependency.publisher -Name $dependency.name -Version $dependency.version
        $dependencySource = Join-Path $packageCache $dependencyFile

        if (-not (Test-Path -LiteralPath $dependencySource)) {
            Write-Warning "Dependency package not found in .alpackages: $dependencyFile"
            continue
        }

        Copy-Item -LiteralPath $dependencySource -Destination (Join-Path $DropPath $dependencyFile) -Force
        Write-Host "Copied dependency: $dependencyFile"

        $manifestApps += [ordered]@{
            name      = [string]$dependency.name
            publisher = [string]$dependency.publisher
            version   = [string]$dependency.version
            file      = $dependencyFile
        }
    }
}

$manifest = [ordered]@{
    publishedAt = (Get-Date).ToString('o')
    publishedBy = $env:COMPUTERNAME
    apps        = $manifestApps
}

$manifestPath = Join-Path $DropPath 'manifest.json'
$manifest | ConvertTo-Json -Depth 5 | Set-Content -Path $manifestPath -Encoding UTF8

Write-Host ''
Write-Host 'Release published successfully.'
Write-Host "Drop folder: $DropPath"
Write-Host "Manifest:    $manifestPath"
Write-Host ''
Write-Host 'Server agents will pick up the new version on their next poll.'
