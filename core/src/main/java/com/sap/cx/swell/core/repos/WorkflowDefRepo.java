package com.sap.cx.swell.core.repos;

import com.sap.cx.swell.core.model.WorkflowDef;
import org.springframework.data.mongodb.repository.ReactiveMongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface WorkflowDefRepo extends ReactiveMongoRepository<WorkflowDef, String> {
}