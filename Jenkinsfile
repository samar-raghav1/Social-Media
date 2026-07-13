pipeline{
    agent any

    stages{
        stage("checkout"){
            steps{
                git url:' https://github.com/samar-raghav/Social-Media.git'  , branch: 'main'

                echo "Code checked out successfully"
            }
        }

        stage("docker build stage"){
            steps{
                echo "Building docker image for frontend"
                sh 'docker build -t socialmedia-frontend:latest ./client'
                echo "Building docker image for backend"
                sh 'docker build -t socialmedia-backend:latest ./server'

                echo "Docker images built successfully"
            }
        }

        stage("docker push stage"){
            steps{
                withCredentials([usernamePassword(
                    credentialsId: 'docker-jen-conn' ,
                    userVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]){
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker tag socialmedia-frontend:latest samarraghav1/socialmedia-frontend:latest'
                    sh 'docker tag socialmedia-backend:latest samarraghav1/socialmedia-backend:latest'
                    sh 'docker push samarraghav1/socialmedia-frontend:latest'
                    sh 'docker push samarraghav1/socialmedia-backend:latest'

                    echo "Docker images pushed successfully"
                }
            }
        }

        stage("deploy stage"){
            steps{
                echo "Deploying the application using docker-compose"
                sh 'docker compose up -d --build'

                echo "Application deployed successfully"
            }
        }
        

    }
}