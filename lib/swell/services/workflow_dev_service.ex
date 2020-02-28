defmodule Swell.Services.WorkflowDefService do
  alias Swell.Repos.WorkflowDefRepo

  def get_with_id(id) do
    WorkflowDefRepo.find_by_id(id)
  end
end
