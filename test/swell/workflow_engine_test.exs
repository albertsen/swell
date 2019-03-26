defmodule TestData do
  defstruct id: "", status: "", time_updated: nil, input: nil, output: nil
end

defmodule Swell.WorkflowExecutorTest do
  use ExUnit.Case
  @before DateTime.utc_now()

  test "executes workflow correctly" do
    workflow = %Swell.Workflow{
      id: :test_workflow,
      steps: %{
        start: %Swell.Workflow.Step{
          action: fn (doc) -> {:ok, %{doc | status: :validated}} end,
          transitions: %{
            ok: :touch
          }
        },
        touch: %Swell.Workflow.Step{
          action: fn (doc) -> {:ok, %{doc | time_updated: DateTime.utc_now()}} end,
          transitions: %{
            ok: :calculate
          }
        },
        calculate: %Swell.Workflow.Step{
          action: fn (doc) -> {:ok, %{doc | output: doc.input*2}} end,
          transitions: %{
            ok: :sleep
          }
        },
        sleep: %Swell.Workflow.Step{
          action: fn (doc) ->
            :timer.sleep(50)
            {:ok, doc}
          end,
          transitions: %{
            ok: :end
          }
        },
        end: :done
      }
    }

    count = 1000

    1..count
    |> Enum.each(fn (i) ->
      document = %TestData{
        id: "123",
        status: :new,
        input: i,
      }
      Swell.WorkflowEngine.execute(workflow, document)
    end)
    check_for_result(:empty, count)
  end

  defp check_for_result(:empty, 0), do: nil

  defp check_for_result(:empty, count) do
    check_for_result(Swell.Queue.dequeue(:results), count)
  end

  defp check_for_result({:value, {result_code, doc}}, count) do
    assert result_code == :done
    assert doc.status == :validated
    :lt = DateTime.compare(@before, doc.time_updated)
    assert doc.output == doc.input * 2
    check_for_result(:empty, count - 1)
  end

  # test "handles workflow error" do
  #   workflow = %Swell.Workflow{
  #     id: :test_workflow,
  #     steps: %{
  #       start: %Swell.Workflow.Step{
  #         action: fn(_) -> raise "Boom!" end,
  #         transitions: %{
  #           ok: :end
  #         }
  #       },
  #       end: :done
  #     }
  #   }

  #   Swell.WorkflowEngine.execute(workflow, %{})
  #   check_for_result(:empty)
  # end


end
