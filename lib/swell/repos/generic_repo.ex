defmodule Swell.Repos.GenRepo do
  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      use GenServer
      require Logger
      @db Keyword.get(Application.get_env(:swell, :db), :name)
      @me __MODULE__

      def create(workflow_def) do
        GenServer.call(@me, {:create, workflow_def})
      end

      def find_by_id(id) do
        GenServer.call(@me, {:find_by_id, id})
      end

      def update(id, doc) do
        GenServer.call(@me, {:update, id, doc})
      end

      def delete(id) when is_binary(id) do
        GenServer.call(@me, {:delete, id})
      end

      def start_link(collection) do
        GenServer.start_link(@me, collection, name: @me)
      end

      @impl GenServer
      def init(collection) do
        {:ok, collection}
      end

      @impl GenServer
      def handle_call({:create, workflow_def}, _from, collection) when is_map(workflow_def) do
        workflow_def = Map.put_new(workflow_def, :_id, workflow_def[:id])
        res = Mongo.insert_one(@db, collection, workflow_def)

        reply =
          case res do
            {:ok, %Mongo.InsertOneResult{inserted_id: inserted_id}} ->
              workflow_def =
                workflow_def
                |> Map.delete(:_id)
                |> Map.put(:id, inserted_id)

              {:created, workflow_def}

            {:error, %Mongo.WriteError{write_errors: [%{"code" => 11000}]}} ->
              {:conflict, %{message: "A document already exists with ID: #{workflow_def.id}"}}

            {:error, error} ->
              Logger.error("Error creating document: #{inspect(error)}")
              {:internal_server_errror, %{message: "An error occurred"}}
          end

        {:reply, reply, collection}
      end

      @impl GenServer
      def handle_call({:find_by_id, id}, _from, collection) when is_binary(id) do
        workflow_def = Mongo.find_one(@db, collection, %{_id: id})

        reply =
          if workflow_def do
            {:ok,
             workflow_def
             |> Map.delete("_id")
             |> Swell.Map.Helpers.atomize_keys()}
          else
            {:not_found, %{message: "No document found with ID: #{id}"}}
          end

        {:reply, reply, collection}
      end

      @impl GenServer
      def handle_call({:update, id, doc}, _from, collection) when is_binary(id) and is_map(doc) do
        if !Map.has_key?(doc, :id), do: raise("Document doesn't have an ID")

        if doc.id != id,
          do: raise("ID of document [#{doc.id}] and ID provided in resource [#{id}] don't match")

        res = Mongo.replace_one(@db, collection, %{_id: id}, doc)

        reply =
          case res do
            {:ok, %Mongo.UpdateResult{matched_count: 0}} ->
              {:not_found, %{message: "No document found with ID: #{id}"}}

            {:ok, _} ->
              {:ok, doc}

            {:error, error} ->
              Logger.error("Error updating WorkflowDef: #{inspect(error)}")
              {:internal_server_errror, %{message: "An error occurred"}}
          end

        {:reply, reply, collection}
      end

      @impl GenServer
      def handle_call({:delete, id}, _from, collection) when is_binary(id) do
        res = Mongo.delete_one(@db, collection, %{_id: id})

        reply =
          case res do
            {:ok, _} ->
              {:ok, nil}

            {:error, error} ->
              Logger.error("Error deleting WorkflowDef: #{inspect(error)}")
              {:internal_server_errror, %{message: "An error occurred"}}
          end

        {:reply, reply, collection}
      end
    end
  end
end
