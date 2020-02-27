defmodule Swell.DB.Repo.WorkflowDefRepo do
  require Logger
  @db Keyword.get(Application.get_env(:swell, :db), :name)
  @collection "workflow_defs"

  def create(workflow_def) when is_map(workflow_def) do
    workflow_def = Map.put_new(workflow_def, :_id, workflow_def[:id])
    res = Mongo.insert_one(@db, @collection, workflow_def)

    case res do
      {:ok, %Mongo.InsertOneResult{inserted_id: inserted_id}} ->
        workflow_def =
          workflow_def
          |> Map.delete(:_id)
          |> Map.put(:id, inserted_id)

        {:created, workflow_def}

      {:error, %Mongo.WriteError{write_errors: [%{"code" => 11000}]}} ->
        {:conflict, %{message: "A document already exists with ID: #{workflow_def.id}"}}

      {:error, error} ->
        Logger.error("Error creating document: #{inspect(error)}")
        {:internal_server_errror, %{message: "An error occurred"}}
    end
  end

  def find_by_id(id) when is_binary(id) do
    workflow_def = Mongo.find_one(@db, @collection, %{_id: id})

    if workflow_def do
      {:ok,
       workflow_def
       |> Map.delete("_id")
       |> Swell.Map.Helpers.atomize_keys()}
    else
      {:not_found, %{message: "No document found with ID: #{id}"}}
    end
  end

  def update(id, doc) when is_binary(id) and is_map(doc) do
    if !Map.has_key?(doc, :id), do: raise("Document doesn't have an ID")

    if doc.id != id,
      do: raise("ID of document [#{doc.id}] and ID provided in resource [#{id}] don't match")

    res = Mongo.replace_one(@db, @collection, %{_id: id}, doc)

    case res do
      {:ok, %Mongo.UpdateResult{matched_count: 0}} ->
        {:not_found, %{message: "No document found with ID: #{id}"}}

      {:ok, _} ->
        {:ok, doc}

      {:error, error} ->
        Logger.error("Error updating WorkflowDef: #{inspect(error)}")
        {:internal_server_errror, %{message: "An error occurred"}}
    end
  end

  def delete(id) when is_binary(id) do
    res = Mongo.delete_one(@db, @collection, %{_id: id})

    case res do
      {:ok, _} ->
        {:ok, nil}

      {:error, error} ->
        Logger.error("Error deleting WorkflowDef: #{inspect(error)}")
        {:internal_server_errror, %{message: "An error occurred"}}
    end
  end
end
