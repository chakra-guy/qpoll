defmodule Qpoll.Polls do
  @moduledoc """
  The Polls context.
  """

  import Ecto.Query, warn: false
  alias Qpoll.Repo

  alias Qpoll.Polls.Poll

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
  def get_poll!(id), do: Repo.get!(Poll, id)

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
  def update_poll(%Poll{} = poll, attrs) do
    poll
    |> Poll.changeset(attrs)
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
  Returns an `%Ecto.Changeset{}` for tracking poll changes.

  ## Examples

      iex> change_poll(poll)
      %Ecto.Changeset{source: %Poll{}}

  """
  def change_poll(%Poll{} = poll) do
    Poll.changeset(poll, %{})
  end

  alias Qpoll.Polls.PollOption

  @doc """
  Returns the list of poll_options.

  ## Examples

      iex> list_poll_options()
      [%PollOption{}, ...]

  """
  def list_poll_options do
    Repo.all(PollOption)
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
  def get_poll_option!(id), do: Repo.get!(PollOption, id)

  @doc """
  Creates a poll_option.

  ## Examples

      iex> create_poll_option(%{field: value})
      {:ok, %PollOption{}}

      iex> create_poll_option(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_poll_option(attrs \\ %{}) do
    %PollOption{}
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
  def update_poll_option(%PollOption{} = poll_option, attrs) do
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
  def delete_poll_option(%PollOption{} = poll_option) do
    Repo.delete(poll_option)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking poll_option changes.

  ## Examples

      iex> change_poll_option(poll_option)
      %Ecto.Changeset{source: %PollOption{}}

  """
  def change_poll_option(%PollOption{} = poll_option) do
    PollOption.changeset(poll_option, %{})
  end
end
