pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    component: ci-agent
spec:
  containers:
  - name: docker
    image: docker:latest
    command: [ "cat" ]
    tty: true
    volumeMounts:
    - mountPath: /var/run/docker.sock
      name: docker-sock
  - name: kubectl
    image: alpine:latest
    command: [ "cat" ]
    tty: true
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
'''
        }
    }

    stages {
        stage('Build Auxiliary Image') {
            steps {
                container('docker') {
                    // Combines cd and build inside a single shell session
                    sh "cd bank-aux-image && docker build --no-cache -t bank-aux:v${BUILD_NUMBER} ."
                }
            }
        }

        stage('Deploy Infrastructure & Scale') {
            steps {
                container('kubectl') {
                    // Installs kubectl tool in the alpine agent container
                    sh 'apk add --no-cache kubectl'
                    
                    dir('k8s') {
                        // 1. Updates restartVersion at root spec
                        sh "sed -i 's/restartVersion: .*/restartVersion: \"${BUILD_NUMBER}\"/' domain.yaml"
                        
                        // 2. Updates introspectVersion at root spec
                        sh "sed -i 's/introspectVersion: .*/introspectVersion: \"${BUILD_NUMBER}\"/' domain.yaml"
                        
                        // 3. Updates auxiliary image tag safely
                        sh "sed -i 's|image: \"bank-aux:.*\"|image: \"bank-aux:v${BUILD_NUMBER}\"|g' domain.yaml"
                        
                        // 4. Batch applies all Kubernetes manifests efficiently
                        sh '''
                            kubectl apply -f secrets.yaml
                            kubectl apply -f configmap.yaml
                            kubectl apply -f mysql.yaml
                            kubectl apply -f bank-cluster.yaml
                            kubectl apply -f domain.yaml
                            kubectl apply -f pod-monitor.yaml
                            kubectl apply -f ingress.yaml
                        '''
                    }
                }
            }
        }
    }
}
