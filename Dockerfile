# Stage 1: Build WAR using Maven + Java 21
FROM maven:3.9.6-eclipse-temurin-21 AS build

WORKDIR /app

# Copy Maven files
COPY pom.xml .
COPY src ./src

# Build WAR file
RUN mvn clean package -DskipTests

# Stage 2: Run using Tomcat
FROM tomcat:10.1-jdk21-temurin

# Remove default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR file to Tomcat's webapps directory
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
