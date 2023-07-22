# Use the official OpenJDK 11 base image
FROM openjdk:11

# Set the working directory inside the container
WORKDIR /app

# Copy the JAR file from the local build context to the container's working directory
COPY target/*.jar store-0.0.1-SNAPSHOT.jar

# Expose port 8080 to allow external access to the application
EXPOSE 8080

# Define the command to run the application as an executable JAR
CMD ["java", "-jar", "store-0.0.1-SNAPSHOT.jar"]

