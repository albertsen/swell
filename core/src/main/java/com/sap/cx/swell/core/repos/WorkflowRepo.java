package com.sap.cx.swell.core.repos;

import com.sap.cx.swell.core.data.Workflow;
import org.springframework.data.mongodb.repository.ReactiveMongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface WorkflowRepo extends ReactiveMongoRepository<Workflow, String> {
}