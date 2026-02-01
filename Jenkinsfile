@Library('homelab-jenkins-library@main') _

def IMAGE_NAME = 'openclaw'
def REGISTRY = 'nexus.erauner.dev'

pipeline {
    agent {
        kubernetes {
            yaml homelab.podTemplate('kaniko')
        }
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
    }

    environment {
        // OpenClaw base version to use
        OPENCLAW_VERSION = '2026.1.29-amd64'
        // Tool versions
        MDBASE_VERSION = '0.7.0'
        TODOIST_VERSION = '0.23.0'
        GOG_VERSION = '0.9.0'
        GH_VERSION = '2.61.0'
    }

    stages {
        stage('Build & Push') {
            when {
                anyOf {
                    branch 'main'
                    changeRequest()
                }
            }
            steps {
                container('kaniko') {
                    script {
                        def imageTag = env.BRANCH_NAME == 'main' ? 'latest' : "pr-${env.CHANGE_ID}"
                        def fullImage = "${REGISTRY}/homelab/${IMAGE_NAME}:${imageTag}"
                        def versionedImage = "${REGISTRY}/homelab/${IMAGE_NAME}:${OPENCLAW_VERSION}"

                        sh """
                            /kaniko/executor \
                                --context=dir://. \
                                --dockerfile=Dockerfile \
                                --destination=${fullImage} \
                                --destination=${versionedImage} \
                                --build-arg=OPENCLAW_VERSION=${OPENCLAW_VERSION} \
                                --build-arg=MDBASE_VERSION=${MDBASE_VERSION} \
                                --build-arg=TODOIST_VERSION=${TODOIST_VERSION} \
                                --build-arg=GOG_VERSION=${GOG_VERSION} \
                                --build-arg=GH_VERSION=${GH_VERSION} \
                                --cache=true \
                                --cache-repo=${REGISTRY}/homelab/cache
                        """

                        echo "Pushed: ${fullImage}"
                        echo "Pushed: ${versionedImage}"
                    }
                }
            }
        }
    }

    post {
        success {
            script {
                if (env.BRANCH_NAME == 'main') {
                    homelab.notifyDiscord(status: 'SUCCESS', message: "OpenClaw image pushed to ${REGISTRY}")
                }
            }
        }
        failure {
            script {
                homelab.notifyDiscord(status: 'FAILURE')
            }
        }
    }
}
