#!groovy

import groovy.json.JsonSlurper
import java.text.SimpleDateFormat
import java.util.Calendar

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
		
		stage('Deploy Application') {
			agent { label 'master' }
			steps {
				script{
					sh 'docker kill demoapp'
					sh 'docker rm demoapp'
					sh 'docker run -p 80:8080 --name demoapp -d devopsmeetup/meetuptest:$BUILD_NUMBER' 
				}
			}
		}

	}
}
