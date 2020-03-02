package com.sap.cx.swell.workflowdef;

import com.intuit.karate.junit5.Karate;

class WorkflowDefApiTest {

    @Karate.Test
    Karate test() {
        return Karate.run("WorkflowDefApi").relativeTo(getClass());
    }

}