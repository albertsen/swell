defmodule TestData do
  @derive {Jason.Encoder, only: [:id, :status, :time_updated, :input, :output]}
  defstruct id: nil, status: nil, time_updated: nil, input: nil, output: nil
end
