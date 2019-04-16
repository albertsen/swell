defmodule Swell.Workflow.State.Workflow do
  @enforce_keys [:id, :definition, :document]
  defstruct id: nil, definition: nil, document: nil, step: nil, result: nil, status: nil, error: nil

  @type t :: %Swell.Workflow.State.Workflow{
          id: String.t(),
          definition: Swell.Workflow.Definition.Workflow.t(),
          document: map(),
          step: atom(),
          result: atom(),
          error: Swell.Workflow.State.Workflow.t(),
          status: :processing | :waiting | :error | :done
        }
end
