package com.sap.cx.swell.core.services.impl;

import com.sap.cx.swell.core.exceptions.ConflictException;
import com.sap.cx.swell.core.exceptions.NotFoundException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.data.mongodb.repository.ReactiveMongoRepository;
import reactor.core.publisher.Mono;

public abstract class AbstractCrudService<T> {

    static private Logger LOG = LoggerFactory.getLogger(AbstractCrudService.class);
    private ReactiveMongoRepository<T, String> repo;

    public AbstractCrudService(ReactiveMongoRepository<T, String> repo) {
        this.repo = repo;
    }

    public Mono<T> create(T doc) {
        return repo.insert(doc)
                .flatMap((insertedDoc) -> Mono.just(insertedDoc))
                .onErrorMap(DuplicateKeyException.class,
                        e -> {
                            return new ConflictException("A document with same ID already exists");
                        });
    }

    public Mono<T> findById(String id) {
        return repo.findById(id)
                .switchIfEmpty(Mono.error(new NotFoundException("No document found with ID '%s", id)));
    }

    public Mono<T> update(T doc) {
        return repo.save(doc);
    }

    public Mono<Void> delete(String id) {
        return repo.deleteById(id);
    }

}
