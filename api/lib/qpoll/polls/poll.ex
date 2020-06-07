defmodule Qpoll.Polls.Poll do
  use Ecto.Schema
  import Ecto.Changeset
  alias Qpoll.Polls.PollOption

  schema "polls" do
    field(:question, :string)
    timestamps()

    has_many(:poll_options, PollOption, on_replace: :delete)
    has_many(:votes, through: [:poll_options, :votes])
  end

  @doc false
  def changeset(poll, attrs) do
    poll
    |> cast(attrs, [:question])
    |> cast_assoc(:poll_options)
    |> validate_required([:question])
  end
end
