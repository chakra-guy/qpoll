defmodule QpollWeb.PollOptionView do
  use QpollWeb, :view
  alias QpollWeb.{PollOptionView, VoteView}

  def render("index.json", %{poll_options: poll_options}) do
    %{data: render_many(poll_options, PollOptionView, "poll_option.json")}
  end

  def render("show.json", %{poll_option: poll_option}) do
    %{data: render_one(poll_option, PollOptionView, "poll_option.json")}
  end

  def render("poll_option.json", %{poll_option: poll_option}) do
    %{
      id: poll_option.id,
      option: poll_option.option,
      vote_count: Enum.count(poll_option.votes)
    }
  end
end
