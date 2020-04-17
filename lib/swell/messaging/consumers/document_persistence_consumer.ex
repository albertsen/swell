defmodule Swell.Messaging.Consumers.DocumentPersistenceConsumer do
  require Logger

  def consume(%{"workflowId" => workflow_id, "document" => doc} = msg)
      when is_binary(workflow_id) and is_map(doc) do
    Logger.debug("Persisting: #{inspect(msg)}")
    Swell.Repos.WorkflowRepo.update_document(workflow_id, doc)
  end
end
