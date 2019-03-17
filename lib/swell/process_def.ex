defmodule Swell.ProcessDef.Process do
  defstruct id: "", description: "", actions: %{}, workflow: %{}
end

defmodule Swell.ProcessDef.Step do
  defstruct action: "", transitions: nil
end
