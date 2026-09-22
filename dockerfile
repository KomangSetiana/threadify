# ==== STAGE 1 BUILD ====
FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /app

# Copy pom.xml dulu saja, belum source code
COPY pom.xml .


# Download dependency - di-cache selama pom.xml tidak berubah
RUN mvn dependency:go-offline -B


# Baru copy source code
COPY src ./src


# Build, skip test (test idelnya jalan di CI step terpisah, bukan build image)
RUN mvn clean package -DskipTests -B


# === STAGE 2 RUN ===
FROM eclipse-temurin:21-jre-alpine


WORKDIR /app


# Jalankan sebagai non-root user, bukan root
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring


#Copy hanya hasil build .jar dari STAGE 1, bukan seluruh project
COPY --from=build /app/target/*.jar app.jar


EXPOSE 8080


ENTRYPOINT ["java", "-jar", "app.jar"]