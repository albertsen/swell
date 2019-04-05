defmodule Swell.Queue.Publisher do

  @transitions "transitions"
  @errors "errors"
  @done "done"
  @steps "steps"
  require Logger

  def publish_message({:done, {_id, _workflow, _document}} = message, channel) do
    Logger.debug(fn -> "Publshing done: #{inspect(message)}" end)
    Swell.Queue.Manager.publish(channel, @done, message)
  end

  def publish_message({:transition, {_id, _workflow, _document, _step_name, result}} = message, channel) when is_atom(result) do
    Logger.debug(fn -> "Publishing transition: #{inspect(message)}" end)
    Swell.Queue.Manager.publish(channel, @transitions, message)
  end

  def publish_message({:error, {_id, _workflow, _document, _step_name, _error}} = message, channel) do
    Logger.debug(fn -> "Publishing error: #{inspect(message)}" end)
    Swell.Queue.Manager.publish(channel, @errors, message)
  end

  def publish_message({:step, {_id, _workflow, _step_name, _document}} = message, channel) do
    Logger.debug(fn -> "Publishing step: #{inspect(message)}" end)
    Swell.Queue.Manager.publish(channel, @steps, message)
  end


  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      import Swell.Queue.Publisher
    end
  end

end
