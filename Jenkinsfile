pipeline {
    agent any

    environment {
        PROJECT_NAME    = "autoscaling-project"
        GITHUB_REPO_URL = "https://github.com/AishwaryaPawar149/Terraform-Jenkins-Static-Website.git"
        GIT_BRANCH      = "master"
        SSH_CRED_ID     = "terraform"          // Jenkins SSH credential ID
        REMOTE_USER     = "ubuntu"             // EC2 username
        REMOTE_IP       = "13.233.165.122"     // EC2 public IP
        REMOTE_PATH     = "/var/www/html"      // Deploy path on EC2

        // Terraform variables
        environment {
    TF_VAR_region           = "ap-south-1"
    TF_VAR_ami_id           = "ami-0041facac80f93bbe"
    TF_VAR_instance_type    = "t4g.micro"
    TF_VAR_key_name         = "terraform"
    TF_VAR_vpc_id           = "vpc-0c6b61f2d046190b5"
    TF_VAR_subnet_ids       = '["subnet-09445e8b614b8e222","subnet-0b7ffdec16dd0024c"]'
    TF_VAR_security_group_id = "sg-0eccc0ca87735822f"
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
                sh "terraform init"

                echo "Running Terraform Apply..."
                sh "terraform apply -auto-approve"
            }
        }

        stage('Deploy to EC2') {
            steps {
                echo "Copying website files to EC2..."
                sshagent(credentials: ["${SSH_CRED_ID}"]) {
                    sh "scp -o StrictHostKeyChecking=no -r * ${REMOTE_USER}@${REMOTE_IP}:${REMOTE_PATH}"
                }

                echo "Restarting Nginx on EC2..."
                sshagent(credentials: ["${SSH_CRED_ID}"]) {
                    sh "ssh ${REMOTE_USER}@${REMOTE_IP} 'sudo systemctl restart nginx'"
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo "Verifying website via ALB..."
                sh "curl -I http://\$(terraform output -raw load_balancer_dns)"
            }
        }
    }

    post {
        success {
            echo "Deployment successful!"
        }
        failure {
            echo "Deployment failed! Check logs."
        }
    }
}
