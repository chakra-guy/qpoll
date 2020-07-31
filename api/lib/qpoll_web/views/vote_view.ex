defmodule QpollWeb.VoteView do
  use QpollWeb, :view
  alias QpollWeb.VoteView

  def render("show.json", %{vote: vote}) do
    %{data: render_one(vote, VoteView, "vote.json")}
  end

  def render("vote.json", %{vote: vote}) do
    %{id: vote.id, option_id: vote.poll_option_id}
  end
end
