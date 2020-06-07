defmodule QpollWeb.VoteController do
  use QpollWeb, :controller

  alias Qpoll.Polls
  alias Qpoll.Polls.Vote

  action_fallback(QpollWeb.FallbackController)

  def index(conn, %{"poll_id" => poll_id}) do
    votes = Polls.list_votes(poll_id)
    render(conn, "index.json", votes: votes)
  end

  def create(conn, %{"poll_id" => poll_id, "vote" => vote_params}) do
    with {:ok, %Vote{} = vote} <- Polls.create_vote(vote_params) do
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
