defmodule Swell.JSON.Validator do
  @me __MODULE__
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start(@me, nil, name: @me)
  end

  def validate(doc, schema_name) when is_binary(schema_name) do
    GenServer.call(@me, {:validate, doc, schema_name})
  end

  def resolve_schema(path) when is_binary(path) do
    schema_dir = Application.get_env(:swell, :schema_dir)

    Path.join(schema_dir, path)
    |> load_schema()
  end

  @impl GenServer
  def init(_) do
    schema_dir = Application.get_env(:swell, :schema_dir)

    schemas =
      Path.wildcard(Path.join(schema_dir, "*.schema.json"))
      |> Enum.map(fn file ->
        {
          Path.basename(file, ".schema.json"),
          file
        }
      end)
      |> Enum.map(fn {name, file} ->
        Logger.info("Loading schema '#{name}' from file '#{file}'")

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
            unless schema do
              msg = "No such schema: #{schema_name}"
              Logger.error(msg)
              raise(ArgumentError, message: msg)
            end

            schema
          end).()
      |> ExJsonSchema.Validator.validate(doc)

    {:reply, res, schemas}
  end
end
