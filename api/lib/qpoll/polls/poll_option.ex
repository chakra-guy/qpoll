defmodule Qpoll.Polls.PollOption do
  use Ecto.Schema
  import Ecto.Changeset

  schema "poll_options" do
    field :option, :string
    field :poll_id, :id

    timestamps()
  end

  @doc false
  def changeset(poll_option, attrs) do
    poll_option
    |> cast(attrs, [:option])
    |> validate_required([:option])
  end
end
