package com.sap.cx.swell.workflowservice.api.config;


import com.sap.cx.swell.workflowservice.api.handlers.WorkflowDefHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.MediaType;
import org.springframework.web.reactive.function.server.RouterFunction;
import org.springframework.web.reactive.function.server.RouterFunctions;
import org.springframework.web.reactive.function.server.ServerResponse;

import static org.springframework.web.reactive.function.server.RequestPredicates.*;

@Configuration
public class WorkflowDefApiRouter {
    @Bean
    public RouterFunction<ServerResponse> workflowDefRoute(WorkflowDefHandler handler) {
        return RouterFunctions
                .route(POST("/workflowdefs").and(accept(MediaType.APPLICATION_JSON)), handler::create)
                .andRoute(GET("/workflowdefs/{id}").and(accept(MediaType.APPLICATION_JSON)), handler::findById)
                .andRoute(PUT("/workflowdefs/{id}").and(accept(MediaType.APPLICATION_JSON)), handler::update)
                .andRoute(DELETE("/workflowdefs/{id}").and(accept(MediaType.APPLICATION_JSON)), handler::delete);
    }

}