defmodule Swell.Workflow.Engine.WorkflowExecutor do
  use GenServer
  alias Swell.Workflow.Engine.StepWorkerSupervisor
  require Logger
  @steps "steps"
  @me __MODULE__

  def start_link(worker_count) do
    GenServer.start_link(@me, worker_count, name: @me)
  end

  def execute(workflow, document) do
    GenServer.cast(@me, {:execute, workflow, document})
  end

  @impl GenServer
  def init(worker_count) do
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Queue.declare(channel, @steps, durable: true)
    send(self(), :start_workers)
    {:ok, {worker_count, channel}}
  end

  @impl GenServer
  def handle_cast({:execute, workflow, document}, {worker_count, channel}) do
    payload = :erlang.term_to_binary({workflow, :start, document})
    AMQP.Basic.publish(channel, "", @steps, payload, persistent: true)
    {:noreply, {worker_count, channel}}
  end

  @impl GenServer
  def handle_info(:start_workers, {worker_count, channel}) do
    StepWorkerSupervisor.start_workers(worker_count)
    {:noreply, {worker_count, channel}}
  end
end
