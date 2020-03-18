Feature: Workflow

  Background:
    * header Accept = 'application/json'

  Scenario: Create & Read
    # Create Wrofklow def
    Given url 'http://localhost:8080/workflowdefs/'
    And request read('classpath:com/sap/cx/swell/apitest/WorkflowDef.json')
    And method post
    Then status 201
    # Create workflow
    * json doc = read('classpath:com/sap/cx/swell/apitest/Workflow.json')
    Given url 'http://localhost:8080/workflows/'
    When request doc
    And method post
    Then status 201
    And match response.id == '#present'
    * set doc.id = response.id
    And match response == doc
    # Read workflow
    When path doc.id
    And method get
    Then status 200
    And match response == doc

  Scenario: Reject workflow with invalid workflow def
    * json doc = read('classpath:com/sap/cx/swell/apitest/Workflow.json')
    * set doc.workflowDefId = "doesnotexist"
    # Create workflow
    Given url 'http://localhost:8080/workflows/'
    When request doc
    And method post
    Then status 422