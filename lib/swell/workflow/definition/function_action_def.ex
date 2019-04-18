defmodule Swell.Workflow.Definition.FunctionActionDef do
  @enforce_keys [:module, :function]
  @derive {Jason.Encoder, only: [:module, :function]}
  defstruct module: nil, function: nil

  @type t :: %Swell.Workflow.Definition.FunctionActionDef{
          module: atom(),
          function: atom()
        }
end
