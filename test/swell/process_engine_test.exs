defmodule TestData do
  defstruct id: "", status: "", time_updated: nil
end

defmodule Swell.ProcessEngineTest do
  use ExUnit.Case

  setup do
    process_def = %Swell.ProcessDef.Process{
      actions: %{
        validate: fn (doc) -> {:ok, %{ doc | status: :validated}} end,
        touch: fn (doc) -> {:ok, %{ doc | time_updated: DateTime.utc_now()}} end
      },
      workflow: %{
        :start => %Swell.ProcessDef.Step{
          action: :validate,
          transitions: %{
            ok: :touch
          }
        },
        :touch => %Swell.ProcessDef.Step{
          action: :touch
        }
      }
    }
    {result, _pid} = Swell.Application.start(nil, {process_def, self()})
    result
  end

  test "executes workflow correctly" do
    before = DateTime.utc_now()
    Swell.ProcessEngine.WorkflowExecutor.execute_with(%TestData{
      id: "123",
      status: :new,
    })
    receive do
      {:done, document, _} ->
        assert document.status == :validated
        assert before < document.time_updated
    end

  end

end
