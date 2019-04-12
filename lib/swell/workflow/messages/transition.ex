defmodule Swell.Workflow.Messages.Transition do
  @enforce_keys [:step_name, :workflow, :document, :result]
  defstruct step_name: nil, workflow: nil, document: nil, result: nil

  @type t :: %Swell.Workflow.Messages.Transition{
          step_name: atom(),
          workflow: Swell.Workflow.Messages.Workflow.t(),
          document: map(),
          result: atom()
        }
end
