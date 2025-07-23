# Stage 1: Build WAR using Maven + Java 21
FROM maven:3.9.6-eclipse-temurin-21 AS build

WORKDIR /app

COPY pom.xml .
COPY src ./src

# ✅ This line is CRITICAL
RUN mvn clean package

# Stage 2: Run WAR with Tomcat
FROM tomcat:10.1-jdk21-temurin

# Clean default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR to Tomcat
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
