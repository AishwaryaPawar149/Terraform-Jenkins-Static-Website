pipeline {
    agent any

    environment {
        PROJECT_NAME    = "autoscaling-project"
        GITHUB_REPO_URL = "https://github.com/sruthi234/static-website-project.git"
        GIT_BRANCH      = "master"
        SSH_CRED_ID     = "terraform"          // Jenkins SSH credential ID
        AWS_REGION      = "ap-south-1"

        // Standalone EC2 server details
        REMOTE_USER     = "ubuntu"
        REMOTE_IP       = "13.233.165.122"     // EC2 public IP
        REMOTE_PATH     = "/var/www/html"      // Deploy path on EC2
        TEMP_PATH       = "/tmp/deploy_temp"   // Temporary folder for SCP
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "Cloning GitHub repo..."
                git branch: "${GIT_BRANCH}", url: "${GITHUB_REPO_URL}"
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                echo "Initializing Terraform..."
                sh 'terraform init'
                echo "Running Terraform Plan..."
                sh 'terraform plan -var-file=terraform.tfvars'
                echo "Applying Terraform changes..."
                sh 'terraform apply -auto-approve -var-file=terraform.tfvars'
            }
        }

        stage('Verify Website via ALB') {
            steps {
                script {
                    def alb_dns = sh(script: "terraform output -raw load_balancer_dns", returnStdout: true).trim()
                    echo "Checking website at ALB: http://${alb_dns}"
                    sh "curl -I http://${alb_dns}"
                }
            }
        }

        stage('Deploy to Standalone EC2') {
            steps {
                echo "Copying website files to EC2..."
                sshagent(credentials: ["${SSH_CRED_ID}"]) {
                    sh """
                    # Create temp folder on EC2
                    ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_IP} 'mkdir -p ${TEMP_PATH}'

                    # SCP files to temp folder
                    scp -o StrictHostKeyChecking=no -r * ${REMOTE_USER}@${REMOTE_IP}:${TEMP_PATH}

                    # Move files to /var/www/html with sudo and restart Nginx
                    ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_IP} '
                        sudo rm -rf ${REMOTE_PATH}/* &&
                        sudo mv ${TEMP_PATH}/* ${REMOTE_PATH}/ &&
                        sudo systemctl restart nginx
                    '
                    """
                }
            }
        }

        stage('Verify Standalone EC2') {
            steps {
                echo "Verifying website on standalone EC2..."
                sh "curl -I http://${REMOTE_IP}"
            }
        }
    }

    post {
        success {
            echo "Deployment successful on both ALB and standalone EC2!"
        }
        failure {
            echo "Deployment failed! Check logs."
        }
    }
}
