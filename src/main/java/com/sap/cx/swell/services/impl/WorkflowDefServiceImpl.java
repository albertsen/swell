package com.sap.cx.swell.services.impl;

import com.sap.cx.swell.model.worflowdef.WorkflowDef;
import com.sap.cx.swell.repos.WorkflowDefRepo;
import com.sap.cx.swell.services.WorkflowDefService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class WorkflowDefServiceImpl extends AbstractCrudService<WorkflowDef> implements WorkflowDefService {

    @Autowired
    public WorkflowDefServiceImpl(WorkflowDefRepo repo) {
        super(repo);
    }

}