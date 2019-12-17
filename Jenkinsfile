#!groovy

import groovy.json.JsonSlurper
import java.text.SimpleDateFormat
import java.util.Calendar

pipeline {  
	environment {
		registry = "rohitshukla/demo"
		registryCredential = 'DockerCredentialId'
	}
	
	agent none
	
	stages{

		stage('Build & Push Application Image') {
			agent { label 'master' }
			steps {
				script{
					dockerImage = docker.build registry + ":$BUILD_NUMBER"
					
					docker.withRegistry( '', registryCredential ) {
						dockerImage.push()
					}
				}
			}
		}
		
		stage('Deploy Application') {
			agent { label 'master' }
			steps {
				script{
					sh 'docker kill demoapp'
					sh 'docker rm demoapp'
					sh 'docker run -p 80:8080 --name demoapp -d rohitshukla/demo:$BUILD_NUMBER' 
				}
			}
		}

	}
}

// ================================================================================================
// Tests steps
// ================================================================================================

def runBrowserTestCases() {	
	
	sh """cat > json_data.txt << EOF
	{\"action\":\"execute\",\"is_group\":\"-g\",\"exe_env\":\"test\",\"exe_type\":\"Smoke\",\"suite_or_group_name\":[\"Xento_Website\"]}
	"""

	def test_case_response = sh(script:'curl -X POST "https://rge9xxkyva.execute-api.ap-south-1.amazonaws.com/prod" -H "Content-Type: application/json" -H "x-api-key: ${TEST_CASE_API_KEY}" --data @json_data.txt', returnStdout: true)
	
	def test_case_parser = new JsonSlurper()
	def response_data = test_case_parser.parseText(test_case_response)

	env.TEST_CASE_EXECUTION_ID = response_data.executionId

}

def statusBrowserTestCases() {
	sh """cat > json_status_data.txt << EOF
	{\"action\":\"status\",\"execution_id\":\"${TEST_CASE_EXECUTION_ID}\"}
	"""
	def test_case_status_response = sh(script:'curl -X POST "https://rge9xxkyva.execute-api.ap-south-1.amazonaws.com/prod" -H "Content-Type: application/json" -H "x-api-key: ${TEST_CASE_API_KEY}" --data @json_status_data.txt', returnStdout: true)

	def test_case_parser = new JsonSlurper()
	def response_data = test_case_parser.parseText(test_case_status_response)

}


// ================================================================================================
// Deploy steps
// ================================================================================================

def deployOnTestServer() {
	
	sh """ssh -o StrictHostKeyChecking=no -tt jenkins@${env.TEST_SERVER_IP} << EOF 
	 sudo aws ecr get-login --registry-ids ${env.REGISTRY_ID} --region ap-south-1 | sed -e 's|-e none||g' > login.sh	 
	 sudo chmod +x login.sh
	 sudo ./login.sh

     sudo docker pull ${env.TEST_IMAGE_URL}     
     sudo docker stop ${TEST_CONTAINER_NAME} && sudo docker rm -f ${TEST_CONTAINER_NAME}
     sudo docker run --name ${env.TEST_CONTAINER_NAME} --expose 8080 -e VIRTUAL_HOST=test.xento.lcl -d ${env.TEST_IMAGE_PATH}
     exit
    EOF"""
}

def deployToServer() {
	if(env.BRANCH == 'trunk') {
		sh """ssh -o StrictHostKeyChecking=no -tt jenkins@${env.TEST_SERVER_IP} << EOF 
		 sudo aws ecr get-login --registry-ids ${env.REGISTRY_ID} --region ap-south-1 | sed -e 's|-e none||g' > login.sh	 
		 sudo chmod +x login.sh
		 sudo ./login.sh

	     sudo docker pull ${env.TEST_IMAGE_URL}     
	     sudo docker stop ${DEV_CONTAINER_NAME} && sudo docker rm -f ${DEV_CONTAINER_NAME}	     
	     sudo docker run --name ${env.DEV_CONTAINER_NAME} --expose 8081 -e VIRTUAL_HOST=dev.xento.lcl -d ${env.TEST_IMAGE_PATH}
	     exit
	    EOF"""
    }
}
