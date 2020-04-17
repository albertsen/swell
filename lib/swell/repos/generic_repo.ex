defmodule Swell.Repos.GenRepo do
  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      require Logger
      @db Keyword.fetch!(Application.get_env(:swell, :db), :name)
      @collection Keyword.fetch!(opts, :collection)

      def create(doc) when is_map(doc) do
        doc =
          doc
          |> Map.put("_id", Map.get_lazy(doc, "id", fn -> UUID.uuid4() end))
          |> Map.delete("id")

        res = Mongo.insert_one(@db, @collection, doc)

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
      end

      def find_by_id(id) when is_binary(id) do
        doc = Mongo.find_one(@db, @collection, %{"_id" => id})

        if doc do
          {:ok, convert_doc(doc, id)}
        else
          {:not_found, %{message: "No document found with ID: #{id}"}}
        end
      end

      def update(id, %{"id" => doc_id} = doc) when is_binary(id) do
        if doc_id != id,
          do: raise("ID of document [#{doc_id}] and ID provided in resource [#{id}] don't match")

        doc =
          doc
          |> Map.put("_id", id)
          |> Map.delete("id")

        res = Mongo.replace_one(@db, @collection, %{"_id" => id}, doc)

        case res do
          {:ok, %Mongo.UpdateResult{matched_count: 0}} ->
            {:not_found, %{message: "No document found with ID: #{id}"}}

          {:ok, _} ->
            {:ok, convert_doc(doc, id)}

          {:error, error} ->
            Logger.error("Error updating document: #{inspect(error)}")
            {:internal_server_errror, %{message: "An error occurred"}}
        end
      end

      def delete(id) when is_binary(id) do
        res = Mongo.delete_one(@db, @collection, %{"_id" => id})

        reply =
          case res do
            {:ok, _} ->
              {:ok, nil}

            {:error, error} ->
              Logger.error("Error deleting WorkflowDef: #{inspect(error)}")
              {:internal_server_errror, %{message: "An error occurred"}}
          end
      end

      def convert_doc(doc, id) do
        doc
        |> Map.put("id", id)
        |> Map.delete("_id")
      end

      def db, do: @db

      def collection, do: @collection
    end
  end
end
