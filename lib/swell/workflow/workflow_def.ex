defmodule Swell.WorkflowDef do
  defstruct [:_id, :id, :description, :command_handlers]
end

defmodule Swell.WorkflowDef.EndpointCommandHandler do
  defstruct [:_id, :type, :url]
end
