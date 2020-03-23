Feature: Workflow

  Background:
    * header Accept = 'application/json'
    * json workflowDef = read('classpath:com/sap/cx/swell/apitest/WorkflowDef.json')
    * json workflow = read('classpath:com/sap/cx/swell/apitest/Workflow.json')

  Scenario: Create & read workflow
    # Create Wrofklow def
    Given url 'http://localhost:8080/workflowdefs/'
    And request workflowDef
    And method post
    Then status 201
    # Create workflow
    Given url 'http://localhost:8080/workflows/'
    When request workflow
    And method post
    Then status 201
    And match response.id == '#present'
    * set workflow.id = response.id
    And match response == workflow
    # Read workflow
    When path workflow.id
    And method get
    Then status 200
    And match response == workflow

  Scenario: Reject workflow with invalid workflow def
    * set workflow.workflowDefId = "doesnotexist"
    # Create workflow
    Given url 'http://localhost:8080/workflows/'
    When request workflow
    And method post
    Then status 422