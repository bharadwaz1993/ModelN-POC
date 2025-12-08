pipeline {
  agent any

  environment {
    AWS_REGION = 'ap-south-1'
    ECR_REPO   = '012419504185.dkr.ecr.ap-south-1.amazonaws.com/hello-world-app'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build & Test') {
      steps {
        // Adjust for your stack: mvn, gradle, npm, etc.
        sh 'mvn -q -e clean test'
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          env.IMAGE_TAG = env.BUILD_NUMBER

          sh """
            aws ecr get-login-password --region ${AWS_REGION} \
              | docker login --username AWS --password-stdin ${ECR_REPO}

            docker build -t ${ECR_REPO}:${IMAGE_TAG} .
          """
        }
      }
    }

    stage('Push Docker Image') {
      steps {
        sh 'docker push ${ECR_REPO}:${IMAGE_TAG}'
      }
    }

    stage('Update Helm values.yaml') {
      steps {
        // Replace the tag line under 'image:' in helm/values.yaml
        sh """
          sed -i 's/^  tag: .*/  tag: "${IMAGE_TAG}"/' helm/values.yaml
        """
      }
    }

    stage('Commit & Push changes to Git') {
      steps {
        sshagent(credentials: ['github-ssh-key']) {
          sh """
            git config user.email "jenkins@modeln-poc.local"
            git config user.name "Jenkins"

            git add helm/values.yaml

            git commit -m "Deploy image tag ${IMAGE_TAG}" || echo "No changes to commit"

            git push origin HEAD:main
          """
        }
      }
    }
  }
}
