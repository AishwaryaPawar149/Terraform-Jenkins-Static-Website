pipeline {
    agent any

    environment {
        SSH_CRED = 'node-app-key'
        SERVER_IP = '13.233.250.148'
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
                    sh """
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${SERVER_IP} 'sudo rm -rf ${WEB_DIR}/*'
                        scp -o StrictHostKeyChecking=no -r index.html css js images fonts ${REMOTE_USER}@${SERVER_IP}:/tmp/
                        ssh ${REMOTE_USER}@${SERVER_IP} 'sudo cp -r /tmp/* ${WEB_DIR}/ && sudo systemctl restart apache2'
                    """
                }
            }
        }

        stage('Done') {
            steps {
                echo "🎉 Deployment Successful!"
                echo "🌍 Visit: http://${SERVER_IP}"
            }
        }
    }
}
