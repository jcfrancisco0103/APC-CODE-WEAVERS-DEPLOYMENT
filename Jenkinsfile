pipeline {
    agent any

    environment {
        PYTHON = 'python3'
        VENV_DIR = '.venv'
        DOCKER_COMPOSE_FILE = 'docker-compose.yml'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo 'Code checked out successfully'
            }
        }

        stage('Setup Environment') {
            steps {
                script {
                    if (isUnix()) {
                        sh '''
                            ${PYTHON} -m venv ${VENV_DIR}
                            . ${VENV_DIR}/bin/activate
                            pip install --upgrade pip
                            pip install -r requirements.txt
                        '''
                    } else {
                        bat '''
                            python -m venv %VENV_DIR%
                            call %VENV_DIR%\\Scripts\\activate.bat
                            pip install --upgrade pip
                            pip install -r requirements.txt
                        '''
                    }
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    if (isUnix()) {
                        sh '''
                            . ${VENV_DIR}/bin/activate
                            python manage.py test --verbosity=2
                        '''
                    } else {
                        bat '''
                            call %VENV_DIR%\\Scripts\\activate.bat
                            python manage.py test --verbosity=2
                        '''
                    }
                }
            }
        }

        stage('Collect Static Files') {
            steps {
                script {
                    if (isUnix()) {
                        sh '''
                            . ${VENV_DIR}/bin/activate
                            python manage.py collectstatic --noinput
                        '''
                    } else {
                        bat '''
                            call %VENV_DIR%\\Scripts\\activate.bat
                            python manage.py collectstatic --noinput
                        '''
                    }
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    try {
                        if (isUnix()) {
                            sh 'docker-compose -f ${DOCKER_COMPOSE_FILE} build'
                        } else {
                            bat 'docker-compose -f %DOCKER_COMPOSE_FILE% build'
                        }
                    } catch (Exception e) {
                        echo "Docker build failed: ${e.getMessage()}"
                        echo "Continuing without Docker build..."
                    }
                }
            }
        }

        stage('Deploy Application') {
            steps {
                script {
                    try {
                        if (isUnix()) {
                            sh '''
                                docker-compose -f ${DOCKER_COMPOSE_FILE} down
                                docker-compose -f ${DOCKER_COMPOSE_FILE} up -d web db
                            '''
                        } else {
                            bat '''
                                docker-compose -f %DOCKER_COMPOSE_FILE% down
                                docker-compose -f %DOCKER_COMPOSE_FILE% up -d web db
                            '''
                        }
                    } catch (Exception e) {
                        echo "Docker deployment failed: ${e.getMessage()}"
                        echo "Continuing without Docker deployment..."
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed.'
        }
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
        cleanup {
            script {
                try {
                    if (isUnix()) {
                        sh 'docker system prune -f || true'
                    } else {
                        bat 'docker system prune -f || echo "Docker cleanup skipped"'
                    }
                } catch (Exception e) {
                    echo "Cleanup failed: ${e.getMessage()}"
                }
            }
        }
    }
}
