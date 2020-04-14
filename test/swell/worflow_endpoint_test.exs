defmodule Swell.Test.WorkflowServiceTest do
  use ExUnit.Case
  require Logger
  alias Swell.Rest.Client
  @url "http://localhost:8080"

  test "Workflow API" do
    %{"id" => workflow_def_id} =
      workflow_def =
      File.read!("test/data/workflow_def.json")
      |> Jason.decode!()

    workflow =
      File.read!("test/data/workflow.json")
      |> Jason.decode!()

    {status, doc} = Client.post("#{@url}/workflowdefs", workflow_def)
    assert status == :created
    assert doc == workflow_def

    {status, _} = Client.post("#{@url}/workflowdefs", workflow_def)
    assert status == :conflict

    {status, workflow_def_created} = Client.get("#{@url}/workflowdefs/#{workflow_def_id}")
    assert status == :ok
    assert workflow_def == workflow_def_created
    workflow_def = %{workflow_def | "description" => "Updated description"}

    {status, doc} = Client.post("#{@url}/workflows", workflow)
    assert status == :created
    assert Map.has_key?(doc, "id")
    assert !Map.has_key?(doc, "_id")
    workflow_id = doc["id"]
    workflow = Map.put(workflow, "id", workflow_id)
    assert doc == workflow

    {status, workflow_created} = Client.get("#{@url}/workflows/#{workflow_id}")
    assert status == :ok
    assert workflow == workflow_created

    {status, doc} = Client.put("#{@url}/workflowdefs/#{workflow_def_id}", workflow_def)
    assert status == :ok
    assert doc == workflow_def
    {status, worflow_def_updated} = Client.get("#{@url}/workflowdefs/#{workflow_def_id}")
    assert status == :ok
    assert workflow_def == worflow_def_updated

    {status, _} = Client.delete("#{@url}/workflowdefs/#{workflow_def_id}")
    assert status == :ok

    {status, _} = Client.get("#{@url}/workflowdefs/#{workflow_def_id}")
    assert status == :not_found

    {status, _} = Client.put("#{@url}/workflowdefs/#{workflow_def_id}", workflow_def)
    assert status == :not_found

    :timer.sleep(5000)
  end

  test "Workflow definition Schema Validation" do
    {status, body} = Client.post("#{@url}/workflowdefs", %{"invalid" => "document"})

    assert status == :unprocessable_entity

    assert body == %{
             "errors" => [
               %{
                 "path" => "#",
                 "reason" => "Required properties id, actionHandlers, steps were not present."
               }
             ]
           }
  end

  test "Workflow Schema Validation" do
    {status, res} = Client.post("#{@url}/workflows", %{invalid: "document"})
    assert status == :unprocessable_entity

    assert res == %{
             "errors" => [
               %{
                 "path" => "#",
                 "reason" => "Required properties workflowDefId, document were not present."
               }
             ]
           }
  end

  test "Workflow with invalid workflow def ID" do
    workflow =
      File.read!("test/data/workflow.json")
      |> Jason.decode!()
      |> Map.put("workflowDefId", "doesnotexists")

    {status, _} = Client.post("#{@url}/workflows", workflow)
    assert status == :unprocessable_entity
  end
end
