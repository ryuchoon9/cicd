node {
  stage ('======== Clone repository ========') {
    checkout scm
  }
  stage('======== Build image ========') {
    sh "terraform init"
    sh "terraform plan"
  }
}
