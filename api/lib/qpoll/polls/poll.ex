defmodule Qpoll.Polls.Poll do
  use Ecto.Schema
  import Ecto.Changeset
  alias Qpoll.Polls.PollOption

  schema "polls" do
    field(:question, :string)
    field :is_published, :boolean, default: false
    timestamps()

    has_many(:poll_options, PollOption, on_replace: :delete)
    has_many(:votes, through: [:poll_options, :votes])
  end

  #  REVIEW
  @doc false
  def changeset(poll, attrs) do
    poll
    |> cast(attrs, [:question, :is_published])
    |> cast_assoc(:poll_options)
    |> validate_required([:question])
  end
end
