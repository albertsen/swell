package com.sap.cx.swell.workflowservice.api.handlers;

import com.sap.cx.swell.core.api.handlers.AbstractCrudHandler;
import com.sap.cx.swell.core.data.WorkflowDef;
import com.sap.cx.swell.core.services.WorkflowDefService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class WorkflowDefHandler extends AbstractCrudHandler<WorkflowDefService, WorkflowDef> {

    @Autowired
    public WorkflowDefHandler(WorkflowDefService workflowDefService) {
        super(workflowDefService);
    }

}