package com.sap.cx.swell.apitest;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.sap.cx.swell.core.data.Workflow;
import com.sap.cx.swell.core.data.WorkflowDef;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.filter.log.RequestLoggingFilter;
import io.restassured.filter.log.ResponseLoggingFilter;
import io.restassured.http.ContentType;
import io.restassured.specification.RequestSpecification;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;

import java.io.IOException;

import static io.restassured.RestAssured.given;
import static net.javacrumbs.jsonunit.assertj.JsonAssertions.assertThatJson;
import static org.assertj.core.api.Assertions.assertThat;

public class WorkflowApiTest {

    private static RequestSpecification workflowDefRequestSpec;
    private static RequestSpecification workflowRequestSpec;
    private static ObjectMapper objectMapper = new ObjectMapper();
    private Workflow workflow;
    private WorkflowDef workflowDef;

    @BeforeAll
    public static void initSpecs() {
        workflowDefRequestSpec = new RequestSpecBuilder()
                .setContentType(ContentType.JSON)
                .setBaseUri("http://localhost:8080/workflowdefs")
                .addFilter(new ResponseLoggingFilter())
                .addFilter(new RequestLoggingFilter())
                .build();
        workflowRequestSpec = new RequestSpecBuilder()
                .setContentType(ContentType.JSON)
                .setBaseUri("http://localhost:8080/workflows")
                .addFilter(new ResponseLoggingFilter())
                .addFilter(new RequestLoggingFilter())
                .build();
    }

    @BeforeEach
    public void loadData() throws IOException {
        workflow = objectMapper.readValue(getClass().getResourceAsStream("Workflow.json"), Workflow.class);
        workflowDef = objectMapper.readValue(getClass().getResourceAsStream("WorkflowDef.json"), WorkflowDef.class);
    }

    @Test
    public void testWorkflowApi() {
        testCRUWorkflowDef();
        testWorkflowReadAndCreate();
        testWorkflowWithInvalidWorkflowDef();
        testDeleteWorkflowDef();
    }

    protected void testCRUWorkflowDef() {
        WorkflowDef createdWorkflowDef = given()
                .spec(workflowDefRequestSpec)
                .body(workflowDef)
                .when()
                .post()
                .then()
                .statusCode(HttpStatus.CREATED.value())
                .extract().as(WorkflowDef.class);
        assertThatJson(createdWorkflowDef).isEqualTo(workflowDef);
        given()
                .spec(workflowDefRequestSpec)
                .body(workflowDef)
                .when()
                .post()
                .then()
                .statusCode(HttpStatus.CONFLICT.value());
        WorkflowDef storedWorkflowDef = given()
                .spec(workflowDefRequestSpec)
                .pathParam("id", workflowDef.getId())
                .when()
                .get("/{id}")
                .then()
                .statusCode(HttpStatus.OK.value())
                .extract().as(WorkflowDef.class);
        assertThatJson(storedWorkflowDef).isEqualTo(workflowDef);
        workflowDef.setDescription("Updated description");
        WorkflowDef updatedWorkflowDef = given()
                .spec(workflowDefRequestSpec)
                .pathParam("id", workflowDef.getId())
                .body(workflowDef)
                .when()
                .put("/{id}")
                .then()
                .statusCode(HttpStatus.OK.value())
                .extract().as(WorkflowDef.class);
        assertThatJson(updatedWorkflowDef).isEqualTo(workflowDef);
        storedWorkflowDef = given()
                .spec(workflowDefRequestSpec)
                .pathParam("id", workflowDef.getId())
                .when()
                .get("/{id}")
                .then()
                .statusCode(HttpStatus.OK.value())
                .extract().as(WorkflowDef.class);
        assertThatJson(storedWorkflowDef).isEqualTo(workflowDef);
    }

    protected void testDeleteWorkflowDef() {
        given()
                .spec(workflowDefRequestSpec)
                .pathParam("id", workflowDef.getId())
                .when()
                .delete("/{id}")
                .then()
                .statusCode(HttpStatus.OK.value());
        given()
                .spec(workflowDefRequestSpec)
                .pathParam("id", workflowDef.getId())
                .when()
                .get("/{id}")
                .then()
                .statusCode(HttpStatus.NOT_FOUND.value());
    }

    protected void testWorkflowReadAndCreate() {
        Workflow createdWorklow = given()
                .spec(workflowRequestSpec)
                .body(workflow)
                .when()
                .post()
                .then()
                .statusCode(HttpStatus.CREATED.value())
                .extract().as(Workflow.class);
        assertThat(createdWorklow.getId()).as("Workflow ID").isNotNull();
        workflow.setId(createdWorklow.getId());
        assertThatJson(createdWorklow).isEqualTo(workflow);
        Workflow storedWorkflow = given()
                .spec(workflowRequestSpec)
                .pathParam("id", createdWorklow.getId())
                .body(workflow)
                .when()
                .get("{id}")
                .then()
                .statusCode(HttpStatus.OK.value())
                .extract().as(Workflow.class);
        assertThatJson(storedWorkflow).isEqualTo(workflow);
    }

    protected void testWorkflowWithInvalidWorkflowDef() {
        workflow.setWorkflowDefId("invalid");
        given()
                .spec(workflowRequestSpec)
                .body(workflow)
                .when()
                .post()
                .then()
                .statusCode(HttpStatus.UNPROCESSABLE_ENTITY.value());
    }


}