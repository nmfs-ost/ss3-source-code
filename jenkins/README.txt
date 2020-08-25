Using Dockerfile and Jenkinsfile for only some jobs from this repository:
- build job: jenkins/Dockerfile and jenkins/Jenkinsfile. Builds SS to run tests.
- build-linux job: jenkins/build-linux/Dockerfile and jenkins/build-linux/Jenkinsfile. Builds 3 version of
SS (all linux) to distribute.

All other jobs are run (compare, model, and r4ss) for now run from
https://nwcgit.nwfsc.noaa.gov/fram-data/boatnet-internal

Need more information on stock synthesis jenkins jobs? Contact Kathryn Doering.