defmodule Salatwitter.Repo do
  use Ecto.Repo,
    otp_app: :salatwitter,
    adapter: Ecto.Adapters.Postgres
end
