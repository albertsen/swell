defmodule Swell.Workflow.State.Error do
  @enforce_keys [:routing_key, :message]
  @derive {Jason.Encoder, only: [:routing_key, :message, :details]}
  defstruct routing_key: nil, message: nil, data: nil, details: nil

  @type t :: %Swell.Workflow.State.Error{
          routing_key: String.t(),
          message: String.t(),
          data: map(),
          details: String.t()
        }
end
