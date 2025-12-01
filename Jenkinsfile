pipeline {

    agent any

    environment {
        SERVER_USER = "ubuntu"
        SERVER_IP   = "13.203.46.112"
        REMOTE_PATH = "/var/www/html"
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "📥 Fetching Code from GitHub..."
                git branch: 'master', url: 'https://github.com/AishwaryaPawar149/Terraform-Jenkins-Static-Website.git'
            }
        }

        stage('Deploy to Server') {
            steps {
                sshagent(['ubuntu']) {
                    sh '''
                    echo "🧹 Cleaning previous deployment..."
                    ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP "sudo rm -rf $REMOTE_PATH/*"

                    echo "📦 Uploading files..."
                    scp -o StrictHostKeyChecking=no -r * $SERVER_USER@$SERVER_IP:/tmp/

                    echo "🚀 Moving files to Apache folder..."
                    ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP "sudo mv /tmp/* $REMOTE_PATH/"
                    '''
                }
            }
        }

        stage('Done') {
            steps {
                echo "🎉 Deployment Successful!"
                echo "🌍 Visit: http://$SERVER_IP"
            }
        }
    }
}
