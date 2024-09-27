pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1' // Your specified region
        AWS_ACCESS_KEY_ID = credentials('Access-key-ID')
        AWS_SECRET_ACCESS_KEY = credentials('Secret-access-key')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    dir('terraform-eks') {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    dir('terraform-eks') {
                        sh 'terraform plan -out=tfplan'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: 'Approve Terraform Apply?', ok: 'Apply'
                script {
                    dir('terraform-eks') {
                        sh 'terraform apply tfplan'
                    }
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                input message: 'Approve Terraform Destroy?', ok: 'Destroy'
                script {
                    dir('terraform-eks') {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'EKS Cluster created and destroyed successfully!'
        }
        failure {
            echo 'There was an error during the process.'
        }
    }
}
