#Requires -Version 5.1
<#
.SYNOPSIS
    Compiles the LS Utils AL project with the Business Central 14 compiler and publishes the .app.

.PARAMETER ProjectPath
    Root folder of the AL project. Defaults to the repo root.

.PARAMETER DropPath
    Folder that receives the published .app and manifest.json.
    Defaults to C:\JenkinsDeploy\NavWS\Published\LS-Utils.
#>
[CmdletBinding()]
param(
    [string]$ProjectPath,
    [string]$DropPath = 'C:\JenkinsDeploy\NavWS\Published\LS-Utils'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $ProjectPath) {
    $ProjectPath = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

function Ensure-Bc14Compiler {
    $alc = 'C:\JenkinsTools\alc-bc140\bin\alc.exe'
    if (Test-Path -LiteralPath $alc) {
        return $alc
    }

    $vsix = 'C:\Program Files (x86)\Microsoft Dynamics 365 Business Central\140\AL Development Environment\ALLanguage.vsix'
    if (-not (Test-Path -LiteralPath $vsix)) {
        throw "BC 14 AL compiler package not found: $vsix"
    }

    Write-Host "Extracting BC 14 AL compiler to C:\JenkinsTools\alc-bc140"
    $dest = 'C:\JenkinsTools\alc-bc140'
    New-Item -ItemType Directory -Force -Path $dest | Out-Null

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($vsix)
    try {
        foreach ($entry in $zip.Entries) {
            $name = $entry.FullName.Replace('\', '/')
            if (-not $name.StartsWith('extension/bin/')) { continue }
            if ($name.StartsWith('extension/bin/darwin/')) { continue }

            $relative = $name.Substring('extension/'.Length)
            $outFile = Join-Path $dest ($relative -replace '/', '\')
            $outDir = Split-Path -Parent $outFile
            if (-not (Test-Path -LiteralPath $outDir)) {
                New-Item -ItemType Directory -Force -Path $outDir | Out-Null
            }
            if ($entry.Name) {
                [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $outFile, $true)
            }
        }
    }
    finally {
        $zip.Dispose()
    }

    if (-not (Test-Path -LiteralPath $alc)) {
        throw "alc.exe was not extracted to $alc"
    }

    return $alc
}

$appJsonPath = Join-Path $ProjectPath 'app.json'
if (-not (Test-Path -LiteralPath $appJsonPath)) {
    throw "app.json not found in $ProjectPath"
}

$appJson = Get-Content -LiteralPath $appJsonPath -Raw | ConvertFrom-Json
$alc = Ensure-Bc14Compiler
$packageCache = Join-Path $ProjectPath '.alpackages'
$artifacts = Join-Path $ProjectPath 'artifacts'
New-Item -ItemType Directory -Force -Path $artifacts | Out-Null

$appFileName = '{0}_{1}_{2}.app' -f $appJson.publisher, $appJson.name, $appJson.version
$buildOutput = Join-Path $artifacts $appFileName
if (Test-Path -LiteralPath $buildOutput) {
    Remove-Item -LiteralPath $buildOutput -Force
}

$probeDirs = @(
    (Join-Path $ProjectPath '.netpackages'),
    'C:\Windows\Microsoft.NET\Framework\v4.0.30319',
    'C:\Windows\Microsoft.NET\Framework64\v4.0.30319'
)
$probe = @($probeDirs | Where-Object { Test-Path -LiteralPath $_ }) -join ';'

Write-Host "Building with: $alc"
Write-Host "Project:       $ProjectPath"
Write-Host "Output:        $buildOutput"

& $alc "/project:$ProjectPath" "/packagecachepath:$packageCache" "/assemblyprobingpaths:$probe" '/generatecode+' "/out:$buildOutput"
if ($LASTEXITCODE -ne 0) {
    throw "AL compilation failed with exit code $LASTEXITCODE"
}

$built = Get-Item -LiteralPath $buildOutput
if ($built.Length -lt 1024) {
    throw "Compiler did not produce a package (size $($built.Length) bytes): $buildOutput"
}

Write-Host "Built: $($built.FullName) ($($built.Length) bytes)"

New-Item -ItemType Directory -Force -Path $DropPath | Out-Null
$published = Join-Path $DropPath $appFileName
Copy-Item -LiteralPath $buildOutput -Destination $published -Force

$manifest = [ordered]@{
    publishedAt = (Get-Date).ToString('o')
    publishedBy = $env:COMPUTERNAME
    buildUrl    = $env:BUILD_URL
    apps        = @(
        [ordered]@{
            name      = [string]$appJson.name
            publisher = [string]$appJson.publisher
            version   = [string]$appJson.version
            file      = $appFileName
        }
    )
}
$manifestPath = Join-Path $DropPath 'manifest.json'
$manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $manifestPath -Encoding UTF8

Write-Host "Published: $published"
Write-Host "Manifest:  $manifestPath"
