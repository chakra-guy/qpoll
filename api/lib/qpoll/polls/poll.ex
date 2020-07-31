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

  # REVIEW
  def changeset(poll, attrs) do
    poll
    |> cast(attrs, [:question])
    |> cast_assoc(:poll_options)
    |> validate_required([:question])
  end

  def publish_changeset(poll) do
    poll
    |> cast(%{is_published: true}, [:is_published])
    |> validate_min_options_count(2)
  end

  def unpublish_changeset(poll) do
    poll
    |> cast(%{is_published: false}, [:is_published])
  end

  defp validate_min_options_count(changeset, count) do
    poll_options = get_field(changeset, :poll_options, [])

    case length(poll_options) >= count do
      true -> changeset
      false -> add_error(changeset, :poll_options, "should have at least #{count} option(s)")
    end
  end
end
