defmodule Qpoll.Polls.Vote do
  use Ecto.Schema
  import Ecto.Changeset
  alias Qpoll.Polls.PollOption

  schema "votes" do
    timestamps()

    belongs_to(:poll_option, PollOption)
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [])
    |> assoc_constraint(:poll_option)
    |> validate_required([])
  end
end
