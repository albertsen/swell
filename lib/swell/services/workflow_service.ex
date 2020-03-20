defmodule Swell.Services.WorkflowService do
  alias Swell.Repos.WorkflowRepo

  def get_with_id(id) do
    WorkflowRepo.find_by_id(id)
  end

  def create(workflow_def) do
    WorkflowRepo.create(workflow_def)
  end

end
