# Etapa de build
FROM maven:3.9.5-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

# Etapa final com múltiplos JDKs
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Instala dependências e JDKs
RUN apt-get update && apt-get install -y \
    wget unzip gnupg curl software-properties-common openjdk-17-jdk openjdk-21-jdk

ENV JAVA_17_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV JAVA_21_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV JAVA_HOME=${JAVA_17_HOME}
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Cria pasta da app e copia o .jar
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
