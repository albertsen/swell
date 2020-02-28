package com.sap.cx.swell.services.impl;

import com.sap.cx.swell.model.worflowdef.WorkflowDef;
import com.sap.cx.swell.repos.WorkflowDefRepo;
import com.sap.cx.swell.services.WorkflowDefService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

@Service
public class WorkflowDefServiceImpl implements WorkflowDefService {

    @Autowired
    private WorkflowDefRepo workflowDefRepo;

    public Mono<WorkflowDef> create(WorkflowDef workflowDef) {
        return workflowDefRepo.save(workflowDef);
    }

    public Mono<WorkflowDef> findById(String id) {
        return workflowDefRepo.findById(id);
    }


    public Mono<WorkflowDef> update(WorkflowDef workflowDef) {
        return workflowDefRepo.save(workflowDef);
    }

    public Mono<Void> delete(String id) {
        return workflowDefRepo.deleteById(id);
    }
}
