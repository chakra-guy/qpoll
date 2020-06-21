defmodule Qpoll.Polls.PollOption do
  use Ecto.Schema
  import Ecto.Changeset
  alias Qpoll.Polls.{Poll, Vote}

  schema "poll_options" do
    field(:option, :string)
    timestamps()

    belongs_to(:poll, Poll)
    has_many(:votes, Vote)
  end

  #  REVIEW
  @doc false
  def changeset(poll_option, attrs) do
    poll_option
    |> cast(attrs, [:option])
    |> assoc_constraint(:poll)
    |> validate_required([:option])
  end
end
