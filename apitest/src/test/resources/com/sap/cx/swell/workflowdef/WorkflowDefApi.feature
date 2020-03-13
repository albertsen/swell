Feature: Workflow Def CRUD

  Background:
    * header Accept = 'application/json'
    * json doc = read('classpath:com/sap/cx/swell/workflowdef/WorkflowDef.json')

  Scenario: CRUD
    # Create
    Given url 'http://localhost:8080/workflowdefs/'
    And request doc
    And method post
    Then status 201
    And match response == doc
    # Read
    When path doc.id
    And method get
    Then status 200
    And match response == doc
    # Update
    * set doc.description = "Updated description"
    When path doc.id
    And request doc
    And method put
    Then status 200
    And match response == doc
    # Delete
    When path doc.id
    And method delete
    Then status 200
    When path doc.id
    And method get
    Then status 404