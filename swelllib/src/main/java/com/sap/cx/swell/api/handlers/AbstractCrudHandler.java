package com.sap.cx.swell.api.handlers;

import com.sap.cx.swell.services.CrudService;
import org.springframework.http.HttpStatus;
import org.springframework.web.reactive.function.server.ServerRequest;
import org.springframework.web.reactive.function.server.ServerResponse;
import reactor.core.publisher.Mono;

import java.lang.reflect.ParameterizedType;

import static org.springframework.web.reactive.function.server.ServerResponse.*;

public abstract class AbstractCrudHandler<S extends CrudService, D> {

    private final Class<D> documentClass;
    private S service;

    public AbstractCrudHandler(S service) {
        this.service = service;
        this.documentClass = (Class<D>)
                ((ParameterizedType) getClass()
                        .getGenericSuperclass())
                        .getActualTypeArguments()[1];
    }

    public Mono<ServerResponse> create(ServerRequest request) {
        return request.bodyToMono(documentClass)
                .flatMap(service::create)
                .flatMap((workflowDef) -> status(HttpStatus.CREATED).bodyValue(workflowDef));
    }

    public Mono<ServerResponse> findById(ServerRequest request) {
        return service.findById(request.pathVariable("id"))
                .flatMap(((workflowDef) -> ok().bodyValue(workflowDef)))
                .switchIfEmpty(notFound().build());
    }

    public Mono<ServerResponse> update(ServerRequest request) {
        return request.bodyToMono(documentClass)
                .flatMap(service::update)
                .flatMap((workflowDef) -> ok().bodyValue(workflowDef));
    }

    public Mono<ServerResponse> delete(ServerRequest request) {
        return service.delete(request.pathVariable("id"))
                .flatMap(((ingore) -> ok().build()));
    }


}
