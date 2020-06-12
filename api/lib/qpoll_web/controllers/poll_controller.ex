defmodule QpollWeb.PollController do
  use QpollWeb, :controller

  alias Qpoll.Polls
  alias Qpoll.Polls.Poll

  action_fallback(QpollWeb.FallbackController)

  def index(conn, _params) do
    polls = Polls.list_polls()
    render(conn, "index.json", polls: polls)
  end

  def create(conn, %{"poll" => poll_params}) do
    params = fixme_format_poll_params(poll_params)

    with {:ok, %Poll{} = poll} <- Polls.create_poll(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.poll_path(conn, :show, poll))
      |> render("show.json", poll: poll)
    end
  end

  def show(conn, %{"id" => id}) do
    poll = Polls.get_poll!(id)
    render(conn, "show.json", poll: poll)
  end

  def update(conn, %{"id" => id, "poll" => poll_params}) do
    poll = Polls.get_poll!(id)
    params = fixme_format_poll_params(poll_params)

    with {:ok, %Poll{} = poll} <- Polls.update_poll(poll, params) do
      render(conn, "show.json", poll: poll)
    end
  end

  def delete(conn, %{"id" => id}) do
    poll = Polls.get_poll!(id)

    with {:ok, %Poll{}} <- Polls.delete_poll(poll) do
      send_resp(conn, :no_content, "")
    end
  end

  defp fixme_format_poll_params(poll_params) do
    poll_options =
      poll_params
      |> Map.get("options", [])
      |> Enum.map(&%{"option" => &1})

    params = Map.put(poll_params, "poll_options", poll_options)

    params
  end
end
