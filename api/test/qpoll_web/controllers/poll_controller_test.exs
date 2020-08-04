defmodule QpollWeb.PollControllerTest do
  use QpollWeb.ConnCase

  alias Qpoll.Polls
  alias Qpoll.Polls.Poll

  @create_attrs %{
    question: "some question"
  }
  @update_attrs %{
    question: "some updated question"
  }
  @invalid_attrs %{question: nil}

  def fixture(:poll) do
    {:ok, poll} = Polls.create_poll(@create_attrs)
    poll
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all polls", %{conn: conn} do
      conn = get(conn, Routes.poll_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create poll" do
    test "renders poll when data is valid", %{conn: conn} do
      conn = post(conn, Routes.poll_path(conn, :create), poll: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.poll_path(conn, :show, id))

      assert %{
               "id" => id,
               "question" => "some question"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.poll_path(conn, :create), poll: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update poll" do
    setup [:create_poll]

    test "renders poll when data is valid", %{conn: conn, poll: %Poll{id: id} = poll} do
      conn = put(conn, Routes.poll_path(conn, :update, poll), poll: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.poll_path(conn, :show, id))

      assert %{
               "id" => id,
               "question" => "some updated question"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when poll is published", %{conn: conn, poll: poll} do
      poll = publish_poll_fixture(poll)
      conn = put(conn, Routes.poll_path(conn, :update, poll), poll: @invalid_attrs)

      assert json_response(conn, 409)["errors"]["detail"] ==
               "Poll can't be modified when it's published"
    end

    test "renders errors when data is invalid", %{conn: conn, poll: poll} do
      conn = put(conn, Routes.poll_path(conn, :update, poll), poll: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete poll" do
    setup [:create_poll]

    test "deletes chosen poll", %{conn: conn, poll: poll} do
      conn = delete(conn, Routes.poll_path(conn, :delete, poll))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.poll_path(conn, :show, poll))
      end
    end
  end

  describe "publish poll" do
    setup [:create_poll_with_options]

    test "publishes chosen poll", %{conn: conn, poll: poll} do
      conn = post(conn, Routes.poll_path(conn, :publish, poll))
      assert %{"id" => id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.poll_path(conn, :show, id))

      assert %{
               "id" => id,
               "is_publised" => true
             } = json_response(conn, 200)["data"]
    end
  end

  describe "unpublish poll" do
    setup [:create_published_poll_with_votes]

    test "unpublishes chosen poll and resets vote count", %{conn: conn, poll: poll} do
      conn = post(conn, Routes.poll_path(conn, :unpublish, poll))
      assert %{"id" => id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.poll_path(conn, :show, id))

      assert %{
               "id" => id,
               "is_publised" => false
             } = json_response(conn, 200)["data"]

      assert [%{"vote_count" => 0}, %{"vote_count" => 0}] =
               json_response(conn, 200)["data"]["options"]
    end
  end

  defp create_poll(_) do
    poll = fixture(:poll)
    {:ok, poll: poll}
  end

  defp create_poll_with_options(_) do
    poll = fixture(:poll)
    {:ok, _} = Polls.create_poll_option(poll, %{option: "A"})
    {:ok, _} = Polls.create_poll_option(poll, %{option: "B"})

    {:ok, poll: Polls.get_poll!(poll.id)}
  end

  defp create_published_poll_with_votes(_) do
    poll = fixture(:poll) |> publish_poll_fixture
    [%Polls.PollOption{id: poll_option_id} | _] = poll.poll_options
    poll_option = Polls.get_poll_option!(poll_option_id)
    {:ok, _} = Polls.create_vote(poll_option)
    {:ok, _} = Polls.create_vote(poll_option)

    {:ok, poll: Polls.get_poll!(poll.id)}
  end

  defp publish_poll_fixture(poll) do
    {:ok, _} = Polls.create_poll_option(poll, %{option: "A"})
    {:ok, _} = Polls.create_poll_option(poll, %{option: "B"})
    {:ok, _} = Polls.get_poll!(poll.id) |> Polls.publish_poll()

    Polls.get_poll!(poll.id)
  end
end
