defmodule Swell.Definition.Step do
  @enforce_keys [:action, :transitions]
  defstruct action: nil, transitions: nil

  @type t :: %Swell.Definition.Step{
          action: (map() -> {atom(), map()}),
          transitions: %{atom() => atom()}
        }
end
