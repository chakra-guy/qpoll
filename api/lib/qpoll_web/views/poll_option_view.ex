defmodule QpollWeb.PollOptionView do
  use QpollWeb, :view
  alias Ecto
  alias QpollWeb.PollOptionView

  def render("index.json", %{poll_options: poll_options}) do
    %{data: render_many(poll_options, PollOptionView, "poll_option.json")}
  end

  def render("show.json", %{poll_option: poll_option}) do
    %{data: render_one(poll_option, PollOptionView, "poll_option.json")}
  end

  # REVIEW
  def render("poll_option.json", %{poll_option: %{id: id, option: option, votes: votes}}) do
    vote_count = if Ecto.assoc_loaded?(votes), do: Enum.count(votes), else: 0

    %{
      id: id,
      option: option,
      vote_count: vote_count
    }
  end
end
