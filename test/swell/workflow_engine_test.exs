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
    {:ok, %{doc | output: doc.input * 2}}
  end

  def sleep(doc) do
    :timer.sleep(50)
    {:ok, doc}
  end

  def boom(_doc) do
    raise "Boom!"
  end

  def nonexisting_transition(doc) do
    {:nonexisting, doc}
  end

  def ok(doc) do
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
    |> Enum.each(fn i ->
      document = %TestData{
        id: "123",
        status: :new,
        input: i
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

  test "handles runtime exception error" do
    workflow = %Workflow{
      id: :test_workflow,
      steps: %{
        start: %Step{
          action: {Swell.WorkflowExecutorTest.Functions, :boom},
          transitions: %{
            ok: :end
          }
        },
        end: :done
      }
    }

    WorkflowExecutor.execute(workflow, %{})
    wait_for_error({:start, %RuntimeError{message: "Boom!"}})
  end

  test "throws error when a result code doesn't have a transition" do
    workflow = %Workflow{
      id: :test_workflow,
      steps: %{
        start: %Step{
          action: {Swell.WorkflowExecutorTest.Functions, :nonexisting_transition},
          transitions: %{
            ok: :end
          }
        },
        end: :done
      }
    }
    WorkflowExecutor.execute(workflow, %{})
    wait_for_error({:start,  %Swell.Workflow.Engine.WorkflowError{
      message: "No transition in step [start] for result with code [nonexisting]"
    }})
  end

  test "throws error when a transition points to an invalid step" do
    workflow = %Workflow{
      id: :test_workflow,
      steps: %{
        start: %Step{
          action: {Swell.WorkflowExecutorTest.Functions, :ok},
          transitions: %{
            ok: :nonexisting
          }
        },
        end: :done
      }
    }
    WorkflowExecutor.execute(workflow, %{})
    wait_for_error({:nonexisting,  %Swell.Workflow.Engine.WorkflowError{
      message: "Invalid step: [nonexisting]"
    }})
  end

  def wait_for_error(expected) do
    chan = Swell.Queue.Manager.open_channel()
    Swell.Queue.Manager.consume(chan, "errors")
    Swell.Queue.Receiver.wait_for_messages(chan, &check_error/2, expected)
  end

  def check_error({_workflow, step_name, _document, error}, {expected_step_name, expected_error}) do
    assert step_name == expected_step_name
    assert error == expected_error
    {:done, nil}
  end


end
