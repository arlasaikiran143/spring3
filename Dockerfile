# Stage 1: Build WAR using Maven + Java 21
FROM maven:3.9.6-eclipse-temurin-21 AS build

WORKDIR /app

# Copy entire project to the container
COPY . .

# Optional: Verify POM is present
RUN ls -l && cat pom.xml

# Build the WAR file (you can skip tests if needed)
RUN mvn clean package -DskipTests

# Stage 2: Run using Tomcat
FROM tomcat:10.1-jdk21-temurin

RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR file to Tomcat
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
