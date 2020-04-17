defmodule Swell.Services.WorkflowService do
  alias Swell.Repos.WorkflowRepo
  alias Swell.Services.WorkflowDefService
  alias Swell.Messaging.Publishers.ActionPublisher
  require Logger

  def get_with_id(id) do
    WorkflowRepo.find_by_id(id)
  end

  def create(%{"workflowDefId" => workflowDefId} = workflow) do
    workflow_def_res = WorkflowDefService.get_with_id(workflowDefId)

    case workflow_def_res do
      {:ok, workflow_def} ->
        WorkflowRepo.create(workflow)
        |> handle_created_workflow(workflow_def)

      {:not_found, _} ->
        {:unprocessable_entity, "No workflow def found with ID '#{workflowDefId}'"}

      _ ->
        workflow_def_res
    end
  end

  def update_document(workflow_id, document) do
    WorkflowRepo.update_document(workflow_id, document)
  end

  defp handle_created_workflow({:created, workflow} = res, workflow_def) do
    :ok = publish_workflow(workflow, workflow_def)
    res
  end

  defp handle_created_workflow(res, _), do: res

  defp publish_workflow(workflow, workflow_def) do
    create_action(workflow, workflow_def, "start")
    |> ActionPublisher.publish()
  end

  defp create_action(
         %{"id" => workflowId, "document" => document} = _workflow,
         %{"actionHandlers" => action_handlers} = _workflow_def,
         step_name
       )
       when is_binary(step_name) do
    {:ok, action_handler} = Map.fetch(action_handlers, step_name)

    %{
      "workflowId" => workflowId,
      "stepName" => step_name,
      "handler" => action_handler,
      "document" => document
    }
  end
end
