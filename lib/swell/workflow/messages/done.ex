defmodule Swell.Workflow.Messages.Done do
  @enforce_keys [:workflow, :document, :result]
  defstruct workflow: nil, document: nil, result: nil

  @type t :: %Swell.Workflow.Messages.Done{
          workflow: Swell.Workflow.Messages.Workflow.t(),
          document: map(),
          result: atom()
        }
end
