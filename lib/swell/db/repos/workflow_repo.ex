defmodule Swell.DB.Repos.WorkflowRepo do
  alias Swell.Workflow.State.Workflow
  require Logger

  def save(workflow) do
    workflow = Workflow.touch(workflow)
    Logger.debug(fn -> inspect(workflow) end)
    Swell.DB.Manager.query(
      """
        INSERT INTO workflows
          (id, definition, document_id, document, step,
          waiting_for, status, result, error, time_created, time_updated)
        VALUES
          ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
        ON CONFLICT (id)
        DO UPDATE SET
          definition = $2,
          document_id = $3,
          document = $4,
          step = $5,
          waiting_for = $6,
          status = $7,
          result = $8,
          error = $9,
          time_updated = $11
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
        to_sql_value(workflow.error),
        to_sql_value(workflow.time_created),
        to_sql_value(workflow.time_updated)
      ]
    )
    workflow
  end

  defp to_sql_value(value) when is_atom(value), do: to_string(value)
  defp to_sql_value(value), do: value

end
