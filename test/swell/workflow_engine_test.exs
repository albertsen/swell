defmodule TestData do
  defstruct id: nil, status: nil, time_updated: nil, input: nil, output: nil
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
  alias Swell.Workflow.State.Workflow
  alias Swell.Workflow.State.Error
  alias Swell.Workflow.Definition.WorkflowDef
  alias Swell.Workflow.Definition.StepDef
  alias Swell.Workflow.Engine.WorkflowExecutor
  require Logger

  @before DateTime.utc_now()

  test "executes workflow correctly" do
    workflow = %WorkflowDef{
      id: :test_workflow,
      steps: %{
        start: %StepDef{
          action: {Swell.WorkflowExecutorTest.Functions, :validate},
          transitions: %{
            ok: :touch
          }
        },
        touch: %StepDef{
          action: {Swell.WorkflowExecutorTest.Functions, :touch},
          transitions: %{
            ok: :calculate
          }
        },
        calculate: %StepDef{
          action: {Swell.WorkflowExecutorTest.Functions, :calculate},
          transitions: %{
            ok: :sleep
          }
        },
        sleep: %StepDef{
          action: {Swell.WorkflowExecutorTest.Functions, :sleep},
          transitions: %{
            ok: :end
          }
        },
        end: :done
      }
    }

    count = 1

    1..count
    |> Enum.each(fn i ->
      document = %TestData{
        id: "123",
        status: :new,
        input: i
      }

      WorkflowExecutor.execute(workflow, document)
    end)

    await_result(~w{done}, "done", &check_success/2, count)
  end

  defp await_result(routing_keys, queue, func, count \\ 1) do
    channel = Swell.Queue.Manager.open_channel()
    {:ok, consumer_tag} = Swell.Queue.Manager.consume(channel, routing_keys, queue)

    try do
      Swell.Queue.Receiver.wait_for_messages(channel, func, count)
    after
      Swell.Queue.Manager.cancel(channel, consumer_tag)
    end
  end

  def check_success({:done, %Workflow{document: document, result: result}}, count) do
    Logger.debug("Count: #{count}")
    assert document.status == :validated
    assert :lt == DateTime.compare(@before, document.time_updated)
    assert document.output == document.input * 2
    assert result == :done

    case count do
      1 -> {:done, 0}
      _ -> {:next, count - 1}
    end
  end

  test "handles runtime exception error" do
    workflow = %WorkflowDef{
      id: :test_workflow,
      steps: %{
        start: %StepDef{
          action: {Swell.WorkflowExecutorTest.Functions, :boom},
          transitions: %{
            ok: :end
          }
        },
        end: :done
      }
    }

    WorkflowExecutor.execute(workflow, %{id: :boom})

    await_result(
      ~w{error},
      "errors",
      check_error(:start, %RuntimeError{message: "Boom!"})
    )
  end

  test "throws error when a result code doesn't have a transition" do
    workflow = %WorkflowDef{
      id: :test_workflow,
      steps: %{
        start: %StepDef{
          action: {Swell.WorkflowExecutorTest.Functions, :nonexisting_transition},
          transitions: %{
            ok: :end
          }
        },
        end: :done
      }
    }

    WorkflowExecutor.execute(workflow, %{id: :nonexisting_transition})

    await_result(
      ~w{error},
      "errors",
      check_error(
        :start,
        %Swell.Workflow.Engine.WorkflowError{
          message: "No transition in step [start] for result with code [nonexisting]"
        }
      )
    )
  end

  test "throws error when a transition points to an invalid step" do
    workflow = %WorkflowDef{
      id: :test_workflow,
      steps: %{
        start: %StepDef{
          action: {Swell.WorkflowExecutorTest.Functions, :ok},
          transitions: %{
            ok: :nonexisting
          }
        },
        end: :done
      }
    }

    WorkflowExecutor.execute(workflow, %{id: :nonexisting_step})

    await_result(
      ~w{error},
      "errors",
      check_error(
        :nonexisting,
        %Swell.Workflow.Engine.WorkflowError{
          message: "Invalid step: [nonexisting]"
        }
      )
    )
  end

  defp check_error(expected_step_name, expected_error) do
    fn ({:error, %Workflow{step: step, error: %Error{data: error_data}}}, _count) ->
      assert step == expected_step_name
      assert error_data == expected_error
      {:done, 0}
    end
  end
end
