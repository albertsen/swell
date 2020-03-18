package com.sap.cx.swell.core.services.impl;

import com.sap.cx.swell.core.exceptions.InvalidDataException;
import com.sap.cx.swell.core.model.Workflow;
import com.sap.cx.swell.core.repos.WorkflowRepo;
import com.sap.cx.swell.core.services.WorkflowDefService;
import com.sap.cx.swell.core.services.WorkflowService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

@Service
public class WorkflowServiceImpl extends AbstractCrudService<Workflow> implements WorkflowService {

    static private Logger LOG = LoggerFactory.getLogger(WorkflowServiceImpl.class);
    private WorkflowDefService workflowDefService;

    @Autowired
    public WorkflowServiceImpl(WorkflowRepo repo, WorkflowDefService workflowDefService) {
        super(repo);
        this.workflowDefService = workflowDefService;
    }

    @Override
    public Mono<Workflow> create(Workflow doc) {
        return workflowDefService.findById(doc.getWorkflowDefId())
                .switchIfEmpty(Mono.error(
                        new InvalidDataException("No workflow definition found with ID %s", doc.getWorkflowDefId())))
                .flatMap((workflowDef) -> super.create(doc));
    }
}