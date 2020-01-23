pipeline {
    agent { dockerfile { dir 'jenkins/stock-synthesis' } }
    stages {
        stage('Build SS Exectuable') {
            steps {
                git credentialsId: '1aa2d7c8-749f-4270-9de2-6ffcf0cd2beb', url: 'https://stock_synthesis.build@vlab.ncep.noaa.gov/git/stock-synthesis'
                sh label: 'Get ADMB Version', script: 'admb --version'
            }
        }
    }
}