defmodule Sendero.Repo do
  use Ecto.Repo,
    otp_app: :sendero,
    adapter: Ecto.Adapters.Postgres
end
