package org.example.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@SpringBootApplication
public class BackendApplication {

    public static void main(String[] args) {
        loadEnv();
        SpringApplication.run(BackendApplication.class, args);
    }

    private static void loadEnv() {
        List<Path> candidates = List.of(
                Paths.get(".env"),
                Paths.get("Backend/.env"),
                Paths.get(System.getProperty("user.dir"), ".env")
        );

        Path envPath = null;
        for (Path candidate : candidates) {
            System.out.println("Trying: " + candidate.toAbsolutePath());
            if (Files.exists(candidate)) {
                envPath = candidate;
                break;
            }
        }

        if (envPath == null) {
            System.out.println("No .env file found!");
            return;
        }

        System.out.println("Loading .env from: " + envPath.toAbsolutePath());

        try {
            for (String line : Files.readAllLines(envPath)) {
                line = line.trim();
                if (line.isEmpty() || line.startsWith("#")) continue;
                int eq = line.indexOf('=');
                if (eq == -1) continue;
                String key = line.substring(0, eq).trim();
                String value = line.substring(eq + 1).trim();
                System.setProperty(key, value);
                System.out.println("Loaded: " + key + "=***");
            }
        } catch (IOException e) {
            throw new RuntimeException("Failed to load .env file", e);
        }
    }

}
