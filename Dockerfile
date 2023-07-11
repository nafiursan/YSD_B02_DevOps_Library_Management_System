FROM maven:3.8.3-openjdk-11 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn package -DskipTests

FROM openjdk:11-jre-slim
WORKDIR /app
COPY --from=build /app/target/spark-lms-0.0.1-SNAPSHOT.jar .
EXPOSE 8080
CMD ["java", "-jar", "spark-lms-0.0.1-SNAPSHOT.jar"]
