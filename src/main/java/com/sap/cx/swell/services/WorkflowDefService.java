package com.sap.cx.swell.services;

import com.sap.cx.swell.model.worflowdef.WorkflowDef;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

public interface WorkflowDefService {

    Mono<WorkflowDef> create(WorkflowDef e);

    Mono<WorkflowDef> findById(String id);

    Mono<WorkflowDef> update(WorkflowDef e);

    Mono<Void> delete(String id);
}
