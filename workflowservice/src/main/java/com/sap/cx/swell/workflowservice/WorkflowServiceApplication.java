package com.sap.cx.swell.workflowservice;

import com.sap.cx.swell.actionhandler.services.ActionHandlerService;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

import javax.annotation.PostConstruct;

@SpringBootApplication
@ComponentScan(basePackages = {"com.sap.cx.swell"})
public class WorkflowServiceApplication {

    private final ActionHandlerService actionHandlerService;

    public WorkflowServiceApplication(ActionHandlerService actionHandlerService) {
        this.actionHandlerService = actionHandlerService;
    }

    public static void main(String[] args) {
        SpringApplication.run(WorkflowServiceApplication.class, args);
    }

    @PostConstruct
    public void init() {
        actionHandlerService.startHandlingRequests();
    }

}
