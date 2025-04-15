# Etapa 1: Build com Maven e JDK 17
FROM maven:3.8-openjdk-17-slim AS build
WORKDIR /build
# Copia o arquivo pom.xml e baixa as dependências (cache)
COPY pom.xml .
RUN mvn dependency:go-offline -B
# Copia o restante do código fonte e compila o projeto
COPY src ./src
RUN mvn package -DskipTests -B

# Etapa 2: Runtime com JDK 17
FROM openjdk:17-jdk-slim
WORKDIR /app
# Copia o jar gerado na etapa anterior (ajuste o nome conforme seu artifact)
COPY --from=build /build/target/sistema-login-cadastro-0.0.1-SNAPSHOT.jar app.jar

# Exponha a porta do seu serviço
EXPOSE 8080

# Healthcheck para monitorar o container (ajuste a URL se necessário)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
