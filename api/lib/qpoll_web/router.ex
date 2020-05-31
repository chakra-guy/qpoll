defmodule QpollWeb.Router do
  use QpollWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", QpollWeb do
    pipe_through :api
  end
end
