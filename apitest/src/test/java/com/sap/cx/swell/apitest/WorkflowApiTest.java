package com.sap.cx.swell.apitest;

import com.intuit.karate.junit5.Karate;

class WorkflowApiTest {

    @Karate.Test
    Karate testWorkflowApi() {
        return Karate.run("WorkflowApi").relativeTo(getClass());
    }

    @Karate.Test
    Karate testWorkflowDefApi() {
        return Karate.run("WorkflowDefApi").relativeTo(getClass());
    }


}