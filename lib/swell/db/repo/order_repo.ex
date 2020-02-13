defmodule Swell.DB.Repo.OrderRepo do
  require Logger
  alias Swell.Order
  alias Swell.Order.Converter
  @db :swell

  def create(%Order{id: nil} = order) do
    now = DateTime.utc_now()
    id = UUID.uuid4()

    order =
      order
      |> Converter.to_map()
      |> Map.merge(%{
        _id: id,
        id: id,
        created_at: now,
        updated_at: now,
        status: "created"
      })

    Mongo.insert_one!(@db, "orders", order)
    {:ok, order}
  end

  def create(%Order{id: _id}), do: raise("New order cannot have an ID")

  def find_by_id(id) when is_binary(id) do
    Mongo.find_one(@db, "orders", %{_id: id})
    |> Converter.to_struct()
  end

  def find_by_customer_email(customer_email) when is_binary(customer_email) do
    Mongo.find(@db, "orders", %{customer_email: customer_email})
    |> Enum.map(&Converter.to_struct(&1))
  end


end
