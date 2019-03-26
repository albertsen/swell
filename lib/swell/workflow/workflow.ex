defmodule Swell.Workflow do
  @enforce_keys [:id, :steps]
  defstruct id: nil, steps: nil

  @type t :: %Swell.Workflow{
          id: String.t(),
          steps: steps()
        }
  @type steps :: %{required(atom()) => Swell.Step.t() | atom()}
end
