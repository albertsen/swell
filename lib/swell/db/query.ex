defmodule Swell.DB.Query do
  use GenServer
  alias Swell.DB.Connection
  require Logger
  @me __MODULE__

  def start_link({name, statement}) do
    GenServer.start_link(@me, {name, statement}, name: name)
  end

  def execute(name, params, opts \\ []) do
    GenServer.call(name, {:execute, params, opts})
  end

  @impl GenServer
  def init({name, statement}) when is_atom(name) do
    init({to_string(name), statement})
  end

  def init({name, statement}) when is_binary(name) and is_binary(statement) do
    query = Connection.prepare(name, statement)
    Logger.debug("Prepared query: #{inspect(query)}")
    {:ok, query}
  end

  @impl GenServer
  def handle_call({:execute, params, opts}, _from, query) do
    Logger.debug("Executing query: #{inspect(query)} - with params #{inspect(params)}")
    res = Connection.execute(query, params, opts)
    {:reply, res, query}
  end
end
