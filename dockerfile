FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Create a secure, minimal production container using Distroless
# gcr.io/distroless/java21-debian12 contains ONLY the JVM and no OS shell
FROM gcr.io/distroless/java21-debian12:latest AS run
WORKDIR /app

# Copy the compiled executable jar from the build stage
COPY --from=build /app/target/java-web-app-1.0.0.jar app.jar

EXPOSE 8081

# Since distroless has no shell, we MUST use the exec array format
# And we pass our custom port flag directly as an argument
CMD ["app.jar", "--server.port=8081"]