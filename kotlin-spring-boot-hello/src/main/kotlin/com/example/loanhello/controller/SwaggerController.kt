package com.example.loanhello.controller

import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.GetMapping

@Controller
class SwaggerController {

    @GetMapping("/swagger")
    fun swagger(): String = "redirect:/swagger-ui.html"
}
