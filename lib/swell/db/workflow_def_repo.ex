defmodule Swell.DB.Repo.WorkflowDefRepo do
  require Logger
  @db :swell
  @collection "workflow_defs"

  def create(%{id: id} = workflow_def) when is_binary(id) do
    workflow_def = Map.put(workflow_def, :_id, id)
    res = Mongo.insert_one(@db, @collection, workflow_def)

    case res do
      {:ok, _} ->
        {:created, "Document created with ID: #{id}"}

      {:error, %Mongo.WriteError{write_errors: [%{"code" => 11000}]}} ->
        {:conflict, "Conflict - Document already exists with ID: #{id}"}

      {:error, error} ->
        Logger.error("Error creating document: #{inspect(error)}")
        {:error, "An error occurred"}
    end
  end

  def find_by_id(id) when is_binary(id) do
    workflow_def = Mongo.find_one(@db, @collection, %{_id: id})

    case workflow_def do
      nil ->
        {:not_found, "No document found with ID: #{id}"}

      _ ->
        workflow_def =
          workflow_def
          |> Map.delete("_id")
          |> Swell.Map.Helpers.atomize_keys()

        {:ok, workflow_def}
    end
  end

  def update(id, doc) when is_binary(id) and is_map(doc) do
    if !Map.has_key?(doc, :id), do: raise("Document doesn't have an ID")

    if doc.id != id,
      do: raise("ID of document [#{doc.id}] and ID provided in resource [#{id}] don't match")

    res = Mongo.replace_one(@db, @collection, %{_id: id}, doc)

    case res do
      {:ok, %Mongo.UpdateResult{matched_count: 0}} ->
        {:not_found, "No document found with ID: #{id}"}

      {:ok, _} ->
        {:ok, "Document updated"}

      {:error, error} ->
        Logger.error("Error creating WorkflowDef: #{inspect(error)}")
        {:error, "An error occurred"}
    end
  end

  def delete(id) when is_binary(id) do
    Mongo.delete_one!(@db, @collection, %{_id: id})
    {:ok, "Document deleted"}
  end
end
