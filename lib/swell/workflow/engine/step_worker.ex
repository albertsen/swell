defmodule Swell.Workflow.Engine.StepWorker do

  use GenServer
  alias Swell.Workflow.Engine.StepExecutor
  use Swell.Queue.Consumer
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
    channel = Swell.Queue.Manager.open_channel()
    Swell.Queue.Manager.consume(channel, @steps)
    {:ok, channel}
  end

  def consume_message({workflow, step_name, document}, channel) do
    try do
      StepExecutor.execute_step(workflow, step_name, document)
    rescue
      e in _ ->
        enqueue_next({:error, document, step_name, e}, workflow, channel)
    end
    |> enqueue_next(workflow, channel)
  end

  defp enqueue_next({result_code, document, nil}, _workflow, channel) do
    Swell.Queue.Manager.publish(channel, @results, {result_code, document})
  end

  defp enqueue_next({_result_code, document, next_step_name}, workflow, channel) do
    Swell.Queue.Manager.publish(channel, @steps, {workflow, next_step_name, document})
  end

  defp enqueue_next({:error, document, step_name, error}, workflow, channel) do
    Swell.Queue.Manager.publish(channel, @errors, {workflow, step_name, document, error})
  end


end
