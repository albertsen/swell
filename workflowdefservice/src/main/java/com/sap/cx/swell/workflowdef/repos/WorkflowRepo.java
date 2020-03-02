package com.sap.cx.swell.workflowdef.repos;

import com.sap.cx.swell.workflowdef.workflowdef.model.worflowdef.WorkflowDef;
import org.springframework.data.mongodb.repository.ReactiveMongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface WorkflowRepo extends ReactiveMongoRepository<WorkflowDef, String> {
}