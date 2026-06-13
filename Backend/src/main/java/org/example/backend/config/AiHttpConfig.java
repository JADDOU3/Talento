package org.example.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.converter.json.JacksonJsonHttpMessageConverter;
import org.springframework.web.client.RestTemplate;
import tools.jackson.databind.MapperFeature;
import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.json.JsonMapper;

import java.util.List;

@Configuration
public class AiHttpConfig {

    @Bean(name = "aiRestTemplate")
    public RestTemplate aiRestTemplate() {
        JsonMapper snakeCaseMapper = JsonMapper.builder()
                .propertyNamingStrategy(PropertyNamingStrategies.SNAKE_CASE)
                .enable(MapperFeature.ACCEPT_CASE_INSENSITIVE_PROPERTIES)
                .build();

        JacksonJsonHttpMessageConverter converter = new JacksonJsonHttpMessageConverter(snakeCaseMapper);

        RestTemplate restTemplate = new RestTemplate();
        restTemplate.setMessageConverters(List.of(converter));
        return restTemplate;
    }
}