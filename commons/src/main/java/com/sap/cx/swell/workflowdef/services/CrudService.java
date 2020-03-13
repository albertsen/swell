package com.sap.cx.swell.workflowdef.services;

import reactor.core.publisher.Mono;

public interface CrudService<T> {

    Mono<T> create(T doc);

    Mono<T> findById(String id);

    Mono<T> update(T doc);

    Mono<Void> delete(String id);

}