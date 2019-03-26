defmodule Swell.QueueTest do
  use ExUnit.Case
  alias Swell.Queue

  test "puts and gets valus correctly" do
    Queue.start_link(:queue)
    Queue.enqueue(:queue, 1)
    Queue.enqueue(:queue, :two)
    Queue.enqueue(:queue, "three")
    Queue.enqueue(:queue, ['four'])
    {:value, 1} = Queue.dequeue(:queue)
    {:value, :two} = Queue.dequeue(:queue)
    {:value, "three"} = Queue.dequeue(:queue)
    {:value, ['four']} = Queue.dequeue(:queue)
    :empty = Queue.dequeue(:queue)
  end
end
