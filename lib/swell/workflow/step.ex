defmodule Swell.Workflow.Step do
  @enforce_keys [:action, :transitions]
  defstruct action: nil, transitions: nil

  @type t :: %Swell.Workflow.Step{
          action: (map() -> {atom(), map()}),
          transitions: %{atom() => atom()}
        }
end
