defmodule Swell.Order.Converter do
  alias Swell.Order
  alias Swell.Order.LineItem

  def to_struct(map) do
    line_items =
      map[:line_items]
      |> Enum.map(fn l -> struct(LineItem, l) end)

    order = struct(Order, map)
    %Order{order | line_items: line_items}
  end

  def to_map(order) do
    line_item_maps =
      order.line_items
      |> Enum.map(fn l -> Map.from_struct(l) end)

    map = Map.from_struct(order)
    %{map | line_items: line_item_maps}
  end
end
