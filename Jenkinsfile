def IMAGE_NAME = 'openclaw'
def REGISTRY = 'docker.nexus.erauner.dev'

// Inline kaniko pod template (no shared library dependency)
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
            echo "Build succeeded - image pushed to ${REGISTRY}/homelab/${IMAGE_NAME}"
        }
        failure {
            echo "Build failed"
        }
    }
}
