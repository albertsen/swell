defmodule Swell.Repos.GenRepo do
  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      use GenServer
      require Logger
      @db Keyword.get(Application.get_env(:swell, :db), :name)
      @me __MODULE__

      def create(doc) when is_map(doc) do
        GenServer.call(@me, {:create, doc})
      end

      def find_by_id(id) when is_binary(id) do
        GenServer.call(@me, {:find_by_id, id})
      end

      def update(id, %{id: _id} = doc) when is_binary(id) do
        GenServer.call(@me, {:update, id, doc})
      end

      def delete(id) when is_binary(id) do
        GenServer.call(@me, {:delete, id})
      end

      def start_link(collection) when is_binary(collection) do
        GenServer.start_link(@me, collection, name: @me)
      end

      @impl GenServer
      def init(collection) when is_binary(collection) do
        {:ok, collection}
      end

      @impl GenServer
      def handle_call({:create, doc}, _from, collection) when is_map(doc) do
        doc = Map.put(doc, :_id, Map.get_lazy(doc, :id, fn -> UUID.uuid4() end))
        res = Mongo.insert_one(@db, collection, doc)

        reply =
          case res do
            {:ok, %Mongo.InsertOneResult{inserted_id: inserted_id}} ->
              doc = convert_doc(doc, inserted_id)
              {:created, doc}

            {:error, %Mongo.WriteError{write_errors: [%{"code" => 11000}]}} ->
              {:conflict, %{message: "A document already exists with ID: #{doc.id}"}}

            {:error, error} ->
              Logger.error("Error creating document: #{inspect(error)}")
              {:internal_server_error, %{message: "An error occurred"}}
          end

        {:reply, reply, collection}
      end

      @impl GenServer
      def handle_call({:find_by_id, id}, _from, collection) when is_binary(id) do
        doc = Mongo.find_one(@db, collection, %{_id: id})

        reply =
          if doc do
            {:ok, convert_doc(doc, id)}
          else
            {:not_found, %{message: "No document found with ID: #{id}"}}
          end

        {:reply, reply, collection}
      end

      @impl GenServer
      def handle_call({:update, id, %{id: _id} = doc}, _from, collection) when is_binary(id) do
        if doc.id != id,
          do: raise("ID of document [#{doc.id}] and ID provided in resource [#{id}] don't match")

        update_doc = doc
          |> Map.put(:_id, id)
          |> Map.delete(:id)
        res = Mongo.replace_one(@db, collection, %{_id: id}, update_doc )

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

      defp convert_doc(doc, id) do
        doc
        |> Swell.Map.Helpers.atomize_keys()
        |> Map.put(:id, id)
        |> Map.delete(:_id)
      end

    end
  end
end