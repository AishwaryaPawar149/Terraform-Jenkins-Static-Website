pipeline {
    agent any

    environment {
        SSH_CRED = 'node-app-key'            // Jenkins SSH key credential ID
        SERVER_IP = '13.203.46.112'     // EC2 Public IP
        REMOTE_USER = 'ubuntu'           // EC2 username (Ubuntu AMI)
        WEB_DIR = '/var/www/html'        // Apache folder
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
                        echo "🧹 Removing old files from EC2..."
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${SERVER_IP} "sudo rm -rf ${WEB_DIR}/*"

                        echo "📦 Uploading website files..."
                        scp -o StrictHostKeyChecking=no -r * ${REMOTE_USER}@${SERVER_IP}:/tmp/

                        echo "🚀 Deploying to Apache directory..."
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
