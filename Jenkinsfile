pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1' // Your specified region
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
                    withCredentials([ 
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id'] // Use the correct credentials ID for AWS
                    ]) {
                        dir('terraform-eks') { // Navigate to the Terraform directory
                            sh 'terraform init'
                        }
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    withCredentials([ 
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id'] // Use the correct credentials ID for AWS
                    ]) {
                        dir('terraform-eks') {
                            sh 'terraform plan -out=tfplan'
                        }
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: 'Approve Terraform Apply?', ok: 'Apply'
                script {
                    withCredentials([ 
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id'] // Use the correct credentials ID for AWS
                    ]) {
                        dir('terraform-eks') {
                            sh 'terraform apply tfplan'
                        }
                    }
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                input message: 'Approve Terraform Destroy?', ok: 'Destroy'
                script {
                    withCredentials([ 
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id'] // Use the correct credentials ID for AWS
                    ]) {
                        dir('terraform-eks') {
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
