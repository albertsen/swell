package com.sap.cx.swell.api.handlers;

import com.sap.cx.swell.model.worflowdef.WorkflowDef;
import com.sap.cx.swell.services.WorkflowDefService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.server.ServerRequest;
import org.springframework.web.reactive.function.server.ServerResponse;
import reactor.core.publisher.Mono;

import static org.springframework.web.reactive.function.server.ServerResponse.*;

@Component
public class WorkflowDefHandler {

    private WorkflowDefService workflowDefService;

    @Autowired
    public WorkflowDefHandler(WorkflowDefService workflowDefService) {
        this.workflowDefService = workflowDefService;
    }

    public Mono<ServerResponse> create(ServerRequest request) {
        return request.bodyToMono(WorkflowDef.class)
                .flatMap(workflowDefService::create)
                .flatMap((workflowDef) -> status(HttpStatus.CREATED).bodyValue(workflowDef));
    }

    public Mono<ServerResponse> findById(ServerRequest request) {
        return workflowDefService.findById(request.pathVariable("id"))
                .flatMap(((workflowDef) -> ok().bodyValue(workflowDef)))
                .switchIfEmpty(notFound().build());
    }

    public Mono<ServerResponse> update(ServerRequest request) {
        return request.bodyToMono(WorkflowDef.class)
                .flatMap(workflowDefService::create)
                .flatMap((workflowDef) -> ok().bodyValue(workflowDef));
    }

    public Mono<ServerResponse> delete(ServerRequest request) {
        return workflowDefService.delete(request.pathVariable("id"))
                .flatMap(((ingore) -> ok().build()));
    }


}
