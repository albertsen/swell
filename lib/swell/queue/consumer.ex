defmodule Queue.Consumer do

  @callback consume_message(any()) :: :ok

end
