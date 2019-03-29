defmodule Swell.Workflow.Definition.Workflow do
  @enforce_keys [:id, :steps]
  defstruct id: nil, steps: nil

  @type t :: %Swell.Workflow.Definition.Workflow{
          id: String.t(),
          steps: steps()
        }
  @type steps :: %{required(atom()) => Swell.Workflow.Definition.Step.t() | atom()}
end
