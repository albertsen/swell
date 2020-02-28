defmodule Swell.Test.WorkflowServiceTest do
  use ExUnit.Case
  require Logger
  alias Swell.Rest.Client
  @url "http://localhost:8080/workflowdefs"

  test "Worfklow definition CRUD" do
    json = File.read!("test/data/workflowdefs/fulfilorder.json")
    workflow_def = Jason.decode!(json, keys: :atoms)
    {status, doc} = Client.post(@url, workflow_def)
    assert status == :created
    assert doc == workflow_def
    {status, _} = Client.post(@url, workflow_def)
    assert status == :conflict
    {status, workflow_def_created} = Client.get("#{@url}/#{workflow_def.id}")
    assert status == :ok
    assert workflow_def == workflow_def_created
    workflow_def = %{workflow_def | description: "Updated description"}
    {status, doc} = Client.put("#{@url}/#{workflow_def.id}", workflow_def)
    assert status == :ok
    assert doc == workflow_def
    {status, worflow_def_updated} = Client.get("#{@url}/#{workflow_def.id}")
    assert status == :ok
    assert workflow_def == worflow_def_updated
    {status, _} = Client.delete("#{@url}/#{workflow_def.id}")
    assert status == :ok
    {status, _} = Client.get("#{@url}/#{workflow_def.id}")
    assert status == :not_found
    {status, _} = Client.put("#{@url}/#{workflow_def.id}", workflow_def)
    assert status == :not_found
  end

  test "Workflow definition Schema Validation" do
    {status, res} = Client.post(@url, %{invalid: "document"})
    assert status == :unprocessable_entity
    assert res == %{errors: [%{path: "#", reason: "Required properties id, actionHandlers, steps were not present."}]}
  end
end
