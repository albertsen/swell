defmodule Swell.Services.WorkflowService do
  alias Swell.Repos.WorkflowRepo
  alias Swell.Services.WorkflowDefService
  alias Swell.Messaging.Publishers.ActionPublisher
  require Logger

  def get_with_id(id) do
    WorkflowRepo.find_by_id(id)
  end

  def create(workflow) do
    {res, _workflow_def} = WorkflowDefService.get_with_id(workflow.workflowDefId)

    if res == :not_found do
      {:unprocessable_entity, "No workflow def found with ID '#{workflow.workflowDefId}'"}
    else
      WorkflowRepo.create(workflow)
      |> publish_workflow()
    end
  end

  defp publish_workflow(create_result = {:created, doc}) do
    ActionPublisher.publish(doc)
    create_result
  end

  defp publish_workflow(create_result), do: create_result
end
