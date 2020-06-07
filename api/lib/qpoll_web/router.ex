defmodule QpollWeb.Router do
  use QpollWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", QpollWeb do
    pipe_through(:api)

    resources("/polls", PollController, except: [:new, :edit]) do
      resources("/options", PollOptionController, except: [:new, :edit], as: "option")
    end
  end
end
