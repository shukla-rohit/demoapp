#!groovy

import groovy.json.JsonSlurper

pipeline {  
	environment {
		registry = "devopsmeetup/meetuptest"
		registryCredential = 'DevOpsToolsMeetupId'
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
		
		stage('Deploy Application on Test Environment') {
			agent { label 'master' }
			steps {
				script{
					sh 'docker run -p 8081:8081 --name demoapp -d devopsmeetup/meetuptest:$BUILD_NUMBER' 
				}
			}
		}
		
		stage('Test Application') {
			agent { label 'master' }
			steps {
				script{
					sh 'echo Run test cases.'
					sh 'export PATH=$PATH:/home/demoapp/ && python testcase.py'
					sh 'echo Test cases ran successfully.'
				}
			}
		}

		stage('Deploy Application on Production') {
			agent { label 'master' }
			steps {
				script{
					sh 'docker run -p 80:8080 --name demoappprod -d devopsmeetup/meetuptest:$BUILD_NUMBER' 
				}
			}
		}
	}
}
