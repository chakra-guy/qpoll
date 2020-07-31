defmodule Qpoll.Polls do
  import Ecto.Query, warn: false
  alias Qpoll.Repo
  alias Ecto.Multi

  alias Qpoll.Polls.{Poll, PollOption, Vote}

  # POLL

  def list_polls do
    Repo.all(Poll)
  end

  def get_poll!(id) do
    Poll
    |> Repo.get!(id)
    |> Repo.preload(poll_options: [:votes])
  end

  def create_poll(attrs \\ %{}) do
    %Poll{}
    |> Poll.changeset(attrs)
    |> Repo.insert()
  end

  def update_poll(%Poll{is_published: true} = _poll, _attrs) do
    {:error, :published_poll_cant_be_modified}
  end

  def update_poll(%Poll{} = poll, attrs) do
    poll
    |> Poll.changeset(attrs)
    |> Repo.update()
  end

  def delete_poll(%Poll{} = poll) do
    Repo.delete(poll)
  end

  def publish_poll(%Poll{} = poll) do
    poll
    |> Poll.publish_changeset()
    |> Repo.update()
  end

  def unpublish_poll(%Poll{} = poll) do
    poll_changeset = Poll.unpublish_changeset(poll)
    poll_option_ids = Enum.map(poll.poll_options, fn poll_option -> poll_option.id end)
    poll_votes_query = from(v in Vote, where: v.poll_option_id in ^poll_option_ids)

    result =
      Multi.new()
      |> Multi.update(:update_poll, poll_changeset)
      |> Multi.delete_all(:delete_votes, poll_votes_query)
      |> Repo.transaction()

    case result do
      {:ok, %{update_poll: poll}} ->
        {:ok, poll}

      {:error, _failed_operation, _failed_value, _changes_so_far} ->
        {:error, "Something went wrong while unpublishing a poll"}
    end
  end

  # POLL OPTION

  def get_poll_option!(id) do
    PollOption
    |> Repo.get!(id)
    |> Repo.preload(:poll)
  end

  def create_poll_option(poll, attrs \\ %{})

  def create_poll_option(%Poll{is_published: true} = _poll, _attrs) do
    {:error, :published_poll_cant_be_modified}
  end

  def create_poll_option(%Poll{} = poll, attrs) do
    poll
    |> Ecto.build_assoc(:poll_options)
    |> PollOption.changeset(attrs)
    |> Repo.insert()
  end

  def update_poll_option(%PollOption{poll: %{is_published: true}} = _poll_option, _attrs) do
    {:error, :published_poll_cant_be_modified}
  end

  def update_poll_option(%PollOption{} = poll_option, attrs) do
    poll_option
    |> PollOption.changeset(attrs)
    |> Repo.update()
  end

  def delete_poll_option(%PollOption{poll: %{is_published: true}} = _poll_option) do
    {:error, :published_poll_cant_be_modified}
  end

  def delete_poll_option(%PollOption{} = poll_option) do
    Repo.delete(poll_option)
  end

  # VOTES

  def create_vote(%PollOption{poll: %{is_published: false}} = _poll_option) do
    {:error, :unpublished_poll_cant_be_voted_on}
  end

  def create_vote(%PollOption{} = poll_option) do
    poll_option
    |> Ecto.build_assoc(:votes)
    |> Repo.insert()
  end
end
