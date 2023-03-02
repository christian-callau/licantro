defmodule Licantro.Repo do
  use Ecto.Repo,
    otp_app: :licantro,
    adapter: Ecto.Adapters.Postgres
end
