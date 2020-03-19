package com.sap.cx.swell.core.services.impl;

import com.sap.cx.swell.core.data.WorkflowDef;
import com.sap.cx.swell.core.repos.WorkflowDefRepo;
import com.sap.cx.swell.core.services.WorkflowDefService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class WorkflowDefServiceImpl extends AbstractCrudService<WorkflowDef> implements WorkflowDefService {

    @Autowired
    public WorkflowDefServiceImpl(WorkflowDefRepo repo) {
        super(repo);
    }

}