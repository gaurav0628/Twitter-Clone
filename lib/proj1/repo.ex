defmodule Proj1.Repo do
  use Ecto.Repo,
    otp_app: :proj1,
    adapter: Ecto.Adapters.Postgres
end
