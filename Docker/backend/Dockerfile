<<<<<<< HEAD
FROM maven:3.9.9-eclipse-temurin-17 AS builder

WORKDIR /app

COPY ../../Backend/pom.xml .

RUN mvn -B -q -e -DskipTests dependency:go-offline

COPY ../../Backend/src ./src

RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jdk-jammy

WORKDIR /app

COPY --from=builder /app/target/*.jar app.jar

=======
FROM maven:3.9.9-eclipse-temurin-17 AS builder

WORKDIR /app

COPY Backend/pom.xml .

RUN mvn -B -q -e -DskipTests dependency:go-offline

COPY Backend/src ./src

RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jdk-jammy

WORKDIR /app

COPY --from=builder /app/target/*.jar app.jar

>>>>>>> 1fa9b86a49e02d460f12550142ed08adf9cf170e
ENTRYPOINT ["java", "-jar", "app.jar"]