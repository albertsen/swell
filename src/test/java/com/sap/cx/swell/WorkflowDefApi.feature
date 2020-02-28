Feature: Workflow Def CRUD
  Background:
    * url 'http://localhost:8080/workflowdefs/'
    * header Accept = 'application/json'
    * json doc = read('classpath:com/sap/cx/swell/WorkflowDef.json')
  Scenario: Create workflow def
    When request doc
    And method post
    Then status 201
    And match response == doc
  Scenario: Get workflow def
    When path doc.id
    And method get
    Then status 200
  Scenario: Update workflow def
    * set doc.description = "Updated description"
    When path doc.id
    And request doc
    And method put
    Then status 200
    And match response == doc
  Scenario: Delete workflow def
    When path doc.id
    And method delete
    Then status 200
  Scenario: Don't find deleted workflow def
    When path doc.id
    And method get
    Then status 404Feature