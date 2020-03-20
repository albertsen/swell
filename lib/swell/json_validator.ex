defmodule Swell.JSON.Validator do
  @me __MODULE__
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start(@me, nil, name: @me)
  end

  def validate(doc, schema_name) do
    GenServer.call(@me, {:validate, doc, schema_name})
  end

  @impl GenServer
  def init(_) do
    schemas =
      Application.get_env(:swell, :schemas)
      |> Enum.map(fn {name, file} ->
        {
          name,
          load_schema(file)
        }
      end)
      |> Enum.into(%{})

    {:ok, schemas}
  end

  defp load_schema(file) do
    File.read!(file)
    |> Jason.decode!()
  end

  @impl GenServer
  def handle_call({:validate, doc, schema_name}, _from, schemas) do
    res =
      schemas[schema_name]
      |> (fn schema ->
            unless schema, do: raise(ArgumentError, message: "No such schema: #{schema_name}")
            schema
          end).()
      |> ExJsonSchema.Validator.validate(doc)

    {:reply, res, schemas}
  end
end
