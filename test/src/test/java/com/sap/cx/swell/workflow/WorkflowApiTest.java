package com.sap.cx.swell.workflow;

import com.intuit.karate.junit5.Karate;

class WorkflowApiTest {

    @Karate.Test
    Karate test() {
        return Karate.run("WorkflowApi").relativeTo(getClass());
    }

}