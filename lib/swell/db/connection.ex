defmodule Swell.DB.Connection do
  use GenServer
  require Logger
  @me __MODULE__

  def start_link(_) do
    GenServer.start_link(@me, nil, name: @me)
  end

  def query(statement, params, opts \\ []) do
    GenServer.call(@me, {:query, statement, params, opts})
  end

  def prepare(name, statement, opts \\ []) do
    GenServer.call(@me, {:prepare, name, statement, opts})
  end

  def execute(query, params, opts \\ []) do
    GenServer.call(@me, {:execute, query, params, opts})
  end


  @impl GenServer
  def init(_) do
    [name: :"#{__MODULE__}_Poolboy"]
    |> Keyword.merge(Application.get_env(:swell, :db))
    |> Postgrex.start_link()
  end

  @impl GenServer
  def handle_call({:query, statement, params, opts}, _from, conn) do
    res = Postgrex.query!(conn, statement, params, opts)
    {:reply, res, conn}
  end

  @impl GenServer
  def handle_call({:prepare, name, statement, opts}, _from, conn) do
    res = Postgrex.prepare!(conn, name, statement, opts)
    {:reply, res, conn}
  end

  def handle_call({:execute, query, params, opts}, _from, conn) do
    res = Postgrex.execute!(conn, query, params, opts)
    {:reply, res, conn}
  end


end
