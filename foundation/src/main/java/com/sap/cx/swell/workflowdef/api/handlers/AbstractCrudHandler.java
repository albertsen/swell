package com.sap.cx.swell.workflowdef.api.handlers;

import com.sap.cx.swell.workflowdef.services.CrudService;
import org.springframework.http.HttpStatus;
import org.springframework.web.reactive.function.server.ServerRequest;
import org.springframework.web.reactive.function.server.ServerResponse;
import reactor.core.publisher.Mono;

import java.lang.reflect.ParameterizedType;

public abstract class AbstractCrudHandler<S extends CrudService, D> {

    private final Class<D> documentClass;
    private S service;

    public AbstractCrudHandler(S service) {
        this.service = service;
        this.documentClass = (Class<D>) ((ParameterizedType) this.getClass().getGenericSuperclass()).getActualTypeArguments()[1];
    }

    public Mono<ServerResponse> create(ServerRequest request) {
        return request.bodyToMono(documentClass)
                .flatMap(service::create)
                .flatMap((workflowDef) -> ServerResponse.status(HttpStatus.CREATED).bodyValue(workflowDef));
    }

    public Mono<ServerResponse> findById(ServerRequest request) {
        return service.findById(request.pathVariable("id"))
                .flatMap(((workflowDef) -> ServerResponse.ok().bodyValue(workflowDef)))
                .switchIfEmpty(ServerResponse.notFound().build());
    }

    public Mono<ServerResponse> update(ServerRequest request) {
        return request.bodyToMono(documentClass)
                .flatMap(service::update)
                .flatMap((workflowDef) -> ServerResponse.ok().bodyValue(workflowDef));
    }

    public Mono<ServerResponse> delete(ServerRequest request) {
        return service.delete(request.pathVariable("id"))
                .flatMap(((ingore) -> ServerResponse.ok().build()));
    }

}
