defmodule Swell.Workflow.Engine.Workers.PersistenceWorker do
  use GenServer
  use Swell.Queue.Consumer

  def start_link(queue) do
    GenServer.start_link(__MODULE__, queue)
  end

  @impl GenServer
  def init({binding_keys, queue}) do
    init_consumer(binding_keys, queue)
  end

  def consume({_routing_key, workflow}, _channel) do
    save_workflow(workflow)
  end

  defp save_workflow(workflow) do
    Swell.DB.Manager.query(
      """
        INSERT INTO workflows
          (id, definition, document_id, document, step,
          waiting_for, status, result, error)
        VALUES
          ($1, $2, $3, $4, $5, $6, $7, $8, $9)
        ON CONFLICT (id)
        DO UPDATE SET
          time_updated = CURRENT_TIMESTAMP,
          definition = $2,
          document_id = $3,
          document = $4,
          step = $5,
          waiting_for = $6,
          status = $7,
          result = $8,
          error = $9
      """,
      [
        UUID.string_to_binary!(workflow.id),
        to_sql_value(workflow.definition),
        to_sql_value(workflow.document.id),
        to_sql_value(workflow.document),
        to_sql_value(workflow.step),
        to_sql_value(workflow.waiting_for),
        to_sql_value(workflow.status),
        to_sql_value(workflow.result),
        to_sql_value(workflow.error)
      ]
    )

    :ok
  end

  defp to_sql_value(value) when is_atom(value), do: to_string(value)
  defp to_sql_value(value), do: value

end
