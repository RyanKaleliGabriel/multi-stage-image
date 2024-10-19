# Stage 1 - Provides a java development kit environment for building the app
#This stage is given the name builder

# Define your base image
FROM eclipse-temurin:21.0.2_13-jdk-jammy AS builder

WORKDIR /opt/app

# Copy the mave wrapper and pom.xml into the current working directory within the docker container
COPY .mvn/ .mvn
COPY mvnw pom.xml ./

# Execute a command within the container 
# Runs  a command which uses the maven wrapper to download all dependencies without building in the final JAR file
RUN ./mvnw dependency:go-offline

#Copy src from your project on the host machine to the /app directory within the container
COPY src ./src

RUN ./mvnw clean install


# Stage 2 - Named final stage. Uses a slimmer jre image containing jus the java runtime environment needed
# to run the application. This image provides a java runtime environment which is enough for running the compiled application
FROM eclipse-temurin:21.0.2_13-jre-jammy AS final

# DEFINE WORKING DIRECTORY
WORKDIR /opt/app

# configure application running port
EXPOSE 8080

#Copy compiled source code
COPY --from=builder /opt/app/target/*.jar /opt/app*.jar

# Conatiner running commands
ENTRYPOINT ["java", "-jar", "/opt/app/*.jar"]



