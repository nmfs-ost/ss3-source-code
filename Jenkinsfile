pipeline {
    agent { dockerfile { dir 'jenkins/stock-synthesis' } }
    stages {
        stage('Build SS Exectutable') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'vlab/stock-synthesis']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '1aa2d7c8-749f-4270-9de2-6ffcf0cd2beb', url: 'https://stock_synthesis.build@vlab.ncep.noaa.gov/git/stock-synthesis']]])
                sh script: 'whoami'
                sh label: 'Get ADMB Version', script: 'admb --version'
            }
        }
    }
}