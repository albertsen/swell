defmodule TestData do
  defstruct id: "", status: "", time_updated: nil
end

defmodule TestActions do
  def validate(doc) do
    {:ok, %{doc | status: :validated}}
  end

  def touch(doc) do
    {:ok, %{doc | time_updated: DateTime.utc_now()}}
  end
end

defmodule Swell.ProcessEngineTest do
  use ExUnit.Case

  test "executes workflow correctly" do
    before = DateTime.utc_now()

    workflow_def = %Swell.WorkflowDef{
      id: :test_workflow,
      steps: %{
        start: %Swell.WorkflowDef.StepDef{
          action: &TestActions.validate/1,
          transitions: %{
            ok: :touch
          }
        },
        touch: %Swell.WorkflowDef.StepDef{
          action: &TestActions.touch/1,
          transitions: %{
            ok: :end
          }
        },
        end: :done
      }
    }

    document = %TestData{
      id: "123",
      status: :new
    }

    document = Swell.WorkflowEngine.execute(workflow_def, document)

    assert document.status == :validated
    assert before < document.time_updated
  end
end
