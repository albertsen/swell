package com.sap.cx.swell.core.services.impl;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sap.cx.swell.core.data.Workflow;
import com.sap.cx.swell.core.data.WorkflowDef;
import com.sap.cx.swell.core.exceptions.InvalidDataException;
import com.sap.cx.swell.core.msg.ActionRequest;
import com.sap.cx.swell.core.repos.WorkflowRepo;
import com.sap.cx.swell.core.services.WorkflowDefService;
import com.sap.cx.swell.core.services.WorkflowService;
import org.reactivestreams.Publisher;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import reactor.core.Exceptions;
import reactor.core.publisher.Mono;
import reactor.rabbitmq.OutboundMessage;
import reactor.rabbitmq.Sender;

@Service
public class WorkflowServiceImpl extends AbstractCrudService<Workflow> implements WorkflowService {

    private ObjectMapper objectMapper;
    private Sender sender;
    private WorkflowDefService workflowDefService;

    @Autowired
    public WorkflowServiceImpl(WorkflowRepo repo, WorkflowDefService workflowDefService,
                               Sender sender, ObjectMapper objectMapper) {
        super(repo);
        this.workflowDefService = workflowDefService;
        this.sender = sender;
        this.objectMapper = objectMapper;
    }

    @Override
    public Mono<Workflow> create(Workflow workflow) {
        return workflowDefService.findById(workflow.getWorkflowDefId())
                .switchIfEmpty(Mono.error(
                        new InvalidDataException("No workflow definition found with ID %s", workflow.getWorkflowDefId())))
                .flatMap((workflowDef) ->
                        super.create(workflow)
                                .flatMap((createdWorkflow) -> Mono.just(new WorkflowSpec(workflow, workflowDef))))
                .flatMap((workflowSpec) -> {
                    startWorkflow(workflowSpec);
                    return Mono.just(workflowSpec.getWorkflow());
                });
    }

    private void startWorkflow(WorkflowSpec workflowSpec) {
        sender.send(createStartMessage(workflowSpec));
    }

    private Publisher<OutboundMessage> createStartMessage(WorkflowSpec workflowSpec) {
        return Mono.just(workflowSpec)
                .flatMap((spec) -> Mono.just(new ActionRequest(
                        spec.getWorkflow().getId(),
                        spec.getWorkflowDef().getId(),
                        spec.getWorkflowDef().getStartHandlerDef())))
                .flatMap((actionRequest) -> {
                    try {
                        return Mono.just(objectMapper.writeValueAsBytes(actionRequest));
                    } catch (JsonProcessingException e) {
                        throw Exceptions.propagate(e);
                    }
                })
                .flatMap((json) -> Mono.just(new OutboundMessage("actions", "", json)));
    }

    private class WorkflowSpec {
        private Workflow workflow;
        private WorkflowDef workflowDef;

        private WorkflowSpec(Workflow workflow, WorkflowDef workflowDef) {
            this.workflow = workflow;
            this.workflowDef = workflowDef;
        }

        public Workflow getWorkflow() {
            return workflow;
        }

        public WorkflowDef getWorkflowDef() {
            return workflowDef;
        }
    }

}