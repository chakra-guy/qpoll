defmodule QpollWeb.VoteController do
  use QpollWeb, :controller

  alias QpollWeb.Endpoint
  alias Qpoll.Polls
  alias Qpoll.Polls.Vote

  action_fallback(QpollWeb.FallbackController)

  def index(conn, %{"poll_id" => poll_id}) do
    poll = Polls.get_poll!(poll_id)
    votes = Polls.list_poll_votes(poll)
    render(conn, "index.json", votes: votes)
  end

  #  REVIEW
  def create(conn, %{"poll_id" => poll_id, "vote" => vote_params}) do
    poll = Polls.get_poll!(poll_id)

    with {:ok, %Vote{} = vote} <- Polls.create_vote(poll, vote_params) do
      # FIXME update ws message to be an aggregate
      Endpoint.broadcast!("poll:" <> poll_id, "new_vote", %{vote: vote})

      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.poll_vote_path(conn, :show, poll_id, vote))
      |> render("show.json", vote: vote)
    end
  end

  def show(conn, %{"id" => id}) do
    vote = Polls.get_vote!(id)
    render(conn, "show.json", vote: vote)
  end
end
