# Etapa 1: compilación
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -q dependency:go-offline
COPY src ./src
RUN mvn -q -DskipTests package

# Etapa 2: ejecución
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
ENV PORT=8080
EXPOSE ${PORT}
ENTRYPOINT ["sh", "-c", "java -jar app.jar --server.port=${PORT}"]
