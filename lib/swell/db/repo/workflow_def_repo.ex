defmodule Swell.DB.Repo.WorkflowDefRepo do
  require Logger
  @db :swell
  @collection "workflow_defs"

  def create(%{"id" => id} = workflow_def) when is_binary(id) do
    workflow_def = Map.put(workflow_def, "_id", id)
    res = Mongo.insert_one(@db, @collection, workflow_def)

    case res do
      {:ok, _} ->
        {:created, "Workflow definition created with ID: #{id}"}

      {:error, %Mongo.WriteError{write_errors: [%{"code" => 11000}]}} ->
        {:conflict, "Conflict - workflow definition already exists with ID: #{id}"}

      {:error, error} ->
        Logger.error("Error creating WorkflowDef: #{inspect(error)}")
        {:error, "Unknown error"}
    end
  end

  def find_by_id(id) when is_binary(id) do
    workflow_def = Mongo.find_one(@db, @collection, %{_id: id})

    case workflow_def do
      nil ->
        {:not_found, nil}

      _ ->
        workflow_def = Map.delete(workflow_def, "_id")
        {:ok, workflow_def}
    end
  end

  def delete(id) when is_binary(id) do

  end
end
