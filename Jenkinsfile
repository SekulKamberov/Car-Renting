pipeline {
  agent any
  stages {
     stage('Verify Branch') {
       steps {
         echo "$GIT_BRANCH"
       }
     }
    stage('Pull Changes') {
      steps {
        powershell(script: "git pull")
      }
    }
    stage('Run Unit Tests') {
      steps {
        powershell(script: """ 
          cd Server
          dotnet test
          cd ..
        """)
      }
    }
     stage('Docker Build Development') {
       when { branch 'development' }
      steps {
        powershell(script: 'docker-compose build')
        powershell(script: 'docker build -t sekul/carrentalsystem-user-client-development --build-arg configuration=development ./Client')
        powershell(script: 'docker images -a')
      }
    }
    stage('Run Test Application') {
      steps {
        powershell(script: 'docker-compose up -d')    
      }
      post {
        success {
	      echo "Success Run Test Application stage"
	    }
	    failure {
	      powershell(script: 'docker-compose down')
	    }
      }
    }
    stage('Run Integration Tests') {
      steps {
        powershell(script: './Tests/ContainerTests.ps1') 
      }
      post {
	    success {
               echo "Success Run Integration Tests stage"
	    }
	    failure {
	      powershell(script: 'docker-compose down')
	    }
      }
    }
    stage('Stop Test Application') {
      steps {
        powershell(script: 'docker-compose down') 
        // powershell(script: 'docker volumes prune -f')   		
      }
      post {
        success {
		  mail to: 'telerikcsharp1@gmail.com',
		    subject: "Success Pipeline: ${currentBuild.fullDisplayName}",
		    body: "Build with ${env.BUILD_URL} succeeded"
		}
        failure {
		  mail to: 'telerikcsharp1@gmail.com',
		    subject: "Failed Pipeline: ${currentBuild.fullDisplayName}",
		    body: "Something is wrong with ${env.BUILD_URL}"
		}
      }  
    }
    stage('Push Images') {

      steps {
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'Docker Hub') {
            def image = docker.image("sekul/carrentalsystem-identity-service")
            image.push("1.0.${env.BUILD_ID}")
            image.push('latest')
          }
		  docker.withRegistry('https://index.docker.io/v1/', 'Docker Hub') {
            def image = docker.image("sekul/carrentalsystem-dealers-service")
            image.push("1.0.${env.BUILD_ID}")
            image.push('latest')
          }
		  docker.withRegistry('https://index.docker.io/v1/', 'Docker Hub') {
            def image = docker.image("sekul/carrentalsystem-statistics-service")
            image.push("1.0.${env.BUILD_ID}")
            image.push('latest')
          }
		  docker.withRegistry('https://index.docker.io/v1/', 'Docker Hub') {
            def image = docker.image("sekul/carrentalsystem-notifications-service")
            image.push("1.0.${env.BUILD_ID}")
            image.push('latest')
          }
		  docker.withRegistry('https://index.docker.io/v1/', 'Docker Hub') {
            def image = docker.image("sekul/carrentalsystem-user-client-production")
            image.push("1.0.${env.BUILD_ID}")
            image.push('latest')
          }
		  docker.withRegistry('https://index.docker.io/v1/', 'Docker Hub') {
            def image = docker.image("sekul/carrentalsystem-admin-client")
            image.push("1.0.${env.BUILD_ID}")
            image.push('latest')
          }
		 docker.withRegistry('https://index.docker.io/v1/', 'Docker Hub') {
            def image = docker.image("sekul/carrentalsystem-watchdog-service")
            image.push("1.0.${env.BUILD_ID}")
            image.push('latest')
          }
        }
      }
    } 
    stage('Deploy Development') {
      when { branch 'development' }
      steps {
        withKubeConfig([credentialsId: 'DevelopmentServer', serverUrl: 'https://34.72.169.70']) {
		       powershell(script: 'kubectl apply -f ./.k8s/.environment/development.yml') 
		       powershell(script: 'kubectl apply -f ./.k8s/databases') 
		       powershell(script: 'kubectl apply -f ./.k8s/event-bus') 
		       powershell(script: 'kubectl apply -f ./.k8s/web-services') 
           powershell(script: 'kubectl apply -f ./.k8s/clients') 
           powershell(script: 'kubectl set image deployments/user-client user-client=sekul/carrentalsystem-user-client-development:latest')
        }
      }
    }	  	  
       //stage('Input') {
	         //when { branch 'production' }  
            //steps {
                //input('Do you want to proceed?')
           // }
        //}

       // stage('If Proceed is yes') {
			//steps {
				//withKubeConfig([credentialsId: 'DevelopmentServer', serverUrl: '']) {
					//powershell(script: 'kubectl apply -f ./.k8s/.environment/production.yml') 
					//powershell(script: 'kubectl apply -f ./.k8s/databases') 
					//powershell(script: 'kubectl apply -f ./.k8s/event-bus') 
					//powershell(script: 'kubectl apply -f ./.k8s/web-services') 
					//powershell(script: 'kubectl apply -f ./.k8s/clients') 
					//powershell(script: 'kubectl set image deployments/user-client user-client=sekul/carrentalsystem-user-client-production:latest')         
				//}
			//}
		//}	
  }
}
