package com.example.loanhello.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class SwaggerController {

    @GetMapping("/swagger")
    public String swaggerRedirect() {
        return "redirect:/swagger/index.html";
    }

    @GetMapping("/swagger/index.html")
    public String swaggerUi() {
        return "forward:/swagger.html";
    }
}
