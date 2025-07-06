pipeline {
  agent any

  environment {
    // Docker Hub Credentials
    DOCKERHUB_USERNAME = credentials('dockerhub-username') 
    DOCKERHUB_PASSWORD = credentials('dockerhub-password')

    // EC2 SSH Deployment Credentials
    EC2_HOST = credentials('ec2-host')            
    EC2_USER = credentials('ec2-user')
    EC2_KEY  = credentials('ec2-private-key')     // SSH private key (stored as secret text)
  }

  triggers {
    pollSCM('* * * * *') // For frequent checks; consider GitHub webhook for better performance
  }

  stages {

    stage('📥 Checkout Source') {
      steps {
        checkout scm
      }
    }

    stage('🐳 Build Docker Image') {
      steps {
        script {
          sh """
            echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
            docker build -t $DOCKERHUB_USERNAME/infra-app:latest -f ./app/Dockerfile.prod ./app
          """
        }
      }
    }

    stage('📤 Push Image to Docker Hub') {
      steps {
        script {
          sh "docker push $DOCKERHUB_USERNAME/infra-app:latest"
        }
      }
    }

    stage('🚀 Deploy to EC2') {
      steps {
        script {
          writeFile file: 'ec2_key.pem', text: EC2_KEY
          sh 'chmod 400 ec2_key.pem'

          sh """
            ssh -o StrictHostKeyChecking=no -i ec2_key.pem ${EC2_USER}@${EC2_HOST} << 'EOF'
              docker stop app || true
              docker rm app || true
              docker pull ${DOCKERHUB_USERNAME}/infra-app:latest
              docker run -d --name app -p 80:3000 ${DOCKERHUB_USERNAME}/infra-app:latest
            EOF
          """
        }
      }
    }
  }

  post {
    success {
      emailext(
        to: 'sudarshangawande98@gmail.com',
        subject: "✅ Jenkins Job '${env.JOB_NAME} [#${env.BUILD_NUMBER}]' Succeeded",
        body: "🎉 Great news! Your build completed successfully.\n\n👉 Build Logs: ${env.BUILD_URL}"
      )
    }

    failure {
      emailext(
        to: 'sudarshangawande98@gmail.com',
        subject: "❌ Jenkins Job '${env.JOB_NAME} [#${env.BUILD_NUMBER}]' Failed",
        body: "⚠️ Oops! The build failed.\n\n📄 Check logs: ${env.BUILD_URL}"
      )
    }

    always {
      cleanWs() // Clean workspace after each build
    }
  }
}
