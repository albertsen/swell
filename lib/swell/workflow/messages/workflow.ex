defmodule Swell.Workflow.Messages.Workflow do
  @enforce_keys [:id, :definition]
  defstruct id: nil, definition: nil

  @type t :: %Swell.Workflow.Messages.Workflow{
          id: String.t(),
          definition: Swell.Workflow.Definition.WorkflowDef.t(),
        }
end
