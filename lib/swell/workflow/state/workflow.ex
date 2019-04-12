defmodule Swell.Workflow.State.Workflow do
  @enforce_keys [:id, :definition, :document, :step, :result]
  defstruct id: nil, definition: nil, document: nil, step: nil, result: nil, status: nil

  @type t :: %Swell.Workflow.State.Workflow{
          id: String.t(),
          definition: Swell.Workflow.Definition.Workflow.t(),
          document: map(),
          step: atom(),
          result: atom(),
          status: :processing | :waiting | :error
        }
end
