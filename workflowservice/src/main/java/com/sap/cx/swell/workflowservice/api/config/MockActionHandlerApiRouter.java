package com.sap.cx.swell.workflowservice.api.config;

import com.sap.cx.swell.workflowservice.api.handlers.MockActionHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.MediaType;
import org.springframework.web.reactive.function.server.RouterFunction;
import org.springframework.web.reactive.function.server.RouterFunctions;
import org.springframework.web.reactive.function.server.ServerResponse;

import static org.springframework.web.reactive.function.server.RequestPredicates.POST;
import static org.springframework.web.reactive.function.server.RequestPredicates.accept;

@Configuration
public class MockActionHandlerApiRouter {

    @Bean
    public RouterFunction<ServerResponse> route(MockActionHandler handler) {
        return RouterFunctions
                .route(POST("/action").and(accept(MediaType.APPLICATION_JSON)), handler::handleAction);
    }

}
