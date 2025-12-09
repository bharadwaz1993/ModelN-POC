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

    stage('Build (placeholder)') {
      steps {
        // Replace with your real build (mvn / npm / gradle) if needed
        sh 'echo "No app build step yet; using Dockerfile only"'
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          env.IMAGE_TAG = env.BUILD_NUMBER

          sh """
            aws ecr get-login-password --region ${AWS_REGION} \
              | docker login --username AWS --password-stdin 012419504185.dkr.ecr.ap-south-1.amazonaws.com

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
        // Update image.tag in helm/values.yaml to the new build number
        sh '''
          sed -i 's/^  tag: .*/  tag: "'${IMAGE_TAG}'"/' helm/values.yaml
        '''
      }
    }

    stage('Commit & Push changes to GitHub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'github-https-creds',
                                          usernameVariable: 'GIT_USER',
                                          passwordVariable: 'GIT_TOKEN')]) {
          sh '''
            git config user.email "jenkins@modeln-poc.local"
            git config user.name "Jenkins"

            git add helm/values.yaml
            git commit -m "Deploy image tag '${IMAGE_TAG}'" || echo "No changes to commit"

            git remote set-url origin https://$GIT_USER:$GIT_TOKEN@github.com/bharadwaz1993/ModelN-POC.git

            git push origin HEAD:main
          '''
        }
      }
    }
  }
}
