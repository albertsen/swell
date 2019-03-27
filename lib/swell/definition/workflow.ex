defmodule Swell.Definition.Workflow do
  @enforce_keys [:id, :steps]
  defstruct id: nil, steps: nil

  @type t :: %Swell.Definition.Workflow{
          id: String.t(),
          steps: steps()
        }
  @type steps :: %{required(atom()) => Swell.Definition.Step.t() | atom()}
end
