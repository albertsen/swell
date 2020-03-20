defmodule Swell.Test.WorkflowServiceTest do
  use ExUnit.Case
  require Logger
  alias Swell.Rest.Client
  @url "http://localhost:8080"

  test "Worfklow definition CRUD" do
    json = File.read!("test/data/workflow_def.json")
    workflow_def = Jason.decode!(json, keys: :atoms)
    {status, doc} = Client.post("#{@url}/workflowdefs", workflow_def)
    assert status == :created
    assert doc == workflow_def
    {status, _} = Client.post("#{@url}/workflowdefs", workflow_def)
    assert status == :conflict
    {status, workflow_def_created} = Client.get("#{@url}/workflowdefs/#{workflow_def.id}")
    assert status == :ok
    assert workflow_def == workflow_def_created
    workflow_def = %{workflow_def | description: "Updated description"}
    {status, doc} = Client.put("#{@url}/workflowdefs/#{workflow_def.id}", workflow_def)
    assert status == :ok
    assert doc == workflow_def
    {status, worflow_def_updated} = Client.get("#{@url}/workflowdefs/#{workflow_def.id}")
    assert status == :ok
    assert workflow_def == worflow_def_updated
    {status, _} = Client.delete("#{@url}/workflowdefs/#{workflow_def.id}")
    assert status == :ok
    {status, _} = Client.get("#{@url}/workflowdefs/#{workflow_def.id}")
    assert status == :not_found
    {status, _} = Client.put("#{@url}/workflowdefs/#{workflow_def.id}", workflow_def)
    assert status == :not_found
  end

  test "Workflow definition Schema Validation" do
    {status, res} = Client.post("#{@url}/workflowdefs", %{invalid: "document"})
    assert status == :unprocessable_entity
    assert res == %{errors: [%{path: "#", reason: "Required properties id, actionHandlers, steps were not present."}]}
  end

  test "Worfklow create & read" do
    json = File.read!("test/data/workflow_def.json")
    workflow_def = Jason.decode!(json, keys: :atoms)
    {status, _} = Client.post("#{@url}/workflowdefs", workflow_def)
    assert Enum.member?([:created, :conflict], status)
    json = File.read!("test/data/workflow.json")
    workflow = Jason.decode!(json, keys: :atoms)
    {status, doc} = Client.post("#{@url}/workflows", workflow)
    assert status == :created
    assert Map.has_key?(doc, :id)
    assert !Map.has_key?(doc, :_id)
    workflow = Map.put(workflow, :id, doc.id)
    assert doc == workflow
    {status, _} = Client.post("#{@url}/workflows", workflow)
    assert status == :conflict
    {status, workflow_created} = Client.get("#{@url}/workflows/#{workflow.id}")
    assert status == :ok
    assert workflow == workflow_created
  end

  test "Workflow Schema Validation" do
    {status, res} = Client.post("#{@url}/workflows", %{invalid: "document"})
    assert status == :unprocessable_entity
    assert res == %{errors: [%{path: "#", reason: "Required properties workflowDefId, document were not present."}]}
  end

  test "Workflow with invalid workflow def ID" do
    json = File.read!("test/data/workflow.json")
    workflow =
      Jason.decode!(json, keys: :atoms)
      |> Map.put(:workflowDefId, "doesnotexists")
    {status, _} = Client.post("#{@url}/workflows", workflow)
    assert status == :unprocessable_entity
  end


end
