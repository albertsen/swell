package com.sap.cx.swell.workflow.api.config;

import com.sap.cx.swell.workflow.api.handlers.WorkflowHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.MediaType;
import org.springframework.web.reactive.function.server.RouterFunction;
import org.springframework.web.reactive.function.server.RouterFunctions;
import org.springframework.web.reactive.function.server.ServerResponse;

import static org.springframework.web.reactive.function.server.RequestPredicates.*;

@Configuration
public class WorkflowApiRouter {
    @Bean
    public RouterFunction<ServerResponse> workflowDefRoute(WorkflowHandler handler) {
        return RouterFunctions
                .route(POST("/workflows").and(accept(MediaType.APPLICATION_JSON)), handler::create)
                .andRoute(GET("/workflows/{id}").and(accept(MediaType.APPLICATION_JSON)), handler::findById);
    }

}