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
                    sh "cd bank-aux-image && docker build --no-cache -t bank-aux:v${BUILD_NUMBER} ."
                }
            }
        }
        stage('Deploy Infrastructure & Scale') {
            steps {
                container('kubectl') {
                    sh 'apk add --no-cache kubectl'
                    
                    // 1. Updates restartVersion at root spec
                    sh "sed -i 's/restartVersion: .*/restartVersion: \"${BUILD_NUMBER}\"/' domain.yaml"
                    
                    // 2. Updates introspectVersion at root spec
                    sh "sed -i 's/introspectVersion: .*/introspectVersion: \"${BUILD_NUMBER}\"/' domain.yaml"
                    
                    // 3. Updates your auxiliary image tag inside the file
                    sh "sed -i 's|image: \"bank-aux:.*\"|image: \"bank-aux:v${BUILD_NUMBER}\"|g' domain.yaml"
                    
                    sh 'kubectl apply -f secrets.yaml'
                    sh 'kubectl apply -f configmap.yaml'
                    sh 'kubectl apply -f mysql.yaml'
                    sh 'kubectl apply -f bank-cluster.yaml'
                    sh 'kubectl apply -f domain.yaml'
                    sh 'kubectl apply -f pod-monitor.yaml'
                    sh 'kubectl apply -f ingress.yaml'
                }
            }
        }
    }
}

