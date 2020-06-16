pipeline {
    agent { dockerfile {
          dir 'jenkins/stock-synthesis'
          args '-u 0:0'
        }
    }
    stages {
        stage('Git clone src for stock-synthesis') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'vlab/stock-synthesis']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '1aa2d7c8-749f-4270-9de2-6ffcf0cd2beb', url: 'https://stock_synthesis.build@vlab.ncep.noaa.gov/git/stock-synthesis']]])
            }
        }
        stage('Build SS Executable') {
            steps {
                sh label: 'view folder structure', script: ls /usr/local/admb -R
				// sh label: 'Check ADMB Version', script: 'admb'
                // sh label: 'Double check source', script: 'ls vlab/stock-synthesis'
                //sh label: 'Copy build script to base location', script: 'cp vlab/stock-synthesis/Make_SS_330.sh .'
                //sh label: 'Make build script executable', script: 'cd vlab/stock-synthesis && chmod a+x Make_SS_330_new.sh'
                sh label: 'Run build', script: 'cd vlab/stock-synthesis && /bin/bash ./Make_SS_330_new.sh -b SS330 -a /usr/local/bin/admb -w'
                sh label: 'Validate build', script: 'cp vlab/stock-synthesis/SS330/ss . && sha256sum ss'
                sh label: 'Archive ss executable', script: 'rm -f ss.gz && gzip -v ss'
            }
        }
        stage('Archive artifact') {
            steps {
              archiveArtifacts 'ss.gz'
            }
        }
    }
	post {
		failure {
			mail bcc: '', body: 'The job Stock-Synthesis-build failed.', cc: '', from: '', replyTo: '', subject: 'stock-synthesis-build: Jenkins Build Failure', to: 'kathryn.doering@noaa.gov richard.methot@noaa.gov ian.taylor@noaa.gov'
		}
		changed {
			script {
				if (currentBuild.currentResult == 'SUCCESS') { // Other values: SUCCESS, UNSTABLE
					// Send an email only if the build status has changed from failure to success
				   mail bcc: '', body: 'The job Stock-Synthesis-build is now passing.', cc: '', from: '', replyTo: '', subject: 'stock-synthesis-build: Jenkins Build Passing Again', to: 'kathryn.doering@noaa.gov richard.methot@noaa.gov ian.taylor@noaa.gov'
				}
			}
		}
    }
}