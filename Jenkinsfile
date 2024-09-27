pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1' // Your specified region
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
        }

        stage('Terraform Apply') {
            steps {
                script {
                    dir('terraform-eks') {
                        if (params.AUTO_APPROVE_APPLY) {
                            // Auto-approve if the parameter is set
                            sh 'terraform apply tfplan'
                        } else {
                            // Manual approval step if auto-approve is not enabled
                            input message: 'Approve Terraform Apply?', ok: 'Apply'
                            sh 'terraform apply tfplan'
                        }
                    }
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                script {
                    dir('terraform-eks') {
                        if (params.AUTO_APPROVE_DESTROY) {
                            // Auto-approve destroy step
                            sh 'terraform destroy -auto-approve'
                        } else {
                            // Manual approval step if auto-approve is not enabled
                            input message: 'Approve Terraform Destroy?', ok: 'Destroy'
                            sh 'terraform destroy -auto-approve'
                        }
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
