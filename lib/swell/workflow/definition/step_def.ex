defmodule Swell.Workflow.Definition.StepDef do
  @enforce_keys [:action, :transitions]
  @derive {Jason.Encoder, only: [:action, :transitions]}
  defstruct action: nil, transitions: nil

  @type t :: %Swell.Workflow.Definition.StepDef{
          action: Swell.Workflow.Definition.FunctionAcionDef.t(),
          transitions: %{String.t() => String.t()}
        }
end
