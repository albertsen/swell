package com.sap.cx.swell.apitest.api.handlers;

import com.sap.cx.swell.core.api.handlers.AbstractCrudHandler;
import com.sap.cx.swell.core.data.Workflow;
import com.sap.cx.swell.core.services.WorkflowService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class WorkflowHandler extends AbstractCrudHandler<WorkflowService, Workflow> {

    @Autowired
    public WorkflowHandler(WorkflowService workflowService) {
        super(workflowService);
    }
}