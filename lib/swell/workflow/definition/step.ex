defmodule Swell.Workflow.Definition.Step do
  @enforce_keys [:action, :transitions]
  defstruct action: nil, transitions: nil

  @type t :: %Swell.Workflow.Definition.Step{
          action: (map() -> {atom(), map()}),
          transitions: %{atom() => atom()}
        }
end
