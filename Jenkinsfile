pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        AWS_ACCESS_KEY_ID = credentials('Access-key-ID')
        AWS_SECRET_ACCESS_KEY = credentials('Secret-access-key')
    }

    parameters {
        booleanParam(name: 'AUTO_APPROVE_APPLY', defaultValue: false, description: 'Auto-approve the Terraform apply')
        booleanParam(name: 'AUTO_APPROVE_DESTROY', defaultValue: false, description: 'Auto-approve the Terraform destroy')
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
            // Plan only when AUTO_APPROVE_DESTROY is not selected
            when {
                expression { return !params.AUTO_APPROVE_DESTROY }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    dir('terraform-eks') {
                        if (params.AUTO_APPROVE_APPLY) {
                            sh 'terraform apply tfplan'
                        } else {
                            input message: 'Approve Terraform Apply?', ok: 'Apply'
                            sh 'terraform apply tfplan'
                        }
                    }
                }
            }
            // Apply only when AUTO_APPROVE_DESTROY is not selected
            when {
                expression { return !params.AUTO_APPROVE_DESTROY }
            }
        }

        stage('Terraform Destroy') {
            steps {
                script {
                    dir('terraform-eks') {
                        if (params.AUTO_APPROVE_DESTROY) {
                            sh 'terraform destroy -auto-approve'
                        } else {
                            input message: 'Approve Terraform Destroy?', ok: 'Destroy'
                            sh 'terraform destroy -auto-approve'
                        }
                    }
                }
            }
            // Destroy only when AUTO_APPROVE_DESTROY is selected
            when {
                expression { return params.AUTO_APPROVE_DESTROY }
            }
        }
    }

    post {
        success {
            echo 'Terraform operation completed successfully!'
        }
        failure {
            echo 'There was an error during the process.'
        }
    }
}
