package com.sap.cx.swell.workflow.repos;

import com.sap.cx.swell.workflow.model.worflowdef.Workflow;
import org.springframework.data.mongodb.repository.ReactiveMongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface WorkflowRepo extends ReactiveMongoRepository<Workflow, String> {
}