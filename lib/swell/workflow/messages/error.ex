defmodule Swell.Workflow.Messages.Error do
  @enforce_keys [:message, :error]
  defstruct message: nil, error: nil, details: nil

  @type t :: %Swell.Workflow.Messages.Error{
          message: map(),
          error: map(),
          details: any()
        }
end
