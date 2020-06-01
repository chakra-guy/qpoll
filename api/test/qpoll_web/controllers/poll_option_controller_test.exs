defmodule QpollWeb.PollOptionControllerTest do
  use QpollWeb.ConnCase

  alias Qpoll.Polls
  alias Qpoll.Polls.PollOption

  @create_attrs %{
    option: "some option"
  }
  @update_attrs %{
    option: "some updated option"
  }
  @invalid_attrs %{option: nil}

  def fixture(:poll_option) do
    {:ok, poll_option} = Polls.create_poll_option(@create_attrs)
    poll_option
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all poll_options", %{conn: conn} do
      conn = get(conn, Routes.poll_option_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create poll_option" do
    test "renders poll_option when data is valid", %{conn: conn} do
      conn = post(conn, Routes.poll_option_path(conn, :create), poll_option: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.poll_option_path(conn, :show, id))

      assert %{
               "id" => id,
               "option" => "some option"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.poll_option_path(conn, :create), poll_option: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update poll_option" do
    setup [:create_poll_option]

    test "renders poll_option when data is valid", %{conn: conn, poll_option: %PollOption{id: id} = poll_option} do
      conn = put(conn, Routes.poll_option_path(conn, :update, poll_option), poll_option: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.poll_option_path(conn, :show, id))

      assert %{
               "id" => id,
               "option" => "some updated option"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, poll_option: poll_option} do
      conn = put(conn, Routes.poll_option_path(conn, :update, poll_option), poll_option: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete poll_option" do
    setup [:create_poll_option]

    test "deletes chosen poll_option", %{conn: conn, poll_option: poll_option} do
      conn = delete(conn, Routes.poll_option_path(conn, :delete, poll_option))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.poll_option_path(conn, :show, poll_option))
      end
    end
  end

  defp create_poll_option(_) do
    poll_option = fixture(:poll_option)
    {:ok, poll_option: poll_option}
  end
end
