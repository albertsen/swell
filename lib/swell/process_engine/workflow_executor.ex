defmodule Swell.ProcessEngine.WorkflowExecutor do
  use GenServer
  alias Swell.ProcessEngine.StepExecutor
  alias Swell.ProcessDef.Step
  @me __MODULE__

  def start_link({workflow, parent}) do
    GenServer.start_link(@me, {workflow, parent}, name: @me)
  end

  def execute_with(document) do
    GenServer.cast(@me, {:execute_with, document})
  end

  def step_completed(result, step) do
    GenServer.cast(@me, {:step_completed, result, step})
  end

  @impl GenServer
  def init({workflow, parent}) do
    {:ok, {workflow, parent}}
  end

  @impl GenServer
  def handle_cast({:execute_with, document},  {%{start: step} = workflow, parent}) do
    execute_step(step, document)
    {:noreply, {workflow, parent}}
  end

  @impl GenServer
  def handle_cast(
        {:step_completed, {_result_code, document}, %Step{transitions: nil} = _step},
        {workflow, parent}
      ) do
    send(parent, {:done, document, workflow})
    {:noreply, {workflow, parent}}
  end

  @impl GenServer
  def handle_cast(
        {:step_completed, {result_code, document}, %Step{transitions: transitions} = step},
        {workflow, parent}
      ) do
    next_step_name = transitions[result_code]
    if !next_step_name, do: raise "No transition for result [#{result_code}] in step #{inspect(step)}"
    workflow[next_step_name]
    |> execute_step(document)

    {:noreply, {workflow, parent}}
  end

  defp execute_step(step, document) do
    StepExecutor.execute(step, document, &step_completed/2)
  end
end
