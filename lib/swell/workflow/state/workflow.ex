defmodule Swell.Workflow.State.Workflow do
  @enforce_keys [:id, :definition, :document]
  @derive {Jason.Encoder, only: [:id, :definition, :document, :step, :result, :status, :waiting_for, :error]}
  defstruct id: nil, definition: nil, document: nil, step: nil, result: nil, status: nil, waiting_for: nil, error: nil

  @type t :: %Swell.Workflow.State.Workflow{
          id: String.t(),
          definition: Swell.Workflow.Definition.Workflow.t(),
          document: map(),
          step: atom(),
          result: atom(),
          waiting_for: atom(),
          error: Swell.Workflow.State.Workflow.t(),
          status: :processing | :waiting | :error | :done
        }
end
