// Every commit on the branch Jenkins watches compiles the .app files and copies them
// into the NavWS publish folder and the live backoffice site.
// Dependency sources:
//   https://github.com/Hasansabti/Nav_Utils       (InvoiceUtils.dll)
//   https://github.com/Hasansabti/AlamerUtils_AL  (AlamerUtils .app)
pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '20'))
        timestamps()
        skipDefaultCheckout(true)
    }

    triggers {
        pollSCM('H/2 * * * *')
    }

    environment {
        DROP_PATH = 'C:\\JenkinsDeploy\\NavWS\\Published\\LS-Utils'
        ALIAS_PATH = 'C:\\JenkinsDeploy\\NavWS\\Published\\ABO\\LS-Utils'
        IIS_PATH = 'C:\\sites\\backoffice\\LS-Utils'
        IIS_ALIAS_PATH = 'C:\\sites\\backoffice\\ABO\\LS-Utils'
        GIT_CREDENTIALS_ID = 'github-navws'
        DEPENDENCY_CREDENTIALS_ID = 'github-alamer-repos'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                powershell 'git -C $env:WORKSPACE config core.longpaths true'
                script {
                    def subject = bat(returnStdout: true, script: '@git log -1 --pretty=format:%%s').trim()
                    subject = subject.replace('\uFEFF', '').replaceAll(/[\r\n\u0000]/, '').trim()
                    currentBuild.description = "Compile after commit: ${subject}"
                    echo "Commit subject: [${subject}]"
                }
            }
        }

        stage('Build .app') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'github-alamer-repos',
                    usernameVariable: 'GIT_USERNAME',
                    passwordVariable: 'GIT_PASSWORD'
                )]) {
                    powershell label: 'Checkout Nav_Utils and AlamerUtils_AL', script: '''
                        $ErrorActionPreference = "Stop"
                        $basic = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("x-access-token:$env:GIT_PASSWORD"))
                        $env:GIT_TERMINAL_PROMPT = "0"
                        $env:GCM_INTERACTIVE = "Never"
                        function Get-Dependency($Name) {
                            # Keep dependency sources outside the LS Utils project.
                            # alc compiles every .al file under the project directory.
                            $dest = Join-Path 'C:/JenkinsTools/ls-utils-deps' $Name
                            if (Test-Path $dest) { Remove-Item -LiteralPath $dest -Recurse -Force }
                            New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
                            git -c credential.helper= -c "http.extraheader=AUTHORIZATION: Basic $basic" clone --depth 1 --branch master "https://github.com/Hasansabti/$Name.git" $dest
                            if ($LASTEXITCODE -ne 0) { throw "git clone $Name failed (exit $LASTEXITCODE)" }
                            Write-Host "Checked out $Name"
                        }
                        Get-Dependency "Nav_Utils"
                        Get-Dependency "AlamerUtils_AL"
                    '''
                }
                powershell label: 'Compile dependency library and AL extensions', script: '''
                    $ErrorActionPreference = "Stop"
                    $leftover = Join-Path $env:WORKSPACE "deps"
                    if (Test-Path $leftover) { Remove-Item -LiteralPath $leftover -Recurse -Force }
                    & (Join-Path $env:WORKSPACE "Scripts\\jenkins\\Build-LSUtilsApp.ps1") `
                        -DropPath $env:DROP_PATH `
                        -AliasPath $env:ALIAS_PATH `
                        -NavUtilsPath 'C:/JenkinsTools/ls-utils-deps/Nav_Utils' `
                        -AlamerUtilsPath 'C:/JenkinsTools/ls-utils-deps/AlamerUtils_AL'
                    if ($LASTEXITCODE -ne 0) { throw "Build-LSUtilsApp.ps1 failed (exit $LASTEXITCODE)" }
                '''
                powershell label: 'Copy packages onto the NavWS site', script: '''
                    $ErrorActionPreference = "Stop"
                    if (!(Test-Path -LiteralPath $env:DROP_PATH)) { throw "Drop folder missing: $($env:DROP_PATH)" }
                    function Copy-Tree($Source, $Dest) {
                        if (!(Test-Path -LiteralPath $Source)) { throw "Missing package folder: $Source" }
                        New-Item -ItemType Directory -Force -Path $Dest | Out-Null
                        & robocopy $Source $Dest /E /R:2 /W:2
                        $code = $LASTEXITCODE
                        if ($code -ge 8) { throw "robocopy to $Dest failed (exit $code)" }
                        Write-Host "Copied $Source to $Dest (robocopy $code)"
                    }
                    Copy-Tree $env:DROP_PATH $env:IIS_PATH
                    Copy-Tree $env:ALIAS_PATH $env:IIS_ALIAS_PATH
                    exit 0
                '''
            }
        }
    }

    post {
        success {
            archiveArtifacts artifacts: 'artifacts/*.app', fingerprint: true
            archiveArtifacts artifacts: 'artifacts/InvoiceUtils.dll', fingerprint: true, allowEmptyArchive: true
            echo "SUCCESS: .app files archived, copied to ${DROP_PATH}, and deployed to ${IIS_PATH}"
        }
        failure {
            echo 'FAILED: see the console log for AL compiler errors.'
        }
    }
}
