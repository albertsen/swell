package com.sap.cx.swell.workflowdef.services.impl;

import com.sap.cx.swell.workflowdef.model.WorkflowDef;
import com.sap.cx.swell.workflowdef.repos.WorkflowDefRepo;
import com.sap.cx.swell.workflowdef.services.WorkflowDefService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class WorkflowDefServiceImpl extends AbstractCrudService<WorkflowDef> implements WorkflowDefService {

    @Autowired
    public WorkflowDefServiceImpl(WorkflowDefRepo repo) {
        super(repo);
    }

}