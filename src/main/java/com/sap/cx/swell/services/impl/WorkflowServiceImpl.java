package com.sap.cx.swell.services.impl;

import com.sap.cx.swell.model.worflow.Workflow;
import com.sap.cx.swell.repos.WorkflowDefRepo;
import com.sap.cx.swell.repos.WorkflowRepo;
import com.sap.cx.swell.services.WorkflowDefService;
import com.sap.cx.swell.services.WorkflowService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

@Service
public class WorkflowServiceImpl extends AbstractCrudService<Workflow> implements WorkflowService {

    @Autowired
    public WorkflowServiceImpl(WorkflowRepo repo) {
        super(repo);
    }

    @Override
    public Mono<Workflow> create(Workflow doc) {
        if (doc.getId() != null) {
            throw new IllegalArgumentException("New workflow can't have an ID");
        }
        return super.create(doc);
    }
}