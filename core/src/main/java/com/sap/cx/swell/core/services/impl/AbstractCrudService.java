package com.sap.cx.swell.core.services.impl;

import com.sap.cx.swell.core.exceptions.ConflictException;
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
                .flatMap((insertedDoc) -> {
                    LOG.info(insertedDoc.toString());
                    return Mono.just(insertedDoc);
                })
                .onErrorMap(DuplicateKeyException.class,
                        e -> {
                            LOG.error("Error ceeating document", e);
                            return new ConflictException("Conflict creating document");
                        });
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
