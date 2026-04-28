
pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  environment {
    AWS_ACCESS_KEY_ID = 'test'
    AWS_SECRET_ACCESS_KEY = 'test'
    AWS_DEFAULT_REGION = 'us-east-1'
    AWS_ENDPOINT_URL = 'http://localhost:4566'
    S3_BUCKET = 'etl-output-bucket'
    DYNAMODB_TABLE = 'etl-job-metadata'
    ETL_ROLE_ARN = 'arn:aws:iam::000000000000:role/etl-lambda-role'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Install') {
      steps {
        dir('etl-python-project') {
          sh 'python -m pip install poetry --break-system-packages'
          sh 'poetry install --no-interaction'
        }
      }
    }

    stage('Test') {
      steps {
        dir('etl-python-project') {
          sh 'poetry run pytest -q'
        }
      }
    }

    stage('Build') {
      steps {
        dir('etl-python-project') {
          sh 'poetry build'
          sh 'poetry run python etl_job.py'
        }
      }
    }

    stage('Deploy') {
      steps {
        input 'Approve Deployment to LocalStack-backed sandbox?'
        sh 'echo "Deployment approved - ETL artifact executed against sandbox infra."'
      }
    }
  }

  post {
    success {
      echo 'Pipeline completed successfully.'
    }
    failure {
      echo 'Pipeline failed. Review logs and fix failing stage.'
    }
  }
}
