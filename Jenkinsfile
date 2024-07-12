pipeline {
    agent any
    
    tools {
        jdk 'jdk17'
        nodejs 'node16'
    }
    
    
    environment  {
        SCANNER_HOME=tool 'sonar-scanner'
        AWS_ACCOUNT_ID = '637423342947'
        AWS_ECR_REPO_NAME = 'three-tier-frontend'
        AWS_DEFAULT_REGION = 'us-east-1'
        REPOSITORY_URI = 'public.ecr.aws/h1p7m8a0/three-tier-frontend'
        
    }

    stages {
        stage('Cleaning Workspace') {
            steps {
                cleanWs()
            }
        }
        
        
        stage('git checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/kokareamol/TWSThreeTierAppChallenge.git'
            }
        }
        
        
        
        
        stage('Sonarqube Analysis') {
            steps {
                dir('Application-Code/frontend') {
                    withSonarQubeEnv('sonar-server') {
                        sh ''' $SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectName=three-tier-app \
                        -Dsonar.projectKey=three-tier-app '''
                    }
                }
            }
        }
        
        
        stage('Quality Check') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-cred' 
                }
            }
        }
        
        
        stage('Trivy File Scan') {
            steps {
                dir('Application-Code/frontend') {
                    sh 'trivy fs . > trivyfs.txt'
                }
            }
        }
        
        
        stage("Docker Image Build") {
            steps {
                script {
                    dir('Application-Code/frontend') {
                            sh 'docker system prune -f'
                            sh 'docker container prune -f'
                            sh 'docker build -t ${AWS_ECR_REPO_NAME} .'
                    }
                }
            }
        }
        


        stage('Push to ECR') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    script {
                        // Configure AWS CLI with provided credentials
                        sh """
                        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                        aws configure set default.region $AWS_DEFAULT_REGION
                        """
                        
                        // Get the login command from ECR and execute it directly
                        sh 'aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/h1p7m8a0'
                        
                        // Tag the image with the full ECR repository URI
                        sh "docker tag three-tier-frontend:latest public.ecr.aws/h1p7m8a0/three-tier-frontend:latest"
                        
                        // Push the image to ECR
                        sh "docker push public.ecr.aws/h1p7m8a0/three-tier-frontend:latest"
                    }
                }
            }
        }
    

        
        
        
    }
}
