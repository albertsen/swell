defmodule Swell.Workflow.Definition.WorkflowDef do
  @enforce_keys [:id, :steps]
  @derive {Jason.Encoder, only: [:id, :steps]}
  defstruct id: nil, steps: nil

  @type t :: %Swell.Workflow.Definition.WorkflowDef{
          id: String.t(),
          steps: steps()
        }
  @type steps :: %{required(String.t()) => Swell.Workflow.Definition.StepDef.t() | String.t()}
end
