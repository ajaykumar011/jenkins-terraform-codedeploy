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
 parameters {
        
        //string(name: 'TF_WORKSPACE', defaultValue: 'dev', description: 'Workspace (dev/prod) file to use for deployment')
        choice(name: 'TF_WORKSPACE', choices: ['dev', 'prod'], description: 'Pick the environment to use')
        string(name: 'TF_REGION', defaultValue: 'us-east-1', description: 'Select your region--not yet implemented')
        string(name: 'TF_AMI', defaultValue: 'ami-0817d428a6fb68645', description: 'Select your custom AMI-- not yet implemented')
        choice(name: 'AWS_PROFILE', choices: ['default', 'ec2-developer', 'ec2-developer'], description: 'Pick AWS profile')
        //string(name: 'version', defaultValue: '0.13.3', description: 'Version variable to pass to Terraform')
        booleanParam(name: 'autoApprove1', defaultValue: false, description: 'Automatically provision?')
        booleanParam(name: 'autoApprove2', defaultValue: false, description: 'Automatically deploy application?')
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
                   //sh "ls -la ${pwd()}"   # this is working but not needed
                   sh "tree ${env.WORKSPACE}" 
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
 
    stage('BuildInfo') {
            steps {
                    echo "Running Buid num: ${env.BUILD_ID} on Jenkins ${env.JENKINS_URL}"
                    echo "BUILD_NUMBER :: ${env.BUILD_NUMBER}"
                    echo "BUILD_ID :: ${env.BUILD_ID}"
                    echo "BUILD_DISPLAY_NAME :: ${env.BUILD_DISPLAY_NAME}"
                    echo "JOB_NAME :: ${env.JOB_NAME}"
                    echo "JOB_BASE_NAME :: ${env.JOB_BASE_NAME}"
                    echo "BUILD_TAG :: ${env.BUILD_TAG}"
                    echo "EXECUTOR_NUMBER :: ${env.EXECUTOR_NUMBER}"
                    echo "NODE_NAME :: ${env.NODE_NAME}"
                    echo "NODE_LABELS :: ${env.NODE_LABELS}"
                    echo "WORKSPACE :: ${env.WORKSPACE}"
                    echo "JENKINS_HOME :: ${env.JENKINS_HOME}"
                    echo "JENKINS_URL :: ${env.JENKINS_URL}"
                    echo "BUILD_URL ::${env.BUILD_URL}"
                    echo "JOB_URL :: ${env.JOB_URL}"
    
                }
            }
        stage('Plan') {
            steps {
                script {
                    currentBuild.displayName = params.version //not required
                }
                  dir("${params.TF_WORKSPACE}"){  //directory steps paramters to change the directory(if you have terraform in a dir in git)
                  //https://www.jenkins.io/doc/pipeline/steps/workflow-basic-steps/#dir-change-current-directory
                  //In normal git configuration we do not require to change the directory
                  sh 'pwd'
                  sh 'terraform --version'
                  sh 'terraform init -input=false'
                  //terraform init -input=false -force-copy -lock=true -upgrade -verify-plugins=true -backend=true -backend-config="profile=$AWS_PROFILE" -backend-config="region=$REGION" -backend-config="bucket=$S3_BUCKET" -backend-config="key=terraform-state/$ENV/terraform.tfstate" -backend-config="acl=private" 
                  //sh "terraform workspace select ${TF_WORKSPACE}"  # not required
                  sh "terraform workspace new ${params.TF_WORKSPACE} || true"
                  sh "terraform plan -input=false -out tfplan --var-file=./env_vars/${params.TF_WORKSPACE}.tfvars"
                  sh 'terraform show -no-color tfplan > tfplan.txt'
                }
            }
        }

        stage('Approval') {
            when {
                not {
                    equals expected: true, actual: params.autoApprove1
                }
            }

            steps {
                script {
                    dir("${params.TF_WORKSPACE}"){
                    def plan = readFile 'tfplan.txt'
                        input message: "Do you want to apply the plan?",
                        parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                    }
                }
            }
        }

        stage('Apply') {
            steps {
                dir("${params.TF_WORKSPACE}"){
                  echo "Terraform is now provisioning the infrastructure.."
                  sh "terraform apply -input=false tfplan"
                }    
            }
        }

  
        stage('App Deployment') {
            when {
                equals expected: true, actual: params.autoApprove2
                }
            steps {
                script {
                    dir("${params.TF_WORKSPACE}"){
                        echo "HEY: We are going to deploy your app."
                        sh 'chmod +x app-deploy.sh'
                        sh './app-deploy.sh'
                        }
              }
            }
        }
        stage('Infra-Destroy') {
            input {
                message "Should we destroy the infrastructre ?"
                ok "Proceed."
                submitter "alice,bob"
                parameters {
                    string(name: 'PERSON', defaultValue: 'Ajay Kumar', description: 'Who should I say hello to?')
                    choice(name: 'INFRA-DEL', choices: ['Yes', 'No', 'nochange'], description: 'Pick yes to display all')
                }
             }
            steps {
                
                echo "Hello, ${PERSON}, We are destroying everything."
                dir("${params.TF_WORKSPACE}"){
                sh 'terraform destroy -auto-approve'
                }
            }
            when { 
                environment name: 'INFRA-DEL', value: 'Yes'
            }
        }
    }  //stage closed

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
        } //post closed
} //pipeline closed