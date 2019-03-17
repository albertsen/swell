defmodule Swell.ProcessEngine.ActionExecutor do
  use GenServer
  @me __MODULE__

  def start_link(actions) do
    GenServer.start_link(@me, actions, name: @me)
  end

  def execute(action_name, document) do
    GenServer.call(@me, {:execute_action, action_name, document})
  end

  @impl GenServer
  def init(actions) do
    {:ok, actions}
  end

  @impl GenServer
  def handle_call({:execute_action, action_name, document}, _from, actions) do
    fun = actions[action_name]
    result = fun.(document)
    {:reply, result, actions}
  end
end
