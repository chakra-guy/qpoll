defmodule Qpoll.Repo do
  use Ecto.Repo,
    otp_app: :qpoll,
    adapter: Ecto.Adapters.Postgres
end
