// The .app is built only when the commit subject line is exactly "publish" (case-insensitive).
// Example: git commit -m "publish"
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
                            echo 'Publish requested — will compile the AL extension to a .app file.'
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
                powershell label: 'Compile AL extension', script: '''
                    $ErrorActionPreference = "Stop"
                    & (Join-Path $env:WORKSPACE "Scripts\\jenkins\\Build-LSUtilsApp.ps1") -DropPath $env:DROP_PATH
                    if ($LASTEXITCODE -ne 0) { throw "Build-LSUtilsApp.ps1 failed (exit $LASTEXITCODE)" }
                '''
                script {
                    currentBuild.description = 'Published AL .app'
                }
            }
        }
    }

    post {
        success {
            script {
                if (fileExists("${env.PUBLISH_FLAG_FILE}")) {
                    archiveArtifacts artifacts: 'artifacts/*.app', fingerprint: true
                    echo "SUCCESS: .app archived and copied to ${env.DROP_PATH}"
                }
            }
        }
        failure {
            echo 'FAILED: see the console log for AL compiler errors.'
        }
    }
}
