defmodule Swell.WorkflowExecutorTest.Functions do
  def validate(doc) do
    {"ok", %{doc | "status" => "validated"}}
  end

  def calculate(doc) do
    {"ok", %{doc | "output" => doc["input"] * 2}}
  end

  def sleep(doc) do
    :timer.sleep(50)
    {"ok", doc}
  end

  def boom(_doc) do
    raise "Boom!"
  end

  def nonexisting_transition(doc) do
    {"nonexisting", doc}
  end

  def ok(doc) do
    {"ok", doc}
  end
end

defmodule Swell.WorkflowExecutorTest do
  use ExUnit.Case
  alias Swell.DB.Repos.WorkflowRepo
  alias Swell.Workflow.State.Workflow
  alias Swell.Workflow.State.Error
  alias Swell.Workflow.Definition.WorkflowDef
  alias Swell.Workflow.Definition.StepDef
  alias Swell.Workflow.Definition.FunctionActionDef
  alias Swell.Workflow.Engine.WorkflowExecutor
  require Logger

  @before NaiveDateTime.utc_now()

  test "executes workflow correctly" do
    workflow = %WorkflowDef{
      id: "test_workflow",
      steps: %{
        "start" => %StepDef{
          action: %FunctionActionDef{
            module: Swell.WorkflowExecutorTest.Functions,
            function: :validate
          },
          transitions: %{
            "ok" => "calculate"
          }
        },
        "calculate" => %StepDef{
          action: %FunctionActionDef{
            module: Swell.WorkflowExecutorTest.Functions,
            function: :calculate
          },
          transitions: %{
            "ok" => "sleep"
          }
        },
        "sleep" => %StepDef{
          action: %FunctionActionDef{
            module: Swell.WorkflowExecutorTest.Functions,
            function: :sleep
          },
          transitions: %{
            "ok" => "end"
          }
        },
        "end" => "done"
      }
    }

    count = 1

    1..count
    |> Enum.each(fn i ->
      document = %{
        "id" => "123",
        "status" => "new",
        "input" => i,
        "output" => nil
      }

      WorkflowExecutor.execute(workflow, document)
    end)

    await_result(~w{update.done}, "done", &check_success/2, count)
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

  def check_success(
        {{:update, :done}, %Workflow{document: document, result: result} = workflow},
        count
      ) do
    Logger.debug("Count: #{count}")
    assert document["status"] == "validated"
    assert :lt == NaiveDateTime.compare(workflow.time_created, workflow.time_updated)
    assert :lt == NaiveDateTime.compare(@before, workflow.time_updated)
    assert document["output"] == document["input"] * 2
    assert result == "done"
    saved_workflow = WorkflowRepo.find_by_id(workflow.id)
    assert saved_workflow == workflow

    case count do
      1 -> {:done, 0}
      _ -> {:next, count - 1}
    end
  end

  test "handles runtime exception error" do
    workflow = %WorkflowDef{
      id: "test_workflow",
      steps: %{
        "start" => %StepDef{
          action: %FunctionActionDef{
            module: Swell.WorkflowExecutorTest.Functions,
            function: :boom
          },
          transitions: %{
            "ok" => "end"
          }
        },
        "end"  => "done"
      }
    }

    WorkflowExecutor.execute(workflow, %{"id" => "boom"})

    await_result(
      ~w{update.error},
      "errors",
      check_error("start", %RuntimeError{message: "Boom!"})
    )
  end

  test "throws error when a result code doesn't have a transition" do
    workflow = %WorkflowDef{
      id: "test_workflow",
      steps: %{
        "start" => %StepDef{
          action: %FunctionActionDef{module: Swell.WorkflowExecutorTest.Functions, function: :nonexisting_transition},
          transitions: %{
            "ok" => "end"
          }
        },
        "end" => "done"
      }
    }

    WorkflowExecutor.execute(workflow, %{"id" => "nonexisting_transition"})

    await_result(
      ~w{update.error},
      "errors",
      check_error(
        "start",
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
        "start" => %StepDef{
          action: %FunctionActionDef{module: Swell.WorkflowExecutorTest.Functions, function: :ok},
          transitions: %{
            "ok" => "nonexisting"
          }
        },
        "end" => "done"
      }
    }

    WorkflowExecutor.execute(workflow, %{"id" => "nonexisting_step"})

    await_result(
      ~w{error},
      "errors",
      check_error(
        "nonexisting",
        %Swell.Workflow.Engine.WorkflowError{
          message: "Invalid step: [nonexisting]"
        }
      )
    )
  end

  defp check_error(expected_step_name, expected_error) do
    fn {{:update, :error}, %Workflow{step: step, error: %Error{data: error_data}}}, _count ->
      assert step == expected_step_name
      assert error_data == expected_error
      {:done, 0}
    end
  end
end
