package com.ese.devops.shrutiapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class ShrutiAppApplication {

    public static void main(String[] args) {
        SpringApplication.run(ShrutiAppApplication.class, args);
    }

    @GetMapping("/")
    public String hello() {
        return "Hello Shruti! Your DevOps ESE Pipeline is working! v1.0";
    }
}
