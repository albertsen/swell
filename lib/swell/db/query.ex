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
    {:ok, query}
  end

  @impl GenServer
  def handle_call({:execute, params, opts}, _from, query) do
    params = Enum.map(params, &to_sql_value(&1))
    res = Connection.execute(query, params, opts)
    {:reply, res, query}
  end

  defp to_sql_value(value) when is_atom(value), do: to_string(value)
  defp to_sql_value(value), do: value


end
