defmodule Qpoll.Polls do
  @moduledoc """
  The Polls context.
  """

  import Ecto.Query, warn: false
  alias Qpoll.Repo

  alias Qpoll.Polls.{Poll, PollOption, Vote}

  @doc """
  Returns the list of polls.

  ## Examples

      iex> list_polls()
      [%Poll{}, ...]

  """
  def list_polls do
    Repo.all(Poll)
  end

  @doc """
  Gets a single poll.

  Raises `Ecto.NoResultsError` if the Poll does not exist.

  ## Examples

      iex> get_poll!(123)
      %Poll{}

      iex> get_poll!(456)
      ** (Ecto.NoResultsError)

  """
  def get_poll!(id) do
    Poll
    |> Repo.get!(id)
    |> Repo.preload(poll_options: [:votes])
  end

  @doc """
  Creates a poll.

  ## Examples

      iex> create_poll(%{field: value})
      {:ok, %Poll{}}

      iex> create_poll(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_poll(attrs \\ %{}) do
    %Poll{}
    |> Poll.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a poll.

  ## Examples

      iex> update_poll(poll, %{field: new_value})
      {:ok, %Poll{}}

      iex> update_poll(poll, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_poll(%Poll{is_published: true} = _poll, _attrs) do
    {:error, :published_poll_cant_be_modified}
  end

  def update_poll(%Poll{} = poll, attrs) do
    poll
    |> Poll.changeset(attrs)
    |> Repo.update()
  end

  def publish_poll(%Poll{} = poll) do
    poll
    |> Poll.changeset(%{is_published: true})
    |> Repo.update()
  end

  def unpublish_poll(%Poll{} = poll) do
    poll
    |> Poll.changeset(%{is_published: false})
    |> Repo.update()
  end

  @doc """
  Deletes a poll.

  ## Examples

      iex> delete_poll(poll)
      {:ok, %Poll{}}

      iex> delete_poll(poll)
      {:error, %Ecto.Changeset{}}

  """
  def delete_poll(%Poll{} = poll) do
    Repo.delete(poll)
  end

  @doc """
  Gets a single poll_option.

  Raises `Ecto.NoResultsError` if the Poll option does not exist.

  ## Examples

      iex> get_poll_option!(123)
      %PollOption{}

      iex> get_poll_option!(456)
      ** (Ecto.NoResultsError)

  """
  #  REVIEW
  def get_poll_option!(%Poll{} = poll, id) when is_binary(id) do
    # FIXME this should raise an error
    poll_option = Enum.find(poll.poll_options, fn option -> to_string(option.id) == id end)

    case poll_option do
      %PollOption{} -> {:ok, poll_option}
      nil -> {:error, :not_found}
    end
  end

  @doc """
  Creates a poll_option for a given poll.

  ## Examples

      iex> create_poll_option(%{field: value})
      {:ok, %PollOption{}}

      iex> create_poll_option(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  #  REVIEW
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

  @doc """
  Updates a poll_option.

  ## Examples

      iex> update_poll_option(poll_option, %{field: new_value})
      {:ok, %PollOption{}}

      iex> update_poll_option(poll_option, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  #  REVIEW
  def update_poll_option(%Poll{is_published: true} = _poll, _poll_option, _attrs) do
    {:error, :published_poll_cant_be_modified}
  end

  def update_poll_option(%Poll{} = _poll, %PollOption{} = poll_option, attrs) do
    # FIXME this should check wheter option belongs to poll

    poll_option
    |> PollOption.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a poll_option.

  ## Examples

      iex> delete_poll_option(poll_option)
      {:ok, %PollOption{}}

      iex> delete_poll_option(poll_option)
      {:error, %Ecto.Changeset{}}

  """
  #  REVIEW
  def delete_poll_option(%Poll{is_published: true} = _poll, _poll_option) do
    {:error, :published_poll_cant_be_modified}
  end

  def delete_poll_option(%Poll{} = _poll, poll_option) do
    # FIXME this should check wheter option belongs to poll

    Repo.delete(poll_option)
  end

  @doc """
  Returns the list of votes for a given poll.

  ## Examples

      iex> list_poll_votes(poll_id)
      [%Vote{}, ...]

  """
  #  REVIEW
  def list_poll_votes(%Poll{} = poll) do
    Enum.flat_map(poll.poll_options, fn option -> option.votes end)
  end

  @doc """
  Gets a single vote.

  Raises `Ecto.NoResultsError` if the Vote does not exist.

  ## Examples

      iex> get_vote!(123)
      %Vote{}

      iex> get_vote!(456)
      ** (Ecto.NoResultsError)

  """
  def get_vote!(id), do: Repo.get!(Vote, id)

  @doc """
  Creates a vote for a give poll option.

  ## Examples

      iex> create_vote(%{option_id: value})
      {:ok, %Vote{}}

      iex> create_vote(%{option_id: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  #  REVIEW
  def create_vote(%Poll{is_published: false} = _poll, _attrs) do
    {:error, :unpublished_poll_cant_be_voted_on}
  end

  def create_vote(_poll, %{"option_id" => poll_option_id}) do
    # FIXME this should check whether these belong to each toher vote->option->poll?
    # FIXME mapping should be poll_option_id already?

    PollOption
    |> Repo.get(poll_option_id)
    |> Ecto.build_assoc(:votes)
    |> Repo.insert()
  end
end
