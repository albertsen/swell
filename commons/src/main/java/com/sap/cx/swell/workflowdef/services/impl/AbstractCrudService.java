package com.sap.cx.swell.workflowdef.services.impl;

import org.springframework.data.mongodb.repository.ReactiveMongoRepository;
import reactor.core.publisher.Mono;

public abstract class AbstractCrudService<T> {

    private ReactiveMongoRepository repo;

    public AbstractCrudService(ReactiveMongoRepository repo) {
        this.repo = repo;
    }

    public Mono<T> create(T doc) {
        return repo.save(doc);
    }

    public Mono<T> findById(String id) {
        return repo.findById(id);
    }

    public Mono<T> update(T doc) {
        return repo.save(doc);
    }

    public Mono<Void> delete(String id) {
        return repo.deleteById(id);
    }

}
