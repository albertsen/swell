defmodule Swell.Workflow.Definition.WorkflowDef do
  @enforce_keys [:id, :steps]
  defstruct id: nil, steps: nil

  @type t :: %Swell.Workflow.Definition.WorkflowDef{
          id: String.t(),
          steps: steps()
        }
  @type steps :: %{required(atom()) => Swell.Workflow.Definition.StepDef.t() | atom()}
end
