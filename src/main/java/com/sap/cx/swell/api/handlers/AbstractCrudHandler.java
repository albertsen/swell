package com.sap.cx.swell.api.handlers;

import com.sap.cx.swell.model.worflowdef.WorkflowDef;
import com.sap.cx.swell.services.CrudService;
import com.sap.cx.swell.services.WorkflowDefService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.reactive.function.server.ServerRequest;
import org.springframework.web.reactive.function.server.ServerResponse;
import reactor.core.publisher.Mono;

import static org.springframework.web.reactive.function.server.ServerResponse.*;
import static org.springframework.web.reactive.function.server.ServerResponse.ok;

public abstract class AbstractCrudHandler<T extends CrudService> {

    private T service;

    public AbstractCrudHandler(T service) {
        this.service = service;
    }

    public Mono<ServerResponse> create(ServerRequest request) {
        return request.bodyToMono(WorkflowDef.class)
                .flatMap(service::create)
                .flatMap((workflowDef) -> status(HttpStatus.CREATED).bodyValue(workflowDef));
    }

    public Mono<ServerResponse> findById(ServerRequest request) {
        return service.findById(request.pathVariable("id"))
                .flatMap(((workflowDef) -> ok().bodyValue(workflowDef)))
                .switchIfEmpty(notFound().build());
    }

    public Mono<ServerResponse> update(ServerRequest request) {
        return request.bodyToMono(WorkflowDef.class)
                .flatMap(service::update)
                .flatMap((workflowDef) -> ok().bodyValue(workflowDef));
    }

    public Mono<ServerResponse> delete(ServerRequest request) {
        return service.delete(request.pathVariable("id"))
                .flatMap(((ingore) -> ok().build()));
    }


}
