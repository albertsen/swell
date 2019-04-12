defmodule Swell.Workflow.Messages.Step do
  @enforce_keys [:step_name, :workflow, :document]
  defstruct step_name: nil, workflow: nil, document: nil, retry: 0

  @type t :: %Swell.Workflow.Messages.Step{
          step_name: atom(),
          workflow: Swell.Workflow.Messages.Workflow.t(),
          document: map(),
          retry: integer()
        }
end
