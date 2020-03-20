defmodule Swell.Services.WorkflowDefService do
  alias Swell.Repos.WorkflowDefRepo

  def get_with_id(id) do
    WorkflowDefRepo.find_by_id(id)
  end

  def create(workflow_def) do
    WorkflowDefRepo.create(workflow_def)
  end

  def update(id, workflow_def) do
    WorkflowDefRepo.update(id, workflow_def)
  end

  def delete(id) do
    WorkflowDefRepo.delete(id)
  end
  
end
