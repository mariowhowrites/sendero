defmodule Cyoa.Repo do
  use Ecto.Repo,
    otp_app: :cyoa,
    adapter: Ecto.Adapters.Postgres
end
