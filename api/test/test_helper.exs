ExUnit.configure(exclude: :skip)
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Qpoll.Repo, :manual)
