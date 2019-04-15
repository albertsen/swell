defmodule Swell.DB.DTO.Workflow do
  use Ecto.Schema

  schema "workflows" do
    field :time_created,  :utc_datetime_usec
    field :time_updated,  :utc_datetime_usec
    field :definition,    :map
    field :document_id,   :string
    field :document,      :map
    field :waiting_for,   :string
    field :status,        :string
    field :result,        :string
  end

end
