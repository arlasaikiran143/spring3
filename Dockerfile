# Stage 1: Build WAR
FROM maven:3.9.6-eclipse-temurin-21 AS build

WORKDIR /app

COPY pom.xml .
COPY src ./src

# ✅ Explicitly run the build
RUN mvn clean package

# Stage 2: Run with Tomcat
FROM tomcat:10.1-jdk21-temurin

# Clean default apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR from build stage
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
