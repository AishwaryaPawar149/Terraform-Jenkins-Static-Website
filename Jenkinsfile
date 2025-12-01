pipeline {
    agent any

    environment {
        SSH_CRED = 'node-app-key'
        SERVER_IP = '13.203.46.112'
        REMOTE_USER = 'ubuntu'
        WEB_DIR = '/var/www/html'
    }

    stages {

        stage('Clone Code') {
            steps {
                git url: 'https://github.com/AishwaryaPawar149/Terraform-Jenkins-Static-Website.git', branch: 'master'
            }
        }

        stage('Deploy Website') {
            steps {
                sshagent(credentials: ["${SSH_CRED}"]) {
                    sh '''
                        echo "🧹 Cleaning old website..."
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${SERVER_IP} "sudo rm -rf ${WEB_DIR}/*"

                        echo "📦 Uploading files..."
                        scp -o StrictHostKeyChecking=no -r *.html *.css images ${REMOTE_USER}@${SERVER_IP}:/tmp/

                        echo "🚀 Deploying..."
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${SERVER_IP} "sudo cp -r /tmp/* ${WEB_DIR}/ && sudo systemctl restart apache2"
                    '''
                }
            }
        }

        stage('Done') {
            steps {
                echo "🎉 Deployment Successful!"
                echo "🌍 Website Live: http://${SERVER_IP}"
            }
        }
    }
}
