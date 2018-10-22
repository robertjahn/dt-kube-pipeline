node {
    environment {
        URL = "35.231.224.62"
    }
	
    stage('Checkout') {
	
	// get our test code
	git url: 'https://github.com/dt-kube-pipeline', branch: 'master'
	    
        // into a dynatrace-cli subdirectory we checkout the CLI
        dir ('dynatrace-cli') {
            git url: 'https://github.com/Dynatrace/dynatrace-cli.git', branch: 'master'
        }
    }
	
    stage('Run Smoke Test') {
	   
	dir ('dynatrace-scripts') {
            //sh '.pushevent.sh SERVICE CONTEXTLESS DockerService SampleNodeJsStaging ' +
            //   '"STARTING Load Test" ${JOB_NAME} "Starting a Load Test as part of the Testing stage"' + 
            //   ' ${JENKINS_URL} ${JOB_URL} ${BUILD_URL} ${GIT_COMMIT}'
        }

        // stop docker container if running	
        sh "./cleanup.sh jmeter-test"

        // run test
	sh "./smoke.sh ${URL}"
     }

     post {
        always {
	    archiveArtifacts artifacts: 'results/**', fingerprint: true, allowEmptyArchive: true
	    archiveArtifacts artifacts: 'results_raw/**', fingerprint: true, allowEmptyArchive: true
	    archiveArtifacts artifacts: 'results_log/**', fingerprint: true, allowEmptyArchive: true
        }
     }
}
