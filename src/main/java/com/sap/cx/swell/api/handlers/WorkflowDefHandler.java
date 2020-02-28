package com.sap.cx.swell.api.handlers;

import com.sap.cx.swell.services.WorkflowDefService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class WorkflowDefHandler extends AbstractCrudHandler<WorkflowDefService> {

    @Autowired
    public WorkflowDefHandler(WorkflowDefService workflowDefService) {
        super(workflowDefService);
    }


}
