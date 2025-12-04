pipeline {
    agent any

    environment {
        PROJECT_NAME    = "autoscaling-project"
        GITHUB_REPO_URL = "https://github.com/sruthi234/static-website-project.git"
        GIT_BRANCH      = "master"
        SSH_CRED_ID     = "terraform"          // Jenkins credential ID for SSH key
        REMOTE_USER     = "ubuntu"             // EC2 username
        REMOTE_IP       = "13.233.165.122"         // Replace with your EC2 public IP
        REMOTE_PATH     = "/var/www/html"      // Deploy path on EC2
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "Cloning GitHub repo..."
                git branch: "${GIT_BRANCH}", url: "${GITHUB_REPO_URL}"
            }
        }

        stage('Copy Files to EC2') {
            steps {
                echo "Copying website files to EC2..."
                sshagent(credentials: ["${SSH_CRED_ID}"]) {
                    sh "scp -r * ${REMOTE_USER}@${REMOTE_IP}:${REMOTE_PATH}"
                }
            }
        }

        stage('Restart Web Server') {
            steps {
                echo "Restarting Nginx on EC2..."
                sshagent(credentials: ["${SSH_CRED_ID}"]) {
                    sh "ssh ${REMOTE_USER}@${REMOTE_IP} 'sudo systemctl restart nginx'"
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo "Verifying website on EC2..."
                sh "curl -I http://${REMOTE_IP}"
            }
        }
    }

    post {
        success {
            echo "Deployment to EC2 successful!"
        }
        failure {
            echo "Deployment failed! Check logs."
        }
    }
}
