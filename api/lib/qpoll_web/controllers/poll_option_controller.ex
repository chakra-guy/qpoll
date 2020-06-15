defmodule QpollWeb.PollOptionController do
  use QpollWeb, :controller

  alias Qpoll.Polls
  alias Qpoll.Polls.PollOption

  action_fallback(QpollWeb.FallbackController)

  def index(conn, %{"poll_id" => poll_id}) do
    poll = Polls.get_poll!(poll_id)
    render(conn, "index.json", poll_options: poll.poll_options)
  end

  def create(conn, %{"poll_id" => poll_id, "poll_option" => poll_option_params}) do
    poll = Polls.get_poll!(poll_id)

    with {:ok, %PollOption{} = poll_option} <-
           Polls.create_poll_option(poll, poll_option_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.poll_option_path(conn, :show, poll_id, poll_option))
      |> render("show.json", poll_option: poll_option)
    end
  end

  def show(conn, %{"poll_id" => poll_id, "id" => id}) do
    poll = Polls.get_poll!(poll_id)

    with {:ok, %PollOption{} = poll_option} <- Polls.get_poll_option!(poll, id) do
      render(conn, "show.json", poll_option: poll_option)
    end
  end

  def update(conn, %{"poll_id" => poll_id, "id" => id, "poll_option" => poll_option_params}) do
    poll = Polls.get_poll!(poll_id)

    with {:ok, %PollOption{} = poll_option} <- Polls.update_poll_option(poll, poll_option_params) do
      render(conn, "show.json", poll_option: poll_option)
    end
  end

  def delete(conn, %{"poll_id" => poll_id, "id" => id}) do
    poll = Polls.get_poll!(poll_id)

    with {:ok, %PollOption{}} <- Polls.delete_poll_option(poll) do
      send_resp(conn, :no_content, "")
    end
  end
end
