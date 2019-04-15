defmodule Swell.DB.Repo.Migrations.CreateWorkflows do
  use Ecto.Migration

  def change do
    create table(:workflows) do
      add :time_created,  :utc_datetime_usec
      add :time_updated,  :utc_datetime_usec
      add :definition,    :map
      add :document_id,   :string
      add :document,      :map
      add :waiting_for,   :string
      add :status,        :string
      add :result,        :string
    end
    create index(:workflows, [:document_id])
    create index(:workflows, [:id, :waiting_for])
    create index(:workflows, [:status])
  end
end
