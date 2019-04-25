defmodule Swell.DB.Repos.WorkflowRepo do
  use GenServer
  alias Swell.DB.Query
  alias Swell.Workflow.State.Workflow
  require Logger
  @save_workflow :save_workflow
  @me __MODULE__

  def start_link(_) do
    GenServer.start_link(@me, nil, name: @me)
  end

  def save(workflow) do
    GenServer.call(@me, {:save, workflow})
  end

  @impl GenServer
  def init(_) do
    send(self(), :init_queries)
    {:ok, nil}
  end

  @impl GenServer
  def handle_call({:save, workflow}, _from, _state) do
    workflow = Workflow.touch(workflow)
    Query.execute(
      @save_workflow,
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

    {:reply, workflow, nil}
  end

  defp to_sql_value(value) when is_atom(value), do: to_string(value)
  defp to_sql_value(value), do: value

  @impl GenServer
  def handle_info(:init_queries, _) do
    {:ok, _pid} =
      Query.start_link({
        @save_workflow,
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
        """
      })

    {:noreply, nil}
  end
end
