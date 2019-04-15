defmodule Swell.DB.Repo do
  use Ecto.Repo,
    otp_app: :swell,
    adapter: Ecto.Adapters.Postgres
end
