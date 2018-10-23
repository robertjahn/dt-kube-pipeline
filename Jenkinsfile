node {
    def SOCKSHOP_URL = "104.196.41.214"
    def DT_SERVICE_FE_TAGNAME = "ServiceName"
    def DT_SERVICE_FE_TAGVALUE = "microservices-demo-front-end"
	
    stage('kubectl') {
	withCredentials([file(credentialsId: 'GC_KEY', variable: 'GC_KEY')]) {
          sh("gcloud auth activate-service-account --key-file=${GC_KEY}")
          sh("gcloud container clusters get-credentials gke-demo --zone us-east1-b --project jjahn-demo-1")
	  sh("gcloud compute instances list")
  	  sh("kubectl config view")
	  sh("kubectl get pods -n dynatrace")
	}
    }
	
    stage('Deploy') {

        dir ('dynatrace-scripts') {
		
            def deploy_cmd = './pushdeployment.sh SERVICE CONTEXTLESS ' + DT_SERVICE_FE_TAGNAME + ' ' + DT_SERVICE_FE_TAGVALUE +
               ' ${BUILD_TAG} ${BUILD_NUMBER} ${JOB_NAME} ${JENKINS_URL}' + 
               ' ${JOB_URL} ${BUILD_URL} ${GIT_COMMIT}'
	    echo deploy_cmd
	    sh deploy_cmd
        }    
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
		def start_test_cmd = './pushevent.sh SERVICE CONTEXTLESS '+ DT_SERVICE_FE_TAGNAME + ' ' + DT_SERVICE_FE_TAGVALUE +
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
             def end_test_cmd = './pushevent.sh SERVICE CONTEXTLESS '+ DT_SERVICE_FE_TAGNAME + ' ' + DT_SERVICE_FE_TAGVALUE +
               ' "ENDING Load Test as part of Job: " ${JOB_NAME} Jenkins-End-Test ' + 
               ' ${JOB_URL} ${BUILD_URL} ${GIT_COMMIT}'
	     echo end_test_cmd
	     sh end_test_cmd
        }
     }
	
     stage('Validate') {
        // lets see if Dynatrace AI found problems -> if so - we can stop the pipeline!
        dir ('dynatrace-scripts') {
            DYNATRACE_PROBLEM_COUNT = sh (script: './checkforproblems.sh', returnStatus : true)
            echo "Dynatrace Problems Found: ${DYNATRACE_PROBLEM_COUNT}"
        }
        
        // now lets generate a report using our CLI and lets generate some direct links back to dynatrace
        dir ('dynatrace-cli') {
	    
            sh 'python3 dtcli.py dqlr srv tag=' + DT_SERVICE_FE_TAGNAME + ':' + DT_SERVICE_FE_TAGVALUE +
                        ' service.responsetime[avg%hour],service.responsetime[p90%hour] ${DT_URL} ${DT_TOKEN}'
            //sh 'mv dqlreport.html dqlstagingreport.html'
            archiveArtifacts artifacts: 'dqlreport.html', fingerprint: true, allowEmptyArchive: true
            
            // get the link to the service's dashboard and make it an artifact
            sh 'python3 dtcli.py link srv tag=' + DT_SERVICE_FE_TAGNAME + ':' + DT_SERVICE_FE_TAGVALUE +
		    ' overview 60:0 ${DT_URL} ${DT_TOKEN} > dtstagelinks.txt'
            archiveArtifacts artifacts: 'dtstagelinks.txt', fingerprint: true, allowEmptyArchive: true
	    
        }
    }
}
