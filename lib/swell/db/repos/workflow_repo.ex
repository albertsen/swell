defmodule Swell.DB.Repos.WorkflowRepo do
  use GenServer
  alias Swell.DB.Query
  alias Swell.Workflow.State.Workflow
  alias Swell.DB.Repos.WorkflowRepo.WorkflowDefConverter
  alias Postgrex.Result
  require Logger
  @save_workflow :save_workflow
  @find_workflow_by_id :find_workflow_by_id
  @me __MODULE__

  def start_link(_) do
    GenServer.start_link(@me, nil, name: @me)
  end

  def save(%Workflow{} = workflow) do
    GenServer.call(@me, {:save, workflow})
  end

  def find_by_id(id) when is_binary(id) do
    GenServer.call(@me, {:find_by_id, id})
  end

  @impl GenServer
  def init(_) do
    send(self(), :init_queries)
    {:ok, nil}
  end

  @impl GenServer
  def handle_call({:find_by_id, id}, _from, _state) do
    workflow =
      Query.execute(
        @find_workflow_by_id,
        [UUID.string_to_binary!(id)]
      )
      |> convert_result()

    {:reply, workflow, nil}
  end

  @impl GenServer
  def handle_call({:save, workflow}, _from, _state) do
    workflow = Workflow.touch(workflow)

    Query.execute(
      @save_workflow,
      [
        UUID.string_to_binary!(workflow.id),
        workflow.definition,
        workflow.document["id"],
        workflow.document,
        workflow.step,
        workflow.waiting_for,
        workflow.status,
        workflow.result,
        workflow.error,
        workflow.time_created,
        workflow.time_updated
      ]
    )

    {:reply, workflow, nil}
  end

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

    {:ok, _pid} =
      Query.start_link({
        @find_workflow_by_id,
        """
          SELECT
            id,
            definition,
            document_id,
            document,
            step,
            waiting_for,
            status,
            result,
            error,
            time_created,
            time_updated
          FROM
            workflows
          WHERE
          id = $1
        """
      })

    {:noreply, nil}
  end

  defp convert_result(%Result{num_rows: 0}), do: nil

  defp convert_result(%Result{command: :select, columns: columns, rows: [row | _], num_rows: 1}) do
    Enum.zip(columns, row)
    |> Enum.map(fn {name, value} ->
      {String.to_atom(name), value}
    end)
    |> Enum.filter(fn {name, value} ->
      name != :document_id and value != nil
    end)
    |> Enum.reduce(
      %Workflow{},
      fn {name, value}, workflow ->
        Map.put(workflow, name, convert_value(name, value))
      end
    )
  end

  defp convert_value(:id, value),
    do: UUID.binary_to_string!(value)

  defp convert_value(:definition, value), do: WorkflowDefConverter.convert(value)

  defp convert_value(_name, ""), do: nil

  defp convert_value(_name, value), do: value
end

defmodule Swell.DB.Repos.WorkflowRepo.WorkflowDefConverter do
  alias Swell.Workflow.Definition.WorkflowDef
  alias Swell.Workflow.Definition.StepDef
  alias Swell.Workflow.Definition.FunctionActionDef

  def convert(map) do
    %WorkflowDef{
      id: map["id"],
      steps: convert_steps(map["steps"])
    }
  end

  def convert_steps(map) do
    Map.keys(map)
    |> Enum.reduce(
      %{},
      fn key, steps ->
        Map.put(
          steps,
          key,
          convert_step(map[key])
        )
      end
    )
  end

  def convert_step(step) when is_map(step) do
    action = step["action"]

    %StepDef{
      action: %FunctionActionDef{
        module: String.to_atom(action["module"]),
        function: String.to_atom(action["function"])
      },
      transitions: step["transitions"]
    }
  end

  def convert_step(step), do: step
end
