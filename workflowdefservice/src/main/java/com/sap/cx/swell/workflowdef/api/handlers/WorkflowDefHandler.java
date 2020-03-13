package com.sap.cx.swell.workflowdef.api.handlers;

import com.sap.cx.swell.workflowdef.model.WorkflowDef;
import com.sap.cx.swell.workflowdef.services.WorkflowDefService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class WorkflowDefHandler extends AbstractCrudHandler<WorkflowDefService, WorkflowDef> {

    @Autowired
    public WorkflowDefHandler(WorkflowDefService workflowDefService) {
        super(workflowDefService);
    }


}