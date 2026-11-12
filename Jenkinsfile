// The .app files are built only when the commit subject line is exactly "publish" (case-insensitive).
// Example: git commit -m "publish"
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
        PUBLISH_FLAG_FILE = 'jenkins-do-publish-app.flag'
        DROP_PATH = 'C:\\JenkinsDeploy\\NavWS\\Published\\LS-Utils'
        GIT_CREDENTIALS_ID = 'github-navws'
        DEPENDENCY_CREDENTIALS_ID = 'github-alamer-repos'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                powershell 'git -C $env:WORKSPACE config core.longpaths true'
            }
        }

        stage('Publish trigger') {
            steps {
                script {
                    dir(env.WORKSPACE) {
                        if (fileExists(env.PUBLISH_FLAG_FILE)) {
                            echo "Removing leftover ${env.PUBLISH_FLAG_FILE} from prior build."
                            powershell "Remove-Item -LiteralPath '${env.PUBLISH_FLAG_FILE}' -Force -ErrorAction SilentlyContinue"
                        }

                        def subject = bat(returnStdout: true, script: '@git log -1 --pretty=format:%%s').trim()
                        subject = subject.replace('\uFEFF', '').replaceAll(/[\r\n\u0000]/, '').trim()
                        echo "Commit subject: [${subject}]"
                        if (subject.equalsIgnoreCase('publish')) {
                            writeFile file: env.PUBLISH_FLAG_FILE, text: 'publish'
                            echo 'Publish requested — will build Nav_Utils, AlamerUtils, and LS Utils.'
                        } else {
                            currentBuild.description = 'Skipped — commit subject is not "publish"'
                            echo 'Skipping .app (use: git commit -m "publish").'
                        }
                    }
                }
            }
        }

        stage('Build .app') {
            when {
                expression { return fileExists("${env.PUBLISH_FLAG_FILE}") }
            }
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
                            $dest = Join-Path $env:WORKSPACE "deps\\$Name"
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
                    & (Join-Path $env:WORKSPACE "Scripts\\jenkins\\Build-LSUtilsApp.ps1") `
                        -DropPath $env:DROP_PATH `
                        -NavUtilsPath (Join-Path $env:WORKSPACE "deps\\Nav_Utils") `
                        -AlamerUtilsPath (Join-Path $env:WORKSPACE "deps\\AlamerUtils_AL")
                    if ($LASTEXITCODE -ne 0) { throw "Build-LSUtilsApp.ps1 failed (exit $LASTEXITCODE)" }
                '''
                script {
                    currentBuild.description = 'Published AlamerUtils and LS Utils .app files'
                }
            }
        }
    }

    post {
        success {
            script {
                if (fileExists("${env.PUBLISH_FLAG_FILE}")) {
                    archiveArtifacts artifacts: 'artifacts/*.app', fingerprint: true
                    archiveArtifacts artifacts: 'artifacts/InvoiceUtils.dll', fingerprint: true, allowEmptyArchive: true
                    echo "SUCCESS: .app files archived and copied to ${env.DROP_PATH}"
                }
            }
        }
        failure {
            echo 'FAILED: see the console log for AL compiler errors.'
        }
    }
}
