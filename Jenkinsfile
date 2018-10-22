node {
    def SOCKSHOP_URL = "104.196.41.214"
    def DT_TAGNAME = "ServiceName"
    def DT_TAGVALUE = "microservices-demo-front-end"
	
    stage('kubectl') {
	sh sh """
	kubectl config view
	kubectl set-context gke_jjahn-demo-1_us-east1-b_gke-demo
	kubectl config view
	kubectl get pods -n dynatrace
	"""
    }
	
    stage('Checkout') {
	
	// get our test code
        // checkout scm
	git url: 'https://github.com/robertjahn/dt-kube-pipeline', branch: 'master'

        // into a jmeter subdirectory we checkout the Jmeter shell scripts
        dir ('jmeter') {
	  git url: 'https://github.com/robertjahn/dt-kube-jmeter-as-container', branch: 'master'
        }
	    
        // into a dynatrace-cli subdirectory we checkout the CLI
        dir ('dynatrace-cli') {
            git url: 'https://github.com/Dynatrace/dynatrace-cli.git', branch: 'master'
        }
    }
	
    stage('Run Smoke Test') {
	   
	dir ('dynatrace-scripts') {
		def start_test_cmd = './pushevent.sh SERVICE CONTEXTLESS '+ DT_TAGNAME + ' ' + DT_TAGVALUE +
               ' "STARTING Load Test as part of Job: " ${JOB_NAME} Jenkins-Start-Test ' + 
               ' ${JOB_URL} ${BUILD_URL} ${GIT_COMMIT}'
		echo start_test_cmd
		sh start_test_cmd
        }

        dir ('jmeter') {
            // stop and remove Jmeter docker container if still there
            sh "./cleanup_docker.sh jmeter-test"

            // run test
	    try {
                sh "./smoke_test.sh ${SOCKSHOP_URL}"
            } finally {
	        archiveArtifacts artifacts: 'results/**', fingerprint: true, allowEmptyArchive: true
	        archiveArtifacts artifacts: 'results_raw/**', fingerprint: true, allowEmptyArchive: true
	        archiveArtifacts artifacts: 'results_log/**', fingerprint: true, allowEmptyArchive: true
	    }
	}

        dir ('dynatrace-scripts') {
             def end_test_cmd = './pushevent.sh SERVICE CONTEXTLESS '+ DT_TAGNAME + ' ' + DT_TAGVALUE +
               ' "ENDING Load Test as part of Job: " ${JOB_NAME} Jenkins-End-Test ' + 
               ' ${JOB_URL} ${BUILD_URL} ${GIT_COMMIT}'
	     echo end_test_cmd
	     sh end_test_cmd
        }
     }
}
