# ---------------------------------------------
# Stage 1: Build (com Maven e JDK 17)
# ---------------------------------------------
FROM maven:3.8-openjdk-17-slim AS build

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn package -DskipTests -B


# ---------------------------------------------
# Stage 2: Devcontainer com JDK 17 e 21 (para Codespaces)
# ---------------------------------------------
FROM mcr.microsoft.com/devcontainers/base:ubuntu AS devcontainer

# Instala dependências básicas
RUN apt-get update && apt-get install -y \
    wget unzip gnupg curl software-properties-common

# Instala JDK 17
RUN apt-get install -y openjdk-17-jdk

# Instala JDK 21
RUN apt-get install -y openjdk-21-jdk

# Define variáveis de ambiente
ENV JAVA_17_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV JAVA_21_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV JAVA_HOME=${JAVA_17_HOME}
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Define shell padrão (útil para Codespaces)
CMD [ "bash" ]


# ---------------------------------------------
# Stage 3: Runtime limpo apenas com JDK 17
# ---------------------------------------------
FROM openjdk:17-jdk-slim AS runtime

WORKDIR /app

COPY --from=build /app/target/sistema-login-cadastro-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
