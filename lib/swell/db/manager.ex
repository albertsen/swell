defmodule Swell.DB.Manager do
  use GenServer
  require Logger
  @me __MODULE__

  def start_link(_) do
    GenServer.start_link(@me, nil, name: @me)
  end

  def query(statement, params, opts \\ []) do
    GenServer.call(@me, {:query, statement, params, opts})
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

end
