# Spring Boot GitOps & Kubernetes Deployment Guide

## 1. Prerequisites
* **Source Code & `pom.xml`**: Minimal project files required.
* **JDK 21**: Java Development Kit to compile and run the application.
* **Maven 3**: Build automation and dependency management tool.
* **Core Concepts**:
  * The `pom.xml` dictates which JDK and Maven versions are required to build the application.
  * **Compilation** translates human-readable Java code into machine-readable bytecode (`.class` files).

---

## 2. Environment Setup
Before building, ensure your machine is configured correctly:
* **Install JDK 21**: Note that a JDK can compile and run code, while a JRE can only run it.
* **Install Maven 3**: Used as the code builder and dependency manager.
* **Folder Structure**: Place the source code in Java's strict dedicated layout: `src/main/java/com/example/java/yourcode.java`
* **Root Files**: The `pom.xml` file must reside at the absolute root of your project directory.

---

## 3. Building the Project (Standard vs. Executable JAR)

### Step 1: Run the initial build
Run the Maven goal to build the project:
```bash
mvn clean package
```
If successful, this creates a `target/` folder at the root directory containing your output `.jar` file. However, this raw JAR cannot run on its own because it lacks execution metadata.


## 4. The Packaging Difference: Go vs. Java

### Go Packaging
When you compile a Go application, it generates a completely **independent, native binary file**. Everything needed to run the application is compiled down and packed tightly into that single file.

### Java Packaging
Java does not work that way by default. When Maven compiles your Java files, it creates individual compiled blocks called `.class` files. When packed into a standard `.jar` file, it behaves like a basic ZIP file full of unorganized code. 

If you try to run that standard file using `java -jar`, the Java runtime gets confused and throws an error: 
> *"Error: Invalid or corrupt jarfile"* or *"no main manifest attribute"*

It effectively asks: *"Hey, this is just a pile of code. Where is the main starting door? I don't know who to execute first!"*

---

### Step 2: Add the Spring Boot Maven Plugin
To solve the execution issue, add the `spring-boot-maven-plugin` to your `pom.xml` inside the `<build>` block. This plugin performs two crucial advanced repackaging operations behind the scenes:

1. **Writes the Manifest Map (The Starting Door)**: It creates a hidden metadata file inside your package called `MANIFEST.MF` and explicitly stamps the execution paths:
   ```manifest
   Main-Class: org.springframework.boot.loader.JarLauncher
   Start-Class: com.example.App
   ```
   This resolves the "Main Manifest Attribute" error. When you run `java -jar`, Java reads this file and instantly knows how to boot the server.
2. **Creates a "Fat JAR" (Injects Tomcat Server)**: A standard Java app cannot handle HTTP web requests natively without a web server. The plugin pulls down embedded Tomcat server libraries and injects them directly into your `.jar` archive. This creates a **Fat JAR** (or Executable JAR) that contains both your logic and the server, allowing it to deploy anywhere smoothly.

### Step 3: Run the final execution
Re-run the build with the plugin active:
```bash
mvn clean package
```
Execute the self-contained package locally:
```bash
java -jar target/your-app-name.jar
```
Access the application locally at `http://localhost:8080`.

---

## 5. Containerization (Dockerize the App)
1. **Create a `Dockerfile`** at the root of the project to package the Fat JAR.
2. **Build the Docker Image** using the local Docker daemon.
3. **Push the Image** to a public or private container registry like Docker Hub.
4. **Test the Container Locally** using port forwarding:
   ```bash
   docker run -p 8080:8080 --name springboot_app <image_id_or_tag>
   ```

---

## 6. Kubernetes Orchestration
1. **Provision a Local Cluster**: Spin up **Minikube** inside your Windows Subsystem for Linux (WSL) environment.
2. **Write K8s Manifests**: Create standard declarative files:
   * `deployment.yaml` (to manage application pods)
   * `service.yaml` (for internal routing)
   * `ingress.yaml` (for external access mapping)
3. **Deploy & Validate**: Apply the manifests to the cluster and use `kubectl port-forward` to access and verify the app from your WSL terminal.

---

## 7. Package Management with Helm
Refactor your raw Kubernetes manifests into a reusable, parameterised Helm Chart:

1. **Initialize the Chart**: Install the Helm CLI and create a boilerplate chart directory.
2. **Migrate Manifests**: Move your existing YAML manifests into the `/helm/springboot_app_chart/templates/` directory.
3. **Template the Configuration**: Replace hardcoded values (such as image tags and replica counts) in your deployment templates with Go template expressions (e.g., `{{ .Values.image.tag }}`).
4. **Define Variables**: Supply default overrides and values inside the `/helm/springboot_app_chart/values.yaml` file.
5. **Install the Release**: Deploy your application using the Helm package:
   ```bash
   helm install springboot-app ./helm/springboot_app_chart
   ```
6. **Final Verification**: Verify that Helm successfully created all resources in the template folder and test using port forwarding from WSL.

## 8. AUTOMATE ALL THESE TASK GITHUB ACTION (CI)
1.  **CREATE WORKFLOW FILE FOLDER**: create a .github/wokrflows at root of your project & inside it create cicd.yaml
2.  **INSIDE THE CICD FILE**: Mention all the actions 
3.  **CREATE GITHUB REPO AND ADD IT AS REMOTE ORIGIN**: at poject root run
   ```bash
   git init
   git remote add orgin <yourgithub repo url>
   git add .
   git commit -m "adding the local file to push on remote url"
   git push origin main 
   ```
4. **GITHUB ACTION**: check on github repo github action must be started 

## 9. DEPLOYING TO K8S GITOPS ARGOCD
1.  **Argocd Install**: install argocd on the minikube cluster.
```bash
   kubectl create namespace argocd
   kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml   
```
2.  **Verify if resource of argocd running**: 
```bash
   kubectl get all --namespace argocd
```
3.  **Access the argicd server**: Use port forwarding .. on browser localhost:8083
```bash
   kubectl port-forward svc/argocd-server -n argocd 8083:443 --address 0.0.0.0
```
4.  **Login to argocd server on browser**: username admin and password from argocd secrets ..copy and decode
```bash
   kubectl get secrets -n argocd
   kubectl edit secret argocd-initial-admin-secret -n argocd # copy from here
   echo R0gtNU9MTEl5Y3B5R21Hbg== | base64 --decode
```
5.  **Project Create**: 
   * `Application Name: go-web-app` (to manage application pods)
   * `Project Name: default` (for internal routing)
   * `Sync Policy: Set to Automatic and check SelfHeal` (for external access mapping)
   * `Repository URL: https://github.comRevision: HEAD (or main)` Your github repo url
   * `Path:` This is the folder containing your Helm chart).
   * `Destination Cluster URL`  https://default.svc (This always points to the local cluster Argo CD is currently running inside).
   * `Destination Namespace` default namespace where your app will run
   


