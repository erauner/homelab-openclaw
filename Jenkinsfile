def IMAGE_NAME = 'openclaw-runtime'
def REGISTRY = 'docker.nexus.erauner.dev'

def kanikoPodTemplate = '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    workload-type: ci-builds
spec:
  imagePullSecrets:
  - name: nexus-registry-credentials
  containers:
  - name: jnlp
    image: jenkins/inbound-agent:3355.v388858a_47b_33-3-jdk21
    resources:
      requests:
        cpu: 100m
        memory: 256Mi
      limits:
        cpu: 500m
        memory: 512Mi
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command: ['sleep', '3600']
    volumeMounts:
    - name: nexus-creds
      mountPath: /kaniko/.docker
    resources:
      requests:
        cpu: 500m
        memory: 1Gi
      limits:
        cpu: 1000m
        memory: 2Gi
  volumes:
  - name: nexus-creds
    secret:
      secretName: nexus-registry-credentials
'''

pipeline {
    agent {
        kubernetes {
            yaml kanikoPodTemplate
        }
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '20'))
        timeout(time: 45, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    environment {
        OPENCLAW_VERSION = '2026.3.7-amd64'
        GH_VERSION = '2.61.0'
        GOG_VERSION = '0.9.0'
        MDBASE_CLI_VERSION = '0.7.0'
        TODOIST_CLI_VERSION = '0.8.23'
        JQ_VERSION = '1.7.1'
        RIPGREP_VERSION = '14.1.1'
        KUBECTL_VERSION = 'v1.31.3'
        MCPORTER_VERSION = 'latest'
        SUMMARIZE_VERSION = 'latest'
    }

    stages {
        stage('Prepare Tags') {
            steps {
                script {
                    env.COMMIT_SHORT = sh(returnStdout: true, script: 'git rev-parse --short=12 HEAD').trim()
                    env.RUNTIME_TAG = "${env.OPENCLAW_VERSION}-runtime"
                    env.IMMUTABLE_TAG = "${env.RUNTIME_TAG}-${env.COMMIT_SHORT}"
                    env.PR_TAG = "pr-${env.CHANGE_ID ?: 'local'}-${env.COMMIT_SHORT}"

                    echo "Base OpenClaw: ${env.OPENCLAW_VERSION}"
                    echo "Stable runtime tag: ${env.RUNTIME_TAG}"
                    echo "Immutable runtime tag: ${env.IMMUTABLE_TAG}"
                }
            }
        }

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
                        def destinations = []
                        if (env.BRANCH_NAME == 'main') {
                            destinations << "${REGISTRY}/homelab/${IMAGE_NAME}:latest"
                            destinations << "${REGISTRY}/homelab/${IMAGE_NAME}:${env.RUNTIME_TAG}"
                            destinations << "${REGISTRY}/homelab/${IMAGE_NAME}:${env.IMMUTABLE_TAG}"
                        } else {
                            destinations << "${REGISTRY}/homelab/${IMAGE_NAME}:${env.PR_TAG}"
                        }

                        def destinationArgs = destinations.collect { "--destination=${it}" }.join(' ')

                        sh """
                            /kaniko/executor \
                                --context=dir://. \
                                --dockerfile=Dockerfile \
                                ${destinationArgs} \
                                --build-arg=OPENCLAW_VERSION=${OPENCLAW_VERSION} \
                                --build-arg=GH_VERSION=${GH_VERSION} \
                                --build-arg=GOG_VERSION=${GOG_VERSION} \
                                --build-arg=MDBASE_CLI_VERSION=${MDBASE_CLI_VERSION} \
                                --build-arg=TODOIST_CLI_VERSION=${TODOIST_CLI_VERSION} \
                                --build-arg=JQ_VERSION=${JQ_VERSION} \
                                --build-arg=RIPGREP_VERSION=${RIPGREP_VERSION} \
                                --build-arg=KUBECTL_VERSION=${KUBECTL_VERSION} \
                                --build-arg=MCPORTER_VERSION=${MCPORTER_VERSION} \
                                --build-arg=SUMMARIZE_VERSION=${SUMMARIZE_VERSION} \
                                --cache=true \
                                --cache-repo=${REGISTRY}/homelab/cache
                        """

                        destinations.each { echo "Pushed: ${it}" }
                    }
                }
            }
        }
    }

    post {
        success {
            script {
                echo "Build succeeded for ${REGISTRY}/homelab/${IMAGE_NAME}"
                if (env.BRANCH_NAME == 'main') {
                    echo "Use in k8s: ${REGISTRY}/homelab/${IMAGE_NAME}:${env.RUNTIME_TAG}"
                }
            }
        }
        failure {
            echo "Build failed"
        }
    }
}
