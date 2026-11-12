#Requires -Version 5.1
<#
.SYNOPSIS
    Builds Nav_Utils, AlamerUtils, and LS Utils, then publishes the .app packages.

.DESCRIPTION
    Nav_Utils is the C# library (InvoiceUtils.dll). AlamerUtils_AL wraps that
    library as the AlamerUtils extension. LS Utils depends on AlamerUtils 1.3.0.0.
    This script compiles them in that order and copies the .app files to the drop folder.

.PARAMETER ProjectPath
    Root folder of the LS Utils AL project. Defaults to the repo root.

.PARAMETER DropPath
    Folder that receives the published .app files and manifest.json.

.PARAMETER AlamerUtilsPath
    Checkout of https://github.com/Hasansabti/AlamerUtils_AL

.PARAMETER NavUtilsPath
    Checkout of https://github.com/Hasansabti/Nav_Utils

.PARAMETER AliasPath
    Optional folder that receives stable download names (AlamerUtils.app and LSUtils.app)
    for the Store Control and Till Setup pages.
#>
[CmdletBinding()]
param(
    [string]$ProjectPath,
    [string]$DropPath = 'C:\JenkinsDeploy\NavWS\Published\LS-Utils',
    [string]$AlamerUtilsPath,
    [string]$NavUtilsPath,
    [string]$AliasPath
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

function Get-AppFileName {
    param($AppJson)
    return '{0}_{1}_{2}.app' -f $AppJson.publisher, $AppJson.name, $AppJson.version
}

function Get-AssemblyProbePath {
    param([string[]]$ExtraDirs)
    $probeDirs = @($ExtraDirs) + @(
        'C:\Windows\Microsoft.NET\Framework\v4.0.30319',
        'C:\Windows\Microsoft.NET\Framework64\v4.0.30319'
    )
    return (@($probeDirs | Where-Object { $_ -and (Test-Path -LiteralPath $_) }) -join ';')
}

function Invoke-Alc {
    param(
        [string]$Alc,
        [string]$Project,
        [string]$OutFile
    )

    $cache = Join-Path $Project '.alpackages'
    $probe = Get-AssemblyProbePath -ExtraDirs @((Join-Path $Project '.netpackages'))
    $outDir = Split-Path -Parent $OutFile
    if (-not (Test-Path -LiteralPath $outDir)) {
        New-Item -ItemType Directory -Force -Path $outDir | Out-Null
    }
    if (Test-Path -LiteralPath $OutFile) {
        Remove-Item -LiteralPath $OutFile -Force
    }

    Write-Host "AL project: $Project"
    Write-Host "AL output:  $OutFile"
    & $Alc "/project:$Project" "/packagecachepath:$cache" "/assemblyprobingpaths:$probe" '/generatecode+' "/out:$OutFile" | Out-Host
    if ($LASTEXITCODE -ne 0) {
        throw "AL compilation failed for $Project with exit code $LASTEXITCODE"
    }

    $built = Get-Item -LiteralPath $OutFile
    if ($built.Length -lt 1024) {
        throw "Compiler did not produce a package (size $($built.Length) bytes): $OutFile"
    }

    Write-Host "Built: $($built.FullName) ($($built.Length) bytes)"
    return $built
}

function Resolve-MSBuild {
    $candidates = @(
        'C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe',
        'C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe'
    )
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }
    throw 'MSBuild.exe was not found on the Jenkins agent.'
}

function Build-NavUtilsDll {
    param(
        [string]$NavPath,
        [string]$DestinationDir
    )

    $project = Join-Path $NavPath 'AlamerUtils3\InvoiceUtils.csproj'
    $solution = Join-Path $NavPath 'InvoiceUtils.sln'
    if (-not (Test-Path -LiteralPath $project)) {
        throw "Nav_Utils project not found: $project"
    }

    $source = Join-Path $NavPath 'AlamerUtils3\InvoiceUtils.cs'
    if (-not (Test-Path -LiteralPath $source)) {
        throw "Nav_Utils source not found: $source"
    }
    $sourceText = Get-Content -LiteralPath $source -Raw
    if ($sourceText -notmatch 'getTextBitmap') {
        $method = @'

        public string getTextBitmap(string value, int width, int height, int fontSize, int borderWidth, string fontName, bool bold, string server)
        {
            if (width <= 0) width = 300;
            if (height <= 0) height = 40;
            if (fontSize <= 0) fontSize = 12;
            if (string.IsNullOrEmpty(fontName)) fontName = "Tahoma";
            System.Drawing.FontStyle style = bold ? System.Drawing.FontStyle.Bold : System.Drawing.FontStyle.Regular;
            Bitmap bitmap = new Bitmap(width, height);
            Graphics graphics = Graphics.FromImage(bitmap);
            graphics.Clear(Color.White);
            System.Drawing.Font font = new System.Drawing.Font(fontName, fontSize, style, GraphicsUnit.Pixel);
            SolidBrush brush = new SolidBrush(Color.Black);
            StringFormat format = new StringFormat();
            format.Alignment = StringAlignment.Center;
            format.LineAlignment = StringAlignment.Center;
            float inset = borderWidth > 0 ? borderWidth : 0;
            RectangleF rect = new RectangleF(inset, inset, Math.Max(1, width - (inset * 2)), Math.Max(1, height - (inset * 2)));
            graphics.DrawString(value ?? "", font, brush, rect, format);
            font.Dispose();
            brush.Dispose();
            format.Dispose();
            graphics.Dispose();
            string filename = Path.GetTempPath() + Guid.NewGuid().ToString() + ".tmp.bmp";
            bitmap.Save(filename, ImageFormat.Bmp);
            bitmap.Dispose();
            if (!string.IsNullOrEmpty(server))
            {
                return sendFile(filename, server);
            }
            return filename;
        }

'@
        $marker = "        public string generateUUID()"
        if ($sourceText.IndexOf($marker) -lt 0) {
            throw 'Could not insert getTextBitmap into InvoiceUtils.cs'
        }
        $sourceText = $sourceText.Replace($marker, $method + $marker)
        Set-Content -LiteralPath $source -Value $sourceText -Encoding UTF8
        Write-Host 'Added getTextBitmap to InvoiceUtils.cs for the AlamerUtils compiler.'
    }

    $assemblyInfo = Join-Path $NavPath 'AlamerUtils3\Properties\AssemblyInfo.cs'
    if (-not (Test-Path -LiteralPath $assemblyInfo)) {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $assemblyInfo) | Out-Null
        @'
using System.Reflection;

[assembly: AssemblyTitle("InvoiceUtils")]
[assembly: AssemblyProduct("InvoiceUtils")]
[assembly: AssemblyVersion("1.3.0.0")]
[assembly: AssemblyFileVersion("1.3.0.0")]
'@ | Set-Content -LiteralPath $assemblyInfo -Encoding ASCII
        Write-Host "Created missing $assemblyInfo"
    }

    $nuget = 'C:\Tools\NuGet\nuget.exe'
    if (-not (Test-Path -LiteralPath $nuget)) {
        throw "nuget.exe not found: $nuget"
    }

    Write-Host "Restoring NuGet packages for Nav_Utils"
    & $nuget restore $solution -NonInteractive | Out-Host
    if ($LASTEXITCODE -ne 0) {
        throw "nuget restore failed with exit code $LASTEXITCODE"
    }

    # Keep this path free of spaces. A trailing backslash next to a quote
    # is eaten by the Windows command line and breaks MSBuild.
    $output = 'C:\JenkinsTools\ls-utils-publish\net472\'
    New-Item -ItemType Directory -Force -Path $output | Out-Null
    $msbuild = Resolve-MSBuild
    Write-Host "Building InvoiceUtils.dll with $msbuild"
    & $msbuild $project /t:Build "/p:Configuration=Release" "/p:OutputPath=$output." /p:DebugType=none /v:m /nologo | Out-Host
    if ($LASTEXITCODE -ne 0) {
        throw "MSBuild failed with exit code $LASTEXITCODE"
    }

    $dll = Join-Path $output 'InvoiceUtils.dll'
    if (-not (Test-Path -LiteralPath $dll)) {
        throw "InvoiceUtils.dll was not built: $dll"
    }

    New-Item -ItemType Directory -Force -Path $DestinationDir | Out-Null
    Copy-Item -LiteralPath $dll -Destination (Join-Path $DestinationDir 'InvoiceUtils.dll') -Force
    Write-Host "Copied InvoiceUtils.dll to $DestinationDir"
    return (Join-Path $DestinationDir 'InvoiceUtils.dll')
}

$appJsonPath = Join-Path $ProjectPath 'app.json'
if (-not (Test-Path -LiteralPath $appJsonPath)) {
    throw "app.json not found in $ProjectPath"
}

$appJson = Get-Content -LiteralPath $appJsonPath -Raw | ConvertFrom-Json
$alc = Ensure-Bc14Compiler
$artifacts = Join-Path $ProjectPath 'artifacts'
New-Item -ItemType Directory -Force -Path $artifacts | Out-Null

$publishedApps = @()

if ($NavUtilsPath -and $AlamerUtilsPath) {
    $navDllDir = Join-Path $AlamerUtilsPath '.netpackages'
    Build-NavUtilsDll -NavPath $NavUtilsPath -DestinationDir $navDllDir | Out-Null
    Copy-Item -LiteralPath (Join-Path $navDllDir 'InvoiceUtils.dll') -Destination (Join-Path $artifacts 'InvoiceUtils.dll') -Force
}

if ($AlamerUtilsPath) {
    $dependencyJson = Get-Content -LiteralPath (Join-Path $AlamerUtilsPath 'app.json') -Raw | ConvertFrom-Json
    $dependencyFile = Get-AppFileName -AppJson $dependencyJson
    $dependencyOutput = Join-Path $artifacts $dependencyFile
    Invoke-Alc -Alc $alc -Project $AlamerUtilsPath -OutFile $dependencyOutput | Out-Null

    $packageCache = Join-Path $ProjectPath '.alpackages'
    New-Item -ItemType Directory -Force -Path $packageCache | Out-Null
    Copy-Item -LiteralPath $dependencyOutput -Destination (Join-Path $packageCache $dependencyFile) -Force
    Write-Host "Updated LS Utils dependency package: $dependencyFile"

    $publishedApps += [ordered]@{
        name      = [string]$dependencyJson.name
        publisher = [string]$dependencyJson.publisher
        version   = [string]$dependencyJson.version
        file      = $dependencyFile
    }
}

$appFileName = Get-AppFileName -AppJson $appJson
$buildOutput = Join-Path $artifacts $appFileName
Write-Host "Building LS Utils with: $alc"
Invoke-Alc -Alc $alc -Project $ProjectPath -OutFile $buildOutput | Out-Null

$publishedApps += [ordered]@{
    name      = [string]$appJson.name
    publisher = [string]$appJson.publisher
    version   = [string]$appJson.version
    file      = $appFileName
}

New-Item -ItemType Directory -Force -Path $DropPath | Out-Null
foreach ($app in $publishedApps) {
    $source = Join-Path $artifacts $app.file
    $published = Join-Path $DropPath $app.file
    Copy-Item -LiteralPath $source -Destination $published -Force
    Write-Host "Published: $published"
}

$dllArtifact = Join-Path $artifacts 'InvoiceUtils.dll'
if (Test-Path -LiteralPath $dllArtifact) {
    Copy-Item -LiteralPath $dllArtifact -Destination (Join-Path $DropPath 'InvoiceUtils.dll') -Force
    Write-Host "Published: $(Join-Path $DropPath 'InvoiceUtils.dll')"
}

$manifest = [ordered]@{
    publishedAt = (Get-Date).ToString('o')
    publishedBy = $env:COMPUTERNAME
    buildUrl    = $env:BUILD_URL
    apps        = @($publishedApps)
}
$manifestPath = Join-Path $DropPath 'manifest.json'
$manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
Write-Host "Manifest: $manifestPath"

if ($AliasPath) {
    New-Item -ItemType Directory -Force -Path $AliasPath | Out-Null
    $alamerApp = Get-ChildItem -LiteralPath $DropPath -Filter '*AlamerUtils*.app' | Select-Object -First 1
    $lsApp = Get-ChildItem -LiteralPath $DropPath -Filter '*ALProject4*.app' | Select-Object -First 1
    if (-not $alamerApp -or -not $lsApp) {
        throw "Could not find AlamerUtils and LS Utils .app files in $DropPath"
    }
    Copy-Item -LiteralPath $alamerApp.FullName -Destination (Join-Path $AliasPath 'AlamerUtils.app') -Force
    Copy-Item -LiteralPath $lsApp.FullName -Destination (Join-Path $AliasPath 'LSUtils.app') -Force
    Copy-Item -LiteralPath $alamerApp.FullName -Destination (Join-Path $AliasPath $alamerApp.Name) -Force
    Copy-Item -LiteralPath $lsApp.FullName -Destination (Join-Path $AliasPath $lsApp.Name) -Force
    Copy-Item -LiteralPath $manifestPath -Destination (Join-Path $AliasPath 'manifest.json') -Force
    $dll = Join-Path $DropPath 'InvoiceUtils.dll'
    if (Test-Path -LiteralPath $dll) {
        Copy-Item -LiteralPath $dll -Destination (Join-Path $AliasPath 'InvoiceUtils.dll') -Force
    }
    Write-Host "Stable packages: $AliasPath"
}
