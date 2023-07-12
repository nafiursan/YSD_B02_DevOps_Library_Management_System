FROM openjdk:11
WORKDIR /app
COPY target/*.jar store-0.0.1-SNAPSHOT.jar
EXPOSE 8080
CMD ["java", "-jar", "store-0.0.1-SNAPSHOT.jar"]
