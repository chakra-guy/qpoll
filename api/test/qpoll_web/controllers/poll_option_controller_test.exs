defmodule QpollWeb.PollOptionControllerTest do
  use QpollWeb.ConnCase

  alias Qpoll.Polls
  alias Qpoll.Polls.PollOption

  @create_poll_attrs %{question: "some question", poll_options: []}
  @create_poll_option_attrs %{question: "some question", poll_options: [%{option: "some option"}]}
  @create_poll_options_attrs %{
    question: "some question",
    poll_options: [%{option: "A"}, %{option: "B"}]
  }
  @create_attrs %{option: "some option"}
  @update_attrs %{option: "some updated option"}
  @invalid_attrs %{option: nil}

  def fixture(:poll) do
    {:ok, poll} = Polls.create_poll(@create_poll_attrs)
    poll
  end

  def fixture(:poll_with_option) do
    {:ok, poll} = Polls.create_poll(@create_poll_option_attrs)
    poll
  end

  def fixture(:published_poll) do
    {:ok, poll} = Polls.create_poll(@create_poll_options_attrs)
    {:ok, _} = Polls.get_poll!(poll.id) |> Polls.publish_poll()
    Polls.get_poll!(poll.id)
  end

  def fixture(:poll_option) do
    poll = fixture(:poll_with_option)
    [%PollOption{} = poll_option | _] = poll.poll_options
    poll_option
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all poll_options", %{conn: conn} do
      poll = fixture(:poll)
      conn = get(conn, Routes.poll_option_path(conn, :index, poll.id))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create poll_option" do
    test "renders poll_option when data is valid", %{conn: conn} do
      poll = fixture(:poll)

      conn =
        post(conn, Routes.poll_option_path(conn, :create, poll.id), poll_option: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.poll_option_path(conn, :show, poll.id, id))

      assert %{
               "id" => id,
               "option" => "some option"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when poll is published", %{conn: conn} do
      poll = fixture(:published_poll)

      conn =
        post(conn, Routes.poll_option_path(conn, :create, poll.id), poll_option: @create_attrs)

      assert json_response(conn, 409)["errors"]["detail"] ==
               "Poll can't be modified when it's published"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      poll = fixture(:poll)

      conn =
        post(conn, Routes.poll_option_path(conn, :create, poll.id), poll_option: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update poll_option" do
    test "renders poll_option when data is valid", %{conn: conn} do
      %PollOption{poll_id: poll_id, id: id} = fixture(:poll_option)

      conn =
        put(conn, Routes.poll_option_path(conn, :update, poll_id, id), poll_option: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.poll_option_path(conn, :show, poll_id, id))

      assert %{
               "id" => ^id,
               "option" => "some updated option"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when poll is published", %{conn: conn} do
      poll = fixture(:published_poll)
      [%PollOption{id: id} | _] = poll.poll_options

      conn =
        put(conn, Routes.poll_option_path(conn, :update, poll.id, id), poll_option: @update_attrs)

      assert json_response(conn, 409)["errors"]["detail"] ==
               "Poll can't be modified when it's published"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      %PollOption{poll_id: poll_id, id: id} = fixture(:poll_option)

      conn =
        put(conn, Routes.poll_option_path(conn, :update, poll_id, id), poll_option: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete poll_option" do
    test "deletes chosen poll_option", %{conn: conn} do
      %PollOption{poll_id: poll_id, id: id} = fixture(:poll_option)
      conn = delete(conn, Routes.poll_option_path(conn, :delete, poll_id, id))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.poll_option_path(conn, :show, poll_id, id))
      end
    end

    test "renders errors when poll is published", %{conn: conn} do
      poll = fixture(:published_poll)
      [%PollOption{id: id} | _] = poll.poll_options

      conn = delete(conn, Routes.poll_option_path(conn, :delete, poll.id, id))

      assert json_response(conn, 409)["errors"]["detail"] ==
               "Poll can't be modified when it's published"
    end
  end
end
