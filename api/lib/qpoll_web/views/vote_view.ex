defmodule QpollWeb.VoteView do
  use QpollWeb, :view
  alias QpollWeb.VoteView

  # REVIEW
  def render("index.json", %{votes: votes}) do
    counted_votes =
      Enum.reduce(votes, %{}, fn vote, acc ->
        Map.update(acc, vote.poll_option_id, 1, &(&1 + 1))
      end)
      |> Enum.map(fn {poll_option_id, count} ->
        %{poll_option_id: poll_option_id, count: count}
      end)

    %{data: render_many(counted_votes, VoteView, "counted_vote.json")}
  end

  def render("show.json", %{vote: vote}) do
    %{data: render_one(vote, VoteView, "vote.json")}
  end

  def render("vote.json", %{vote: vote}) do
    %{id: vote.id, option_id: vote.poll_option_id}
  end

  def render("counted_vote.json", %{vote: vote}) do
    %{option_id: vote.poll_option_id, vote_count: vote.count}
  end
end
