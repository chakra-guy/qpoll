defmodule QpollWeb.VoteControllerTest do
  use QpollWeb.ConnCase

  alias Qpoll.Polls
  alias Qpoll.Polls.PollOption
  alias QpollWeb.Endpoint

  @create_poll_with_options_attrs %{
    question: "some question",
    poll_options: [%{option: "A"}, %{option: "B"}]
  }
  @create_poll_option_attrs %{option: "A"}

  def fixture(:published_poll) do
    {:ok, poll} = Polls.create_poll(@create_poll_with_options_attrs)
    {:ok, _} = Polls.get_poll!(poll.id) |> Polls.publish_poll()
    Polls.get_poll!(poll.id)
  end

  def fixture(:poll_option) do
    {:ok, poll} = Polls.create_poll(@create_poll_with_options_attrs)
    {:ok, poll_option} = Polls.create_poll_option(poll, @create_poll_option_attrs)
    Polls.get_poll_option!(poll_option.id)
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create vote" do
    test "renders vote when data is valid, updates vote count and broadcast new vote", %{
      conn: conn
    } do
      poll = fixture(:published_poll)
      [%PollOption{id: id} | _] = poll.poll_options

      Endpoint.subscribe("poll:#{poll.id}")

      conn = post(conn, Routes.vote_path(conn, :create, poll.id), vote: %{"option_id" => id})

      assert_receive %Phoenix.Socket.Broadcast{event: "new_vote", payload: %{poll_option_id: id}}
      assert %{"id" => _} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.poll_option_path(conn, :show, poll.id, id))

      assert %{"vote_count" => 1} = json_response(conn, 200)["data"]

      Endpoint.unsubscribe("poll:#{poll.id}")
    end

    test "renders errors when option does not belong to poll", %{conn: conn} do
      poll = fixture(:published_poll)
      poll_option = fixture(:poll_option)

      conn =
        post(conn, Routes.vote_path(conn, :create, poll.id),
          vote: %{"option_id" => poll_option.id}
        )

      assert json_response(conn, 409)["errors"]["detail"] == "Voted option doesn't belong to poll"
    end
  end

  defp create_vote(_) do
    vote = fixture(:vote)
    {:ok, vote: vote}
  end
end
