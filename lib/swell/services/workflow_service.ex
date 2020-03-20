defmodule Swell.Services.WorkflowService do
  alias Swell.Repos.WorkflowRepo
  alias Swell.Services.WorkflowDefService
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
    end
  end

end
