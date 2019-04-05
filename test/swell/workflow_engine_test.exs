defmodule TestData do
  defstruct id: "", status: "", time_updated: nil, input: nil, output: nil
end

defmodule Swell.WorkflowExecutorTest.Functions do

  def validate(doc) do
    {:ok, %{doc | status: :validated}}
  end

  def touch(doc) do
    {:ok, %{doc | time_updated: DateTime.utc_now()}}
  end

  def calculate(doc) do
    {:ok, %{doc | output: doc.input*2}}
  end

  def sleep(doc) do
    :timer.sleep(50)
    {:ok, doc}
  end

end

defmodule Swell.WorkflowExecutorTest do
  use ExUnit.Case
  alias Swell.Workflow.Definition.Workflow
  alias Swell.Workflow.Definition.Step
  alias Swell.Workflow.Engine.WorkflowExecutor

  @before DateTime.utc_now()

  test "executes workflow correctly" do
    workflow = %Workflow{
      id: :test_workflow,
      steps: %{
        start: %Step{
          action: {Swell.WorkflowExecutorTest.Functions, :validate},
          transitions: %{
            ok: :touch
          }
        },
        touch: %Step{
          action: {Swell.WorkflowExecutorTest.Functions, :touch},
          transitions: %{
            ok: :calculate
          }
        },
        calculate: %Step{
          action: {Swell.WorkflowExecutorTest.Functions, :calculate},
          transitions: %{
            ok: :sleep
          }
        },
        sleep: %Step{
          action: {Swell.WorkflowExecutorTest.Functions, :sleep},
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
      WorkflowExecutor.execute(workflow, document)
    end)
    chan = Swell.Queue.Manager.open_channel()
    Swell.Queue.Manager.consume(chan, "results")
    Swell.Queue.Receiver.wait_for_messages(chan, &check_result/2, count)
  end

  def check_result({result_code, doc}, count) do
    assert result_code == :done
    assert doc.status == :validated
    assert :lt == DateTime.compare(@before, doc.time_updated)
    assert doc.output == doc.input * 2
    case count do
      1 -> {:done, 0}
      _ -> {:next, count - 1}
    end
  end

  # test "handles runtime exception error" do
  #   workflow = %Workflow{
  #     id: :test_workflow,
  #     steps: %{
  #       start: %Step{
  #         action: fn(_) ->
  #           raise "Boom!"
  #         end,
  #         transitions: %{
  #           ok: :end
  #         }
  #       },
  #       end: :done
  #     }
  #   }
  #   WorkflowExecutor.execute(workflow, %{})
  #   check_for_error(:empty, {:start, %RuntimeError{message: "Boom!"}})
  # end

  # test "throws error when a result code doesn't have a transition" do
  #   workflow = %Workflow{
  #     id: :test_workflow,
  #     steps: %{
  #       start: %Step{
  #         action: fn(doc) -> {:notexisting, doc} end,
  #         transitions: %{
  #           ok: :end
  #         }
  #       },
  #       end: :done
  #     }
  #   }
  #   WorkflowExecutor.execute(workflow, %{})
  #   check_for_error(:empty, {:start,  %Swell.Engine.WorkflowError{
  #     message: "No transition in step [start] for result with code [notexisting]"
  #   }})
  # end

  # test "throws error when a transition points to an invalid step" do
  #   workflow = %Workflow{
  #     id: :test_workflow,
  #     steps: %{
  #       start: %Step{
  #         action: fn(doc) -> {:ok, doc} end,
  #         transitions: %{
  #           ok: :notexisting
  #         }
  #       },
  #       end: :done
  #     }
  #   }
  #   WorkflowExecutor.execute(workflow, %{})
  #   check_for_error(:empty, {:notexisting,  %Swell.Engine.WorkflowError{
  #     message: "Invalid step: [notexisting]"
  #   }})
  # end


  # defp check_for_error(:empty, {expected_step_name, expected_error}) do
  #   check_for_error(Swell.Queue.dequeue(:errors), {expected_step_name, expected_error})
  # end

  # defp check_for_error({:value, {_workflow, step_name, _document, error}}, {expected_step_name, expected_error}) do
  #   assert step_name == expected_step_name
  #   assert error == expected_error
  # end


end
