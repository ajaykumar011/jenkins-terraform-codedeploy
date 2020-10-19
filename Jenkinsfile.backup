pipeline {
 agent any
 options {
        timeout(time: 1, unit: 'HOURS') 
        timestamps() 
        buildDiscarder(logRotator(numToKeepStr: '5'))
        //skipDefaultCheckout() //skips the default checkout.
        //checkoutToSubdirectory('subdirectory') //checkout to a subdirectory
        // preserveStashes()   Preserve stashes from completed builds, for use with stage restarting
        }

 environment {
        FULL_PATH_BRANCH = "${sh(script:'git name-rev --name-only HEAD', returnStdout: true)}"
        GIT_BRANCH = FULL_PATH_BRANCH.substring(FULL_PATH_BRANCH.lastIndexOf('/') + 1, FULL_PATH_BRANCH.length())
        }
     
  stages {
        stage('Checkout') {
            steps {
                script{
                    //git branch: 'Your Branch name', credentialsId: 'Your crendiatails', url: ' Your BitBucket Repo URL '
                    // Branch name is master in this repo
                    //git branch: 'main', credentialsId: 'github-cred', url: 'https://github.com/ajaykumar011/jenkins-packer-with-ansible2/'
                    echo 'Pulling... ' + env.GIT_BRANCH
                    sh 'printenv'
                   //sh "ls -la ${pwd()}"  
                    sh "tree ${env.WORKSPACE}"
                }
            }
        }

        stage('Packer-AMI-Builder') {
            steps {
                script {
                    dir('packer')
                        {
                        sh 'chmod +x packer-build-ami.sh'
                        echo 'I am inside packer'
                        def result = sh returnStatus: true, script: 'sudo ./packer-build-ami.sh'
                        if (result != 0) {
                            echo '[PACKER: FAILURE] Failed to build AMI'
                            currentBuild.result = 'FAILURE'
                            sh "exit ${result}"  
                            }
                        }
                }
            }
        }

        stage('Set Terraform path') {
            steps {
                script {  // script is used for complex scripts, loops, conditions elese use steps
                    // Get the Terraform tool.
                    //def tfHome = tool name: 'Terraform', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
                    def tfHome = tool name: 'Terraform'
                    env.PATH = "${tfHome}:${env.PATH}"
                    sh 'terraform --version'
                }
             }
        }
 
    stage('Provision infrastructure') {
         steps {
            //dir('dev')
            //    {
                sh 'sudo chmod +x jenkins-run-terraform.sh'
                sh 'sudo ./jenkins-run-terraform.sh'
              //  }
            }
        }
    
        stage('Infra-Destroy') {
            input {
                message "Should we destroy the infrastructre ?"
                ok "Yes, we should."
                submitter "alice,bob"
                parameters {
                    string(name: 'PERSON', defaultValue: 'Ajay Kumar', description: 'Who should I say hello to?')
                    choice(name: 'INFRA-DEL', choices: ['Yes', 'No', 'nochange'], description: 'Pick yes to display all')
                }
             }
            steps {
                echo "Hello, ${PERSON}, nice to meet you."
                sh 'terraform destroy -auto-approve'
                dir('packer')
                {
                sh 'chmod +x packer-destroy.sh'
                sh 'sudo ./packer-destroy.sh'
                }
            }
            when { 
                environment name: 'INFRA-DEL', value: 'Yes'
            }

        }

    }

    post {
            always {
                echo 'One way or another, I have finished'
                // deleteDir() /* delete the working dir normally workspace */
                //cleanWs() /* clean up workspace */
                //archiveArtifacts artifacts: 'targetbuild-*.zip', followSymlinks: false, onlyIfSuccessful: true
                }
        
            success {
                 echo 'Success'
                // slackSend channel: '#jenkins-builds',
                // color: 'good',
                // message: "The pipeline ${currentBuild.fullDisplayName} completed successfully."
                }
                  
            unstable {
                echo 'I am unstable :/'
                }
        
            failure {
                echo 'delete me I am of no use'
                //cleanWs()
                //  mail to: 'ajay011.sharma@hotmail.com',
                //  cc: 'macme.tang@gmail.com',
                //  subject: "Failed Pipeline: ${currentBuild.fullDisplayName}",
                //  body: "Something is wrong with ${env.BUILD_URL}"
                }
            changed {
                echo 'Things were different before...'
                }   
        }
}


                // withCredentials([
                //     string(credentialsId: 'websearch_mysql_pwd', variable: 'MYSQL_PWD'),
                //     string(credentialsId: 'websearch_mysql_root_pwd', variable: 'MYSQL_ROOT_PWD'),
                //     file(credentialsId: 'AWS_PEM', variable: 'AWS_KEY')
                //     ]) { 
                //     echo "My password is '${MYSQL_PWD}'!"
                //     echo "My key is '${AWS_Key}'"
