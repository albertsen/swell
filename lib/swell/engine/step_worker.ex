defmodule Swell.Engine.StepWorker do

  use GenServer
  alias Swell.Engine.StepExecutor
  require Logger

  @me __MODULE__
  @steps :steps
  @results :results
  @errors :errors

  def start_link(_) do
    GenServer.start_link(@me, nil)
  end

  @impl GenServer
  def init(_) do
    send(self(), :execute_step)
    {:ok, nil}
  end

  @impl GenServer
  def handle_info(:execute_step, _) do
    Swell.Queue.dequeue(@steps)
    |> handle_queue_item()
    send(self(), :execute_step)
    {:noreply, nil}
  end

  defp handle_queue_item({:value, {workflow, step_name, document}}) do
    try do
      StepExecutor.execute_step(workflow, step_name, document)
    rescue
      e in _ ->
        {:error, document, step_name, e}
    end
    |> enqueue_next(workflow)
  end

  defp handle_queue_item(:empty), do: nil

  defp enqueue_next({result_code, document, nil}, _workflow) do
    Swell.Queue.enqueue(@results, {result_code, document})
  end

  defp enqueue_next({_result_code, document, next_step_name}, workflow) do
    Swell.Queue.enqueue(@steps, {workflow, next_step_name, document})
  end

  defp enqueue_next({:error, document, step_name, error}, workflow) do
    Swell.Queue.enqueue(@errors, {workflow, step_name, document, error})
  end


end
