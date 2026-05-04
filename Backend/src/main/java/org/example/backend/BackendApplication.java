package org.example.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@SpringBootApplication
public class BackendApplication {

    public static void main(String[] args) {
        loadEnv();
        SpringApplication.run(BackendApplication.class, args);
    }

    private static void loadEnv() {
        Path envPath = Paths.get("backend/.env");

        if (!Files.exists(envPath)) {
            System.out.println("No .env file found at: " + envPath.toAbsolutePath());
            return;
        }

        try {
            for (String line : Files.readAllLines(envPath)) {
                line = line.trim();
                if (line.isEmpty() || line.startsWith("#")) continue;
                int eq = line.indexOf('=');
                if (eq == -1) continue;
                System.setProperty(line.substring(0, eq).trim(), line.substring(eq + 1).trim());
            }
        } catch (IOException e) {
            throw new RuntimeException("Failed to load .env file", e);
        }
    }
}