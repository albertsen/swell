package com.sap.cx.swell.api.handlers;

import com.sap.cx.swell.services.WorkflowService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class WorkflowHandler extends AbstractCrudHandler<WorkflowService> {

    @Autowired
    public WorkflowHandler(WorkflowService workflowService) {
        super(workflowService);
    }


}