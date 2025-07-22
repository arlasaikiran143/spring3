pipeline {
    agent any

    tools {
        maven "Maven3"
        jdk "Java17"
    }

    environment {
        SONARQUBE_ENV = 'MySonarQube'
        NEXUS_CREDENTIAL_ID = 'nexus-keygen'
        NEXUS_URL = 'http://54.90.70.220:8081'
        NEXUS_REPOSITORY = 'sample'
        DOCKER_IMAGE = 'arlasaikiran1/sample'
        DOCKERHUB_CREDENTIALS = 'docker-creds'
        TOMCAT_URL = 'http://3.90.64.42:8083/manager/text'
        TOMCAT_CREDENTIALS = 'tomcat-creds'
    }

    stages {
        stage('Checkout') {
            steps {
                deleteDir()
                wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                    git branch: 'main', url: 'https://github.com/manikiran7/spring3.git'
                }
            }
        }

        stage('Verify JDK') {
            steps {
                sh 'echo "JAVA_HOME: $JAVA_HOME"'
                sh '$JAVA_HOME/bin/java -version'
            }
        }

        stage('Code Quality - SonarQube') {
            steps {
                wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                    withSonarQubeEnv("${SONARQUBE_ENV}") {
                        sh 'mvn clean verify sonar:sonar'
                    }
                }
            }
        }

        stage('Maven Build') {
            steps {
                wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                    sh '''
                        if [ "$SKIP_TESTS" = "true" ]; then
                            mvn clean install -DskipTests
                        else
                            mvn clean install
                        fi
                    '''
                }
            }
        }

        stage('Upload to Nexus') {
            steps {
                wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                    script {
                        def artifactPath = "target/ncodeit-hello-world-3.0.war"
                        if (!fileExists(artifactPath)) {
                            error "WAR file not found: ${artifactPath}"
                        }

                        nexusArtifactUploader(
                            nexusVersion: 'nexus3',
                            protocol: 'http',
                            nexusUrl: NEXUS_URL,
                            groupId: 'com.ncodeit',
                            version: "${BUILD_NUMBER}",
                            repository: NEXUS_REPOSITORY,
                            credentialsId: NEXUS_CREDENTIAL_ID,
                            artifacts: [[
                                artifactId: 'ncodeit-hello-world',
                                classifier: '',
                                file: artifactPath,
                                type: 'war'
                            ]]
                        )
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                    script {
                        def warFile = "target/ncodeit-hello-world-3.0.war"
                        if (!fileExists(warFile)) {
                            error("WAR file not found! Ensure Maven build was successful.")
                        }

                        sh """
                            docker ps -a --filter "ancestor=${DOCKER_IMAGE}" --format "{{.ID}}" | xargs -r docker stop || true
                            docker ps -a --filter "ancestor=${DOCKER_IMAGE}" --format "{{.ID}}" | xargs -r docker rm || true
                            docker images ${DOCKER_IMAGE} --format "{{.Repository}}:{{.Tag}}" | grep -v ":${BUILD_NUMBER}" | xargs -r docker rmi || true
                        """

                        sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
                        sh "docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest"
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                    withCredentials([usernamePassword(credentialsId: DOCKERHUB_CREDENTIALS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                            docker push ${DOCKER_IMAGE}:latest
                            docker logout
                        """
                    }
                }
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                    withCredentials([usernamePassword(credentialsId: TOMCAT_CREDENTIALS, usernameVariable: 'TOMCAT_USER', passwordVariable: 'TOMCAT_PASS')]) {
                        sh '''
                            curl -v -T target/ncodeit-hello-world-3.0.war \
                            -u $TOMCAT_USER:$TOMCAT_PASS \
                            "${TOMCAT_URL}?path=/maniapp&update=true"
                        '''
                    }
                }
            }
        }
    }
}
