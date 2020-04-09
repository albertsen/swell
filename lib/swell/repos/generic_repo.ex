defmodule Swell.Repos.GenRepo do
  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      use GenServer
      require Logger
      @db Keyword.fetch!(Application.get_env(:swell, :db), :name)
      @collection Keyword.fetch!(opts, :collection)
      @me __MODULE__

      def create(doc) when is_map(doc) do
        GenServer.call(@me, {:create, doc})
      end

      def find_by_id(id) when is_binary(id) do
        GenServer.call(@me, {:find_by_id, id})
      end

      def update(id, %{"id" => _id} = doc) when is_binary(id) do
        GenServer.call(@me, {:update, id, doc})
      end

      def delete(id) when is_binary(id) do
        GenServer.call(@me, {:delete, id})
      end

      def start_link(_) do
        GenServer.start_link(@me, nil, name: @me)
      end

      @impl GenServer
      def init(_) do
        {:ok, nil}
      end

      @impl GenServer
      def handle_call({:create, doc}, _from, _) when is_map(doc) do
        doc =
          doc
          |> Map.put("_id", Map.get_lazy(doc, "id", fn -> UUID.uuid4() end))
          |> Map.delete("id")

        res = Mongo.insert_one(@db, @collection, doc)

        reply =
          case res do
            {:ok, %Mongo.InsertOneResult{inserted_id: inserted_id}} ->
              doc = convert_doc(doc, inserted_id)
              {:created, doc}

            {:error, %Mongo.WriteError{write_errors: [%{"code" => 11000}]}} ->
              doc_id = doc["id"]
              {:conflict, %{message: "A document already exists with ID: #{doc_id}"}}

            {:error, error} ->
              Logger.error("Error creating document: #{inspect(error)}")
              {:internal_server_error, %{message: "An error occurred"}}
          end

        {:reply, reply, nil}
      end

      @impl GenServer
      def handle_call({:find_by_id, id}, _from, _) when is_binary(id) do
        doc = Mongo.find_one(@db, @collection, %{"_id" => id})

        reply =
          if doc do
            {:ok, convert_doc(doc, id)}
          else
            {:not_found, %{message: "No document found with ID: #{id}"}}
          end

        {:reply, reply, nil}
      end

      @impl GenServer
      def handle_call({:update, id, %{"id" => doc_id} = doc}, _from, _) when is_binary(id) do
        if doc_id != id,
          do: raise("ID of document [#{doc_id}] and ID provided in resource [#{id}] don't match")

        doc =
          doc
          |> Map.put("_id", id)
          |> Map.delete("id")

        res = Mongo.replace_one(@db, @collection, %{"_id" => id}, doc)

        reply =
          case res do
            {:ok, %Mongo.UpdateResult{matched_count: 0}} ->
              {:not_found, %{message: "No document found with ID: #{id}"}}

            {:ok, _} ->
              {:ok, convert_doc(doc, id)}

            {:error, error} ->
              Logger.error("Error updating WorkflowDef: #{inspect(error)}")
              {:internal_server_errror, %{message: "An error occurred"}}
          end

        {:reply, reply, nil}
      end

      @impl GenServer
      def handle_call({:delete, id}, _from, _) when is_binary(id) do
        res = Mongo.delete_one(@db, @collection, %{"_id" => id})

        reply =
          case res do
            {:ok, _} ->
              {:ok, nil}

            {:error, error} ->
              Logger.error("Error deleting WorkflowDef: #{inspect(error)}")
              {:internal_server_errror, %{message: "An error occurred"}}
          end

        {:reply, reply, nil}
      end

      defp convert_doc(doc, id) do
        doc
        |> Map.put("id", id)
        |> Map.delete("_id")
      end
    end
  end
end
