defmodule Swell.WorkflowDef.StepDef do
  @enforce_keys [:action, :transitions]
  defstruct action: nil, transitions: nil

  @type t :: %Swell.WorkflowDef.StepDef{
          action: (map() -> {atom(), map()}),
          transitions: %{atom() => atom()}
        }
end

defmodule Swell.WorkflowDef do
  @enforce_keys [:id, :steps]
  defstruct id: nil, steps: nil

  @type t :: %Swell.WorkflowDef{
          id: String.t(),
          steps: steps()
        }
  @type steps :: %{required(atom()) => Swell.StepDef.t() | atom()}
end
