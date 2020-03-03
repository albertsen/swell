package com.sap.cx.swell.workflow.services.impl;

import com.sap.cx.swell.workflow.model.worflowdef.Workflow;
import com.sap.cx.swell.workflow.repos.WorkflowRepo;
import com.sap.cx.swell.workflow.services.WorkflowService;
import com.sap.cx.swell.workflowdef.services.impl.AbstractCrudService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class WorkflowServiceImpl extends AbstractCrudService<Workflow> implements WorkflowService {

    @Autowired
    public WorkflowServiceImpl(WorkflowRepo repo) {
        super(repo);
    }

}