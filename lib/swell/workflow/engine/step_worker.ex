defmodule Swell.Workflow.Engine.StepWorker do

  use GenServer
  use Swell.Queue.Consumer
  alias Swell.Workflow.Engine.StepExecutor
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

  def consume_message({workflow, step_name, document} = message, channel) do
    Logger.debug("Consuming message: #{inspect(message)} - #{inspect(self())}")
    try do
      StepExecutor.execute_step(workflow, step_name, document)
    rescue
      e in _ ->
        Logger.error(inspect(e))
        {:error, document, step_name, e}
    end
    |> enqueue_next(workflow, channel)
  end

  defp enqueue_next({result_code, document, nil} = message, _workflow, channel) do
    Logger.debug("RESULT: #{inspect(message)}")
    Swell.Queue.Manager.publish(channel, @results, {result_code, document})
  end

  defp enqueue_next({_result_code, document, next_step_name} = message, workflow, channel) do
    Logger.debug("NEXT STEP: #{inspect(message)}")
    Swell.Queue.Manager.publish(channel, @steps, {workflow, next_step_name, document})
  end

  defp enqueue_next({:error, document, step_name, error} = message, workflow, channel) do
    Logger.debug("ERROR: #{inspect(message)}")
    Swell.Queue.Manager.publish(channel, @errors, {workflow, step_name, document, error})
  end


end
