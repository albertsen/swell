defmodule Swell.WorkflowExecutorTest do
  use ExUnit.Case
  require Logger
  alias Swell.Event
  alias Swell.Order
  alias Swell.Order.LineItem
  alias Swell.DB.Repo.OrderRepo

  test "sends events" do
    count = 2
    1..count
    |> Enum.map(fn i ->
      line_items = [
        %LineItem{product_id: "#{i}-1", item_price: 1000, count: 2, total_price: 2000},
        %LineItem{product_id: "#{i}-2", item_price: 5000, count: 1, total_price: 5000},
        %LineItem{product_id: "#{i}-3", item_price: 2000, count: 2, total_price: 4000}
      ]
      %Order{total_price: 11000, customer_email: "ich#{i}@du.com", line_items: line_items}
    end)
    |> (fn (orders) ->
      Enum.each(orders, &Event.send("order_placed", &1))
      Process.sleep(1000)
      orders
    end).()
    |> Enum.each(fn (order_created) ->
      IO.puts(inspect(order_created))
      order_stored = OrderRepo.find_by_customer_email(order_created.customer_email)
      assert order_created == order_stored
    end)
  end
end
