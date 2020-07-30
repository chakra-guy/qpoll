defmodule QpollWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use QpollWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(QpollWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(QpollWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :voted_option_doesnt_belong_to_poll}) do
    conn
    |> put_status(:conflict)
    |> put_view(QpollWeb.ErrorView)
    |> render("voted_option_doesnt_belong_to_poll.json")
  end

  #  REVIEW
  def call(conn, {:error, :published_poll_cant_be_modified}) do
    conn
    |> put_status(:conflict)
    |> put_view(QpollWeb.ErrorView)
    |> render("published_poll_cant_be_modified.json")
  end

  #  REVIEW
  def call(conn, {:error, :unpublished_poll_cant_be_voted_on}) do
    conn
    |> put_status(:conflict)
    |> put_view(QpollWeb.ErrorView)
    |> render("unpublished_poll_cant_be_voted_on.json")
  end
end
