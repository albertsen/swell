defmodule Swell.Workflow.State.Workflow do
  alias Swell.Workflow.State.Workflow

  @derive {Jason.Encoder,
           only: [
             :id,
             :time_created,
             :time_updated,
             :definition,
             :document,
             :step,
             :result,
             :status,
             :waiting_for,
             :error
           ]}
  defstruct id: nil,
            time_created: nil,
            time_updated: nil,
            definition: nil,
            document: nil,
            step: nil,
            result: nil,
            status: nil,
            waiting_for: nil,
            error: nil

  @type t :: %Swell.Workflow.State.Workflow{
          id: String.t(),
          time_created: NaiveDateTime.t(),
          time_updated: NaiveDateTime.t(),
          definition: Swell.Workflow.Definition.Workflow.t(),
          document: map(),
          step: atom(),
          result: atom(),
          waiting_for: atom(),
          error: Swell.Workflow.State.Workflow.t(),
          status: :processing | :waiting | :error | :done
        }

  def new([{:definition, _}, {:document, _} | _] = values) do
    now = NaiveDateTime.utc_now()

    struct(
      Workflow,
      [id: UUID.uuid4(), time_created: now, time_updated: now]
      |> Keyword.merge(values)
    )
  end

  def touch(workflow) do
    %Workflow{workflow | time_updated: NaiveDateTime.utc_now()}
  end
end
