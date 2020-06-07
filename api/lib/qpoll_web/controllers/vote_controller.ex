defmodule QpollWeb.VoteController do
  use QpollWeb, :controller

  alias Qpoll.Polls
  alias Qpoll.Polls.Vote

  action_fallback QpollWeb.FallbackController

  def index(conn, _params) do
    votes = Polls.list_votes()
    render(conn, "index.json", votes: votes)
  end

  def create(conn, %{"vote" => vote_params}) do
    with {:ok, %Vote{} = vote} <- Polls.create_vote(vote_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.vote_path(conn, :show, vote))
      |> render("show.json", vote: vote)
    end
  end

  def show(conn, %{"id" => id}) do
    vote = Polls.get_vote!(id)
    render(conn, "show.json", vote: vote)
  end

  def update(conn, %{"id" => id, "vote" => vote_params}) do
    vote = Polls.get_vote!(id)

    with {:ok, %Vote{} = vote} <- Polls.update_vote(vote, vote_params) do
      render(conn, "show.json", vote: vote)
    end
  end

  def delete(conn, %{"id" => id}) do
    vote = Polls.get_vote!(id)

    with {:ok, %Vote{}} <- Polls.delete_vote(vote) do
      send_resp(conn, :no_content, "")
    end
  end
end
