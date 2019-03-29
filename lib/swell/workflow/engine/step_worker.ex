defmodule Swell.Workflow.Engine.StepWorker do

  use GenServer
  alias Swell.Workflow.Engine.StepExecutor
  alias Swell.AmqpManager
  require Logger

  @me __MODULE__
  @steps "steps"
  @results "results"
  @errors "errors"

  def start_link(_) do
    GenServer.start_link(@me, nil)
  end

  @impl GenServer
  def init(_) do
    channel = AmqpManager.open_channel([@steps, @results, @errors])
    AmqpManager.consume(channel, @steps)
    {:ok, channel}
  end

  @impl GenServer
  def handle_info({:basic_deliver, payload, _meta}, channel) do
    :erlang.binary_to_term(payload)
    |> execute_step()
    {:noreply, channel}
  end

  def handle_info({:basic_consume_ok, %{consumer_tag: consumer_tag}}, chan) do
    {:noreply, chan}
  end

  def handle_info({:basic_cancel, %{consumer_tag: consumer_tag}}, chan) do
    {:stop, :normal, chan}
  end

  def handle_info({:basic_cancel_ok, %{consumer_tag: consumer_tag}}, chan) do
    {:noreply, chan}
  end

  defp execute_step({workflow, step_name, document}) do
    try do
      StepExecutor.execute_step(workflow, step_name, document)
    rescue
      e in _ ->
        {:error, document, step_name, e}
    end
    |> enqueue_next(workflow)
  end


  defp enqueue_next({result_code, document, nil}, _workflow) do
    # Swell.Queue.enqueue(@results, {result_code, document})
  end

  defp enqueue_next({_result_code, document, next_step_name}, workflow) do
    # Swell.Queue.enqueue(@steps, {workflow, next_step_name, document})
  end

  defp enqueue_next({:error, document, step_name, error}, workflow) do
    # Swell.Queue.enqueue(@errors, {workflow, step_name, document, error})
  end


end
