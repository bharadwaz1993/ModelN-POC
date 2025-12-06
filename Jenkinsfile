pipeline {
  agent any

  environment {
    AWS_REGION    = 'ap-south-1'
    ECR_REPO      = '<your-account-id>.dkr.ecr.ap-south-1.amazonaws.com/hello-world-app'
    IMAGE_TAG     = "${env.BUILD_NUMBER}"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build & Test') {
      steps {
        sh 'mvn -q -e clean package'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh """
          aws ecr get-login-password --region ${AWS_REGION} \
            | docker login --username AWS --password-stdin ${ECR_REPO}
          docker build -t ${ECR_REPO}:${IMAGE_TAG} .
        """
      }
    }

    stage('Push Image') {
      steps {
        sh "docker push ${ECR_REPO}:${IMAGE_TAG}"
      }
    }

    stage('Update Helm values (for GitOps)') {
      steps {
        sh """
          sed -i 's/tag: .*/tag: "${IMAGE_TAG}"/' helm/values.yaml
        """
      }
    }

    stage('Push to Git (GitOps repo)') {
      steps {
        // Option 1: same repo; commit Jenkins-changed values.yaml
        sh """
          git config user.email "jenkins@local"
          git config user.name "Jenkins"
          git add helm/values.yaml
          git commit -m "Update image tag to ${IMAGE_TAG}" || echo "No changes"
          git push origin HEAD:main
        """
      }
    }
  }
}
