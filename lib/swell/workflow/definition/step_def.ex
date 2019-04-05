defmodule Swell.Workflow.Definition.StepDef do
  @enforce_keys [:action, :transitions]
  defstruct action: nil, transitions: nil

  @type t :: %Swell.Workflow.Definition.StepDef{
          action: {atom(), atom()},
          transitions: %{atom() => atom()}
        }
end
