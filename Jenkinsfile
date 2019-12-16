#!groovy

import groovy.json.JsonSlurper
import java.text.SimpleDateFormat
import java.util.Calendar

pipeline {  
	agent none

	stages{		

		stage('Init') {
			steps{
				script{
					initialize()
				}
			}
			
		}

		stage('Build Application') {
			agent { label 'master' }

			steps {
				buildApp()
			}
		}

	}
}

// ================================================================================================
// Build steps
// ================================================================================================

def initialize() {
	env.SERVER_IP = '192.168.172.7'

	env.REGISTRY_URL 	= 'rohitshukla/demo'

	env.IMAGE_NAME = "1.0." + env.BUILD_ID
}


def buildApp() {
	sh "docker build -t ${env.IMAGE_NAME} ."
	
}


def buildApplication(branch) {
	
	docker.withRegistry(env.REGISTRY_URL) {
		dockerLogin(env.REGISTRY_ID)

		
		def buildResult = docker.build(env.IMAGE_NAME)
		buildResult.push()

		echo "Disconnect from registry at ${env.REGISTRY_URL}"
        sh "docker logout ${env.REGISTRY_URL}"
	 }	 
}
	
def dockerLogin(String regid) {
	echo "Connect to registry at ${regid}"
	def login_command = sh(returnStdout: true, script: "aws ecr get-login --registry-ids ${regid} --region ap-south-1 | sed -e 's|-e none||g'")	
	sh "${login_command}"
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
