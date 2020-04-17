defmodule Swell.Repos.WorkflowRepo do
  use Swell.Repos.GenRepo, collection: "workflows"

  def update_document(workflow_id, doc)
      when is_binary(workflow_id) and is_map(doc) do
    res =
      Mongo.update_one(db(), collection(), %{"_id" => workflow_id}, %{
        "$set" => %{"document" => doc}
      })

    case res do
      {:ok, %Mongo.UpdateResult{matched_count: 0}} ->
        {:not_found, %{message: "No doc found with ID: #{workflow_id}"}}

      {:ok, _} ->
        {:ok, convert_doc(doc, workflow_id)}

      {:error, error} ->
        Logger.error("Error updating doc: #{inspect(error)}")
        {:internal_server_errror, %{message: "An error occurred"}}
    end
  end
end
