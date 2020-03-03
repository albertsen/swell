package com.sap.cx.swell.workflow.api.handlers;

import com.sap.cx.swell.workflow.model.worflowdef.Workflow;
import com.sap.cx.swell.workflow.services.WorkflowService;
import com.sap.cx.swell.workflowdef.api.handlers.AbstractCrudHandler;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class WorkflowHandler extends AbstractCrudHandler<WorkflowService, Workflow> {

    @Autowired
    public WorkflowHandler(WorkflowService workflowService) {
        super(workflowService);
    }


}