Feature: Workflow

  Background:
    * url 'http://localhost:8081/workflows/'
    * header Accept = 'application/json'
    * json doc = read('classpath:com/sap/cx/swell/workflow/Workflow.json')

  Scenario: Create & Read
    # Create Wrofklow def
    Given url 'http://localhost:8080/workflowdefs/'
    And request read('classpath:com/sap/cx/swell/workflowdef/WorkflowDef.json')
    And method post
    Then status 201
    # Create workflow
    Given url 'http://localhost:8081/workflows/'
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