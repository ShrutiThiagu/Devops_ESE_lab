# CORRECTION 1: Use a Java 17 base image, not 11, to match your pom.xml
FROM amazoncorretto:17-alpine-jdk

# Set the working directory
WORKDIR /app

# CORRECTION 2: Copy the correct JAR name from your pom.xml (version 1.0)
COPY target/shruti-app-1.0.jar app.jar

# CORRECTION 3: Expose port 8080 (the default)
# It's better to run as a non-privileged user on a non-privileged port
# and map it to port 80 when you run the container.
EXPOSE 8080

# Command to run the application on its default port 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
