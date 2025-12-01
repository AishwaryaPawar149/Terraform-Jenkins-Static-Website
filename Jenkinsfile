pipeline {

    agent any

    environment {
        SERVER_USER = "ubuntu"
        SERVER_IP   = "13.201.37.19"
        REMOTE_PATH = "/var/www/html"
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "📥 Fetching Code from GitHub..."
                git branch: 'master', url: 'https://github.com/AishwaryaPawar149/Terraform-Jenkins-Static-Website.git'
            }
        }

        stage('Test SSH Connection') {
            steps {
                script {
                    echo "🔍 Testing SSH connection to server..."
                    sshagent(['terraform']) {
                        sh '''
                            ssh -o StrictHostKeyChecking=no \
                                -o ConnectTimeout=10 \
                                ${SERVER_USER}@${SERVER_IP} \
                                "echo '✅ SSH Connection Successful!' && uptime"
                        '''
                    }
                }
            }
        }

        stage('Clean Previous Deployment') {
            steps {
                script {
                    echo "🧹 Cleaning previous deployment..."
                    sshagent(['terraform']) {
                        sh '''
                            ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} \
                            "sudo rm -rf ${REMOTE_PATH}/* && echo '✅ Cleanup Complete'"
                        '''
                    }
                }
            }
        }

        stage('Upload Files') {
            steps {
                script {
                    echo "📦 Uploading website files to server..."
                    sshagent(['terraform']) {
                        sh '''
                            # Create temporary directory if it doesn't exist
                            ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} \
                            "mkdir -p /tmp/website-deploy && rm -rf /tmp/website-deploy/*"
                            
                            # Upload files (excluding Jenkins and git files)
                            scp -o StrictHostKeyChecking=no -r ./* ${SERVER_USER}@${SERVER_IP}:/tmp/website-deploy/
                            
                            echo "✅ Files uploaded successfully"
                        '''
                    }
                }
            }
        }

        stage('Deploy to Apache') {
            steps {
                script {
                    echo "🚀 Moving files to Apache web directory..."
                    sshagent(['terraform']) {
                        sh '''
                            ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} \
                            "sudo cp -r /tmp/website-deploy/* ${REMOTE_PATH}/ && \
                             sudo chown -R www-data:www-data ${REMOTE_PATH}/* && \
                             sudo chmod -R 755 ${REMOTE_PATH} && \
                             echo '✅ Deployment Complete'"
                        '''
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    echo "🔍 Verifying deployment..."
                    sshagent(['terraform']) {
                        sh '''
                            ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} \
                            "ls -lh ${REMOTE_PATH}/ && \
                             sudo systemctl status apache2 --no-pager | head -10"
                        '''
                    }
                }
            }
        }

        stage('Done') {
            steps {
                echo "🎉 Deployment Successful!"
                echo "🌍 Visit: http://${SERVER_IP}"
                echo "📊 Check your website now!"
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully!"
            echo "🌐 Your website is live at: http://${SERVER_IP}"
        }
        failure {
            echo "❌ Pipeline failed. Check the logs above for details."
            echo "💡 Common issues:"
            echo "   - SSH key 'terraform' not configured correctly in Jenkins credentials"
            echo "   - Server not accessible (check security groups)"
            echo "   - Apache not installed or running on server"
            echo "   - Sudo permissions not configured for ubuntu user"
        }
        always {
            echo "🧹 Cleaning up workspace..."
            cleanWs()
        }
    }
}
```

## Main Change:
- All `sshagent(['ubuntu'])` replaced with `sshagent(['terraform'])`

## Now Verify Your 'terraform' Credential in Jenkins:

1. Go to: **Jenkins Dashboard → Manage Jenkins → Credentials → System → Global credentials**

2. Find the credential with ID `terraform`

3. Make sure it has:
   - **Kind**: SSH Username with private key
   - **ID**: `terraform`
   - **Username**: `ubuntu`
   - **Private Key**: Your EC2 instance's private key (the entire `.pem` file content)

## If the 'terraform' credential doesn't exist or needs updating:

Click **Add Credentials** or **Update** and set:
```
Kind: SSH Username with private key
ID: terraform
Username: ubuntu
Private Key: [Enter directly] → Paste your entire EC2 private key
```

The private key should look like:
```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
(multiple lines)
...
-----END RSA PRIVATE KEY-----