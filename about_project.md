* PREREQUISITES
    * At the very minimal we need a source code and pom.xml and jdk 21 and maven 3 
    * Pom tells us what jdk and maven version we need to use to compiple this code
    * Compile  mean to  turn the code into machine readable format

* The Difference Between Go and Java Packaging            

    Think about your Go project. When you compiled your Go application, it generated a completely independent, native binary file. Everything needed to run the app was compiled down and packed tightly into that single file.

    Java does not work that way. When Maven compiles your Java files, it creates individual standard compiled blocks called .class files. When it packs them together into a standard .jar file, it is just a basic zip file full of unorganized code.If you try to run that standard file using java -jar, the Java runtime looks inside it, gets confused, and says: "Hey, this is just a pile of code. Where is the main starting door? I don't know who to execute first!"

* To solve this 

    * In pom.xml we add a build plugin "spring-boot-maven-plugin"
    * When we add this plugin, We are telling Maven to execute an advanced Repackaging Process.
    * The plugin performs two crucial operations behind the scenes:

* SETUP ENVIRONMENT(MACHINE)
    * Install  JDK 21 (jdk can compile and run the code as well while jre only can run)
    * install maven 3 to build code( dependency manager)
    * PUt the source code in dedicated folder structure java needs it src/main/java/com/example/java/yourcode.java
    * pom.xml file (wheree dependencies are written) should be at root of your project

* BUILD THE PROJECT
    * run maven goal # mvn clean package  to build the code
    * if successfull it will create a folder named target at root directory 
    * inside target folder we will have our output .jar file
    * But this jar file cannot run using java -jar  beacuse it is just a zip of java compiled classes.
    * To Solve this we added a plugin in pom.xml 

* WHAT THE PLUGIN(spring-boot-maven-plugin) DOES
    * It Writes the Manifest Map (The Starting Door)It creates a tiny hidden metadata file inside your jar package called MANIFEST.MF. 
    * Inside that file, it stamps one line explicitly:Main-Class: org.springframework.boot.loader.JarLauncherStart-Class: com.example.App
    * This is the exact "Main Manifest Attribute" that your terminal was complaining about! Now, when you run java -jar, Java opens the package, reads that line, and instantly knows exactly how to boot up your server.
    * It Creates a "Fat JAR" (Injects Tomcat Server) A standard Java file does not know how to handle web requests
    * It needs a web server like Tomcat. The plugin automatically pulls down the embedded Tomcat server libraries
    * and injects them directly inside your .jar archive file.This creates what we call a "Fat JAR" or an Executable
    * JAR—a single package that contains both your logic and the server itself, allowing it to deploy anywhere smoothly
    * build project mvn clean package done with new plugin it will again create a jar file this file can be executed alone..
    * On local we can run this code and access the application using localhost:8080
    * To run  java -jar /path/to the .jar file

* DOCKERIZE THIS APP

    * create docker file 
    * create docker image with this file
    * push docker image to dockerhub
    * Again run the app using prot forwarding 
    * docker run -p 8080:8080 -name springboot_app imageid

* Now we will try to run the app on k8s cluster
    * Create cluster (minikube on wsl)
    * Create k8s manifest files deployment,service, ingress 
    * Deploy the app and check if app accessible done use prot forwarding to access from WSL
* Package the project into helm chart
    * Install the helm and create helm chart 
    * Copy manifest file to /helm/springboot_app_chart/templates/
    * Change the hardcoded values eg image tag in deployment yaml file with jinja2 template 
    * Provide the values for image tag etc in /helm/springboot_app_chart/values.yaml file
    * RUN the app using helm install <releasename> /helm/springboot_app_chart/chart.yaml
    * It will create all the resources as mentioned in template folder
    * Again test if application working done(use port forwarding to access from WSL)




