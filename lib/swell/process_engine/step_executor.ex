defmodule Swell.ProcessEngine.StepExecutor do
  use GenServer
  alias Swell.ProcessEngine.ActionExecutor
  alias Swell.ProcessDef.Step
  @me __MODULE__

  def start_link(_) do
    GenServer.start_link(@me, nil, name: @me)
  end

  def execute(step, document, callback) do
    GenServer.cast(@me, {:execute_step, step, document, callback})
  end

  @impl GenServer
  def init(_) do
    {:ok, nil}
  end

  @impl GenServer
  def handle_cast({:execute_step, %Step{action: action} = step, document, callback}, _state) do
    ActionExecutor.execute(action, document)
    |> callback.(step)
    {:noreply, nil}
  end

end
