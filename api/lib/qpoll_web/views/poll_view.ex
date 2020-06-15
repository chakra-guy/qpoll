defmodule QpollWeb.PollView do
  use QpollWeb, :view
  alias QpollWeb.{PollView, PollOptionView}

  def render("index.json", %{polls: polls}) do
    %{data: render_many(polls, PollView, "poll.json")}
  end

  def render("show.json", %{poll: poll}) do
    %{data: render_one(poll, PollView, "poll_with_options.json")}
  end

  def render("poll.json", %{poll: poll}) do
    %{
      id: poll.id,
      question: poll.question,
      is_publised: poll.is_published
    }
  end

  def render("poll_with_options.json", %{poll: poll}) do
    %{
      id: poll.id,
      question: poll.question,
      is_publised: poll.is_published,
      options: render_many(poll.poll_options, PollOptionView, "poll_option.json")
    }
  end
end
