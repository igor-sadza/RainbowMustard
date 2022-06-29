class Globals {
    def projectName      = "PROJECT-NAME"
    def stages           = [ 'Git','Sonarqube','Flyway','Tomcat','Selenium','Nexus','Docker' ]
    def stagesChoosed    = []
    def stageAll         = false
    def userName         = "USER"
    def userPassword     = "PASSWORD"
    
    def urlGit           = "ssh://git@docker-centos:8004/home/git/flyway/"
    def urlSonar         = "http://docker-centos:8002"
    def urlMysql         = "jdbc:mysql://docker-centos:7000/" //?allowPublicKeyRetrieval=true&useSSL=False;"
    def urlTomcat        = "http://docker-centos:8011/manager/text/"
    def urlNexusSnapshot = "http://docker-centos:8003/repository/devops-snapshot/"
    def urlNexusRelease  = "http://docker-centos:8003/repository/devops-release/"
}

def globals = new Globals() 

// HELPER FUNCTIONS
def getGitBranches() {
    return sh(script: "git branch -r | grep -wv 'HEAD\\|master' | sed 's,.*/,,g' ", returnStdout: true).trim().split('\n')
}  
    
pipeline {
    //agent any
    agent { label 'node-slave-debian'}
    
    stages {
        stage ('Prebuild') {
           //options { timeout(time: 10, unit: "SECONDS") }
            steps {
                script {      
                    
                    inputMessage        = ("\n- Build all stages\n- Build multiple stages\n")
                    timeoutInSeconds    = 15
                    // First prompt
                    try {
                        timeout(time: timeoutInSeconds, unit:'SECONDS') {
                            interactiveInput = input message: inputMessage, parameters: [
                                choice(choices: ['All', 'Single/Multiple'], name: '')
                            ]
                        }
                    } catch(err) {
                        interactiveInput = ['All']
                    }
                    
                    if (interactiveInput == 'All') {
                        globals.stageAll = true
                    }
                    
                    inputMessage        = ("\n- Select stages to build\n")
                    interactiveInput    = []
                    inputParameters     = []
                    timeoutInSeconds    = 15
                    // second prompt
                    try {
                        timeout(time: timeoutInSeconds, unit:'SECONDS') {
                            globals.stages.each { stage ->
                                inputParameters += 
                                        booleanParam(defaultValue: globals.stageAll, name: stage, description: '')
                            } 
                            interactiveInput = input message: inputMessage, parameters: inputParameters
                        }
                    } catch(err) { 
                        globals.stagesChoosed = globals.stages
                    }
                    
                    interactiveInput.each { item ->
                        def str_item = "$item"
                        if (str_item.contains('true')) {
                            globals.stagesChoosed.add("$item")
                        }
                    }                        
                }
            }            
        }
        
        //when { 
        //    anyOf { 
        //        expression { globals.stagesChoosed.any { stage -> stage.contains('Git') } }
        //        expression { ... } 
        //    } 
        //}
        
        stage('Git') {
            when { expression { globals.stagesChoosed.any { stage -> stage.contains('Git') } } }
            steps {
                //CLEAN WORKSPACE
                cleanWs()
                script{
                     //CURRENT SCRIPT
                    sh """git clone ${globals.urlGit} . """
                }
            }
        }
        
        stage('Sonarqube') {
            when { expression { globals.stagesChoosed.any { stage -> stage.contains('Sonarqube') } } }
            steps {
                script {
                    gitBranches = getGitBranches()
                    gitBranches.each { branch ->
                        //PRE                
                        sh "git clean -fd"
                        sh "git checkout $branch"
                         //CURRENT SCRIPT
                        sh """
                            mvn -f */ \
                            clean \
                            verify \
                            -Dhttps.protocols=TLSv1.2 \
                            -Dsonar.projectKey=${globals.projectName}-${branch} \
                            -Dsonar.projectName=${globals.projectName}-${branch} \
                            -Dsonar.login=${globals.userName} \
                            -Dsonar.password=${globals.userPassword} \
                            -Dsonar.host.url=${globals.urlSonar} \
                            sonar:sonar                
                        """
                   }
                   sh "git checkout -f master"
                }
            } 
        }
        
        stage('Flyway') {
            when { expression { globals.stagesChoosed.any { stage -> stage.contains('Flyway') } } }
            steps {
                script {
                    echo "FLYWAY: CLEAN"
                    gitBranches = getGitBranches()
                    gitBranches.each { branch ->
                        //PRE                    
                        sh "git clean -fd"
                        sh "git checkout -f $branch"
                        sh """
                            sed -i 's,docker-centos:7000/flyway,docker-centos:7000/flyway-${branch},g' \
                            */src/main/webapp/WEB-INF/database.cfg.xml
                            """
                        //CURRENT SCRIPT
                        try {
                            sh """
                                mvn -f */ \
                                -Dhttps.protocols=TLSv1.2 \
                                -Dflyway.schemas=${globals.projectName}-${branch} \
                                -Dflyway.user=${globals.userName} \
                                -Dflyway.password=${globals.userPassword} \
                                -Dflyway.url=${globals.urlMysql} \
                                flyway:clean
                            """                        
                        } catch (_exception) { }
                    }
                }
                script {
                    echo "FLYWAY: MIGRATE"
                    gitBranches = getGitBranches()
                    gitBranches.each { branch ->
                        //PRE                    
                        sh "git clean -fd"
                        sh "git checkout -f $branch"
                        sh """
                            sed -i 's,docker-centos:7000/flyway,docker-centos:7000/flyway-${branch},g' \
                            */src/main/webapp/WEB-INF/database.cfg.xml
                        """
                        //CURRENT SCRIPT
                        sh """
                            mvn -f */ \
                            -Dhttps.protocols=TLSv1.2 \
                            -Dflyway.schemas=${globals.projectName}-${branch} \
                            -Dflyway.user=${globals.userName} \
                            -Dflyway.password=${globals.userPassword} \
                            -Dflyway.url=${globals.urlMysql} \
                            flyway:migrate
                        """
                    }
                }
            }
        }
        
        stage('Tomcat') {
            when { expression { globals.stagesChoosed.any { stage -> stage.contains('Tomcat') } } }
            steps {
                script {
                    gitBranches = getGitBranches()
                    gitBranches.each { branch ->
                        //PRE
                        sh "git clean -fd"
                        sh "git checkout -f $branch"

                        sh """sed -i 's,docker-centos:7000/flyway,docker-centos:7000/flyway-${branch},g' \\
                            */src/main/webapp/WEB-INF/database.cfg.xml"""                        
                            
                        sh """sed -i 's,${globals.projectName},${globals.projectName}-${branch},g' \\
                            */src/main/webapp/WEB-INF/web.xml"""
                            
                        sh """sed -i 's,${globals.projectName},${globals.projectName}-${branch},g' \\
                            */src/main/webapp/WEB-INF/views/welcome.jsp"""
                            
                        //CURRENT SCRIPT
                        sh """mvn -f */ \
                            package \
                            -Ddeploy-path=/${globals.projectName}-${branch} \
                            -Ddeploy-user=${globals.userName} \
                            -Ddeploy-pass=${globals.userPassword} \
                            -Dserver-url=${globals.urlTomcat} \
                            tomcat7:redeploy
                        """
                    }
                    sh "git checkout -f master"
                }
            }
        }
        
        stage('Nexus') {
            when { expression { globals.stagesChoosed.any { stage -> stage.contains('Nexus') } } }
            steps {
                script {
                    gitBranches = getGitBranches()
                    gitBranches.each { branch ->
                        sh "git clean -fd"
                        sh "git checkout -f $branch"
                        
                        sh """cd * && cat << EOF > settings.xml
<settings>
  <servers>
    <server>
      <id>nexus</id>
      <username>${globals.userName}</username>
      <password>${globals.userPassword}</password>
    </server>
  </servers>
</settings>
                        """.stripMargin()
                        
                        sh """
                            mvn -f */ \
                            package \
                            -Dhttps.protocols=TLSv1.2 \
                            -DpomFile=pom.xml \
                            -DgeneratePom=false \
                            -Durl=${globals.urlNexusSnapshot} \
                            -Dfile=target/${globals.projectName}.war \
                            -DartifactId=${globals.projectName}-${branch} \
                            -DrepositoryId=nexus \
                            -s */settings.xml \
                            deploy:deploy-file
                        """
                    }
                    sh "git checkout -f master"
                }
            }
        }      
        
        stage('Selenium') {
            when { expression { globals.stagesChoosed.any { stage -> stage.contains('Selenium-OFF') } } }
            steps {
                script {
                    gitBranches = getGitBranches()
                    gitBranches.each { branch ->
                        sh "git clean -fd"
                        sh "git checkout -f $branch"
                        
                        sh """mvn -f */ \
                        
                        """
                    }
                    sh "git checkout -f master"
                }
            }
        }
        
        stage('Docker') {
            when { expression { globals.stagesChoosed.any { stage -> stage.contains('Docker') } } }
            steps {
                script {
                    gitBranches = getGitBranches()
                    gitBranches.each { branch ->
                        sh "git clean -fd"
                        sh "git checkout -f $branch"
                        
                        sh """
                            var=\$(echo ${globals.projectName}-${branch} | sed -e 's/[A-Z]/-\\L&/g' -e 's/-//')
                            sed -i "s/e>.*<\\/n/e>\$var<\\/n/" */pom.xml
                        """
                        sh '''cd * && cat <<\\EOF > fabric8.plugin
<plugin>
  <groupId>io.fabric8</groupId>
  <artifactId>docker-maven-plugin</artifactId>
  <version>0.27.2</version>
  <configuration>
      <images>
          <image>
              <name>${project.name}</name>
              <build>
                  <from>tomcat:8.0</from>
                  <assembly>
                      <descriptorRef>artifact</descriptorRef>
                      <targetDir>/usr/local/tomcat/webapps/</targetDir>
                  </assembly>
                  <ports>
                      <port>8080</port>
                  </ports>
                  <cmd>catalina.sh run</cmd>
              </build>
              <run>
                  <ports>
                      <port>8080:8080</port>
                  </ports>
              </run>
          </image>
      </images>
  </configuration>
</plugin>
EOF
                        '''
                        
                        sh """cd * && sed -i -e '/<plugins>/r fabric8.plugin' pom.xml""" 
                        
                        sh """ 
                            export DOCKER_HOST=tcp://docker-centos:2375 &&
                            mvn -f */ \
                            package \
                            docker:build
                        """
                    }
                }
            }
        }
    }
}

//FILE PROVIDER PLUGIN
//configFileProvider([configFile(fileId: 'FILE-ID', variable: 'GROOVY-VARIABLE')]) { $GROOVY-VARIABLE }
