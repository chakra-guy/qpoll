defmodule QpollWeb.VoteController do
  use QpollWeb, :controller

  # alias QpollWeb.Endpoint
  alias Qpoll.Polls
  alias Qpoll.Polls.Vote

  action_fallback(QpollWeb.FallbackController)

  def create(conn, %{"id" => id, "vote" => %{"option_id" => option_id}}) do
    poll_option = Polls.get_poll_option!(option_id)

    with {:ok, _poll_option} <- Polls.option_belongs_to_poll?(id, poll_option),
         {:ok, %Vote{} = vote} <- Polls.create_vote(poll_option) do
      # FIXME update ws message to be an aggregate
      # Endpoint.broadcast!("poll:" <> poll_id, "new_vote", %{vote: vote})

      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.poll_path(conn, :show, id))
      |> render("show.json", vote: vote)
    end
  end
end
