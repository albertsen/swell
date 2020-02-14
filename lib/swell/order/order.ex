defmodule Swell.Order do
  # @derive Jason.Encoder
  defstruct [:_id, :id, :created_at, :updated_at, :total_price, :status, :customer_email, :line_items]
end

defmodule Swell.Order.LineItem do
  # @derive Jason.Encoder
  defstruct [:product_id, :item_price, :total_price, :count]
end
