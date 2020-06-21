defmodule QpollWeb.Router do
  use QpollWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", QpollWeb do
    pipe_through(:api)

    resources("/polls", PollController, except: [:new, :edit]) do
      resources("/options", PollOptionController, except: [:new, :edit], as: "option")
      resources("/votes", VoteController, only: [:index, :create, :show], as: "vote")
    end

    #  REVIEW
    post("/polls/:id/publish", PollController, :publish)
    post("/polls/:id/unpublish", PollController, :unpublish)
    delete("/polls/:id/publish", PollController, :unpublish)
  end
end
