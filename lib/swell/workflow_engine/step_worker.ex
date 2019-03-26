defmodule Swell.WorkflowEngine.StepWorker do

  use GenServer
  alias Swell.WorkflowEngine.StepExecutor

  @me __MODULE__
  @steps :steps
  @results :results

  def start_link(_) do
    GenServer.start_link(@me, nil)
  end

  @impl GenServer
  def init(_) do
    Process.send_after(self(), :execute_step, 0)
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
    StepExecutor.execute_step(workflow, step_name, document)
    |> enqueue_next_step(workflow)
  end

  defp handle_queue_item(:empty), do: nil

  defp enqueue_next_step({result_code, document, nil}, _workflow) do
    Swell.Queue.enqueue(
      @results,
      {result_code, document}
    )
  end

  defp enqueue_next_step({_result_code, document, next_step_name}, workflow) do
    Swell.Queue.enqueue(
      :steps,
      {workflow, next_step_name, document}
    )
  end

end
