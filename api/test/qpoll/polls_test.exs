defmodule Qpoll.PollsTest do
  use Qpoll.DataCase

  alias Qpoll.Repo
  alias Qpoll.Polls

  describe "polls" do
    alias Qpoll.Polls.{Poll, PollOption}

    @valid_attrs %{question: "some question"}
    @update_attrs %{question: "some updated question"}
    @invalid_attrs %{question: nil}
    @without_options_attrs %{question: "some question"}
    @with_options_attrs %{
      question: "some question",
      poll_options: [%{option: "A"}, %{option: "B"}]
    }
    @with_new_options_attrs %{
      poll_options: [%{option: "C"}, %{option: "D"}]
    }

    def poll_fixture(attrs \\ %{}) do
      {:ok, poll} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Polls.create_poll()

      poll
    end

    def published_poll_fixture() do
      {:ok, poll} = poll_fixture(@with_options_attrs) |> Polls.publish_poll()

      poll
    end

    def published_poll_with_votes_fixture() do
      poll = published_poll_fixture()

      [%PollOption{id: poll_option_id} | _] = poll.poll_options

      {:ok, _vote} =
        poll_option_id
        |> Polls.get_poll_option!()
        |> Polls.create_vote()

      Polls.get_poll!(poll.id)
    end

    test "list_polls/0 returns all polls" do
      poll = poll_fixture()
      assert Polls.list_polls() == [poll]
    end

    test "get_poll!/1 returns the poll with given id" do
      poll = poll_fixture() |> Repo.preload(poll_options: [:votes])
      assert Polls.get_poll!(poll.id) == poll
    end

    test "create_poll/1 with valid data creates a poll" do
      assert {:ok, %Poll{} = poll} = Polls.create_poll(@valid_attrs)
      assert poll.question == "some question"
    end

    test "create_poll/1 with options create a poll with options" do
      assert {:ok, %Poll{} = poll} = Polls.create_poll(@with_options_attrs)
      assert poll.question == "some question"
      assert [%PollOption{option: "A"}, %PollOption{option: "B"}] = poll.poll_options
    end

    test "create_poll/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Polls.create_poll(@invalid_attrs)
    end

    test "publish_poll/1 with a poll that has atleast 2 options publishes the poll" do
      poll = poll_fixture(@with_options_attrs)
      assert {:ok, %Poll{} = poll} = Polls.publish_poll(poll)
      assert poll.is_published
    end

    test "publish_poll/1 with a poll that has atleast 2 options returns error changeset" do
      poll = poll_fixture(@without_options_attrs) |> Repo.preload(poll_options: [:votes])
      changeset_error = [poll_options: {"should have at least 2 option(s)", []}]
      assert {:error, %Ecto.Changeset{errors: ^changeset_error}} = Polls.publish_poll(poll)
    end

    test "unpublish_poll/1 with a poll unpublishes the poll and deletes all the votes" do
      poll = published_poll_with_votes_fixture() |> Repo.preload(:votes)

      assert poll.is_published
      assert length(poll.votes) > 0
      assert {:ok, poll} = Polls.unpublish_poll(poll)

      poll = Repo.preload(poll, :votes)

      assert poll.is_published == false
      assert length(poll.votes) == 0
    end

    test "update_poll/2 with valid data updates the poll" do
      poll = poll_fixture()
      assert {:ok, %Poll{} = poll} = Polls.update_poll(poll, @update_attrs)
      assert poll.question == "some updated question"
    end

    test "update_poll/2 with new options updates the poll options" do
      poll = poll_fixture() |> Repo.preload(poll_options: [:votes])
      assert {:ok, %Poll{} = poll} = Polls.update_poll(poll, @with_new_options_attrs)
      assert poll.question == "some question"
      assert [%PollOption{option: "C"}, %PollOption{option: "D"}] = poll.poll_options
    end

    test "update_poll/2 with invalid data returns error changeset" do
      poll = poll_fixture() |> Repo.preload(poll_options: [:votes])
      assert {:error, %Ecto.Changeset{}} = Polls.update_poll(poll, @invalid_attrs)
      assert poll == Polls.get_poll!(poll.id)
    end

    test "update_poll/2 with already published poll returns error" do
      poll = published_poll_with_votes_fixture()
      assert %Poll{is_published: true} = poll
      assert {:error, :published_poll_cant_be_modified} = Polls.update_poll(poll, @update_attrs)
      assert poll == Polls.get_poll!(poll.id)
    end

    test "delete_poll/1 deletes the poll" do
      poll = poll_fixture()
      assert {:ok, %Poll{}} = Polls.delete_poll(poll)
      assert_raise Ecto.NoResultsError, fn -> Polls.get_poll!(poll.id) end
    end
  end

  describe "poll_options" do
    alias Qpoll.Polls.PollOption

    @valid_attrs %{option: "some option"}
    @update_attrs %{option: "some updated option"}
    @invalid_attrs %{option: nil}

    def poll_option_fixture(attrs \\ %{}) do
      attrs = Enum.into(attrs, @valid_attrs)
      {:ok, poll} = Polls.create_poll(%{question: "some question"})
      {:ok, poll_option} = Polls.create_poll_option(poll, attrs)

      poll_option
    end

    test "get_poll_option!/1 returns the poll_option with given id" do
      poll_option = poll_option_fixture() |> Repo.preload([:poll, :votes])
      assert Polls.get_poll_option!(poll_option.id) == poll_option
    end

    test "create_poll_option/1 with valid data creates a poll_option" do
      poll = poll_fixture()
      assert {:ok, %PollOption{} = poll_option} = Polls.create_poll_option(poll, @valid_attrs)
      assert poll_option.option == "some option"
    end

    test "create_poll_option/1 with published poll returns error" do
      poll = published_poll_fixture()

      assert {:error, :published_poll_cant_be_modified} =
               Polls.create_poll_option(poll, @valid_attrs)
    end

    test "create_poll_option/1 with invalid data returns error changeset" do
      poll = poll_fixture()
      assert {:error, %Ecto.Changeset{}} = Polls.create_poll_option(poll, @invalid_attrs)
    end

    test "update_poll_option/2 with valid data updates the poll_option" do
      poll_option = poll_option_fixture() |> Repo.preload(:poll)

      assert {:ok, %PollOption{} = poll_option} =
               Polls.update_poll_option(poll_option, @update_attrs)

      assert poll_option.option == "some updated option"
    end

    test "update_poll_option/2 with published poll returns error" do
      poll = published_poll_fixture()
      [%PollOption{id: poll_option_id} | _] = poll.poll_options
      poll_option = Polls.get_poll_option!(poll_option_id)

      assert {:error, :published_poll_cant_be_modified} =
               Polls.update_poll_option(poll_option, @update_attrs)

      assert poll_option == Polls.get_poll_option!(poll_option.id)
    end

    test "update_poll_option/2 with invalid data returns error changeset" do
      poll_option = poll_option_fixture() |> Repo.preload([:poll, :votes])
      assert {:error, %Ecto.Changeset{}} = Polls.update_poll_option(poll_option, @invalid_attrs)
      assert poll_option == Polls.get_poll_option!(poll_option.id)
    end

    test "delete_poll_option/1 deletes the poll_option" do
      poll_option = poll_option_fixture() |> Repo.preload(:poll)
      assert {:ok, %PollOption{}} = Polls.delete_poll_option(poll_option)
      assert_raise Ecto.NoResultsError, fn -> Polls.get_poll_option!(poll_option.id) end
    end

    test "delete_poll_option/1 wiht published poll return error" do
      poll = published_poll_fixture()
      [%PollOption{id: poll_option_id} | _] = poll.poll_options
      poll_option = Polls.get_poll_option!(poll_option_id)

      assert {:error, :published_poll_cant_be_modified} = Polls.delete_poll_option(poll_option)

      assert poll_option == Polls.get_poll_option!(poll_option.id)
    end

    test "option_belongs_to_poll?/1 returns a poll_option when it belongs to the poll" do
      poll_option = poll_option_fixture() |> Repo.preload(:poll)
      poll_id = to_string(poll_option.poll.id)
      assert {:ok, poll_option} = Polls.option_belongs_to_poll?(poll_id, poll_option)
    end

    test "option_belongs_to_poll?/1 returns an error when it does not belongs to the poll" do
      poll_option = poll_option_fixture()

      assert {:error, :voted_option_doesnt_belong_to_poll} =
               Polls.option_belongs_to_poll?("404", poll_option)
    end
  end

  describe "votes" do
    alias Qpoll.Polls.{PollOption, Vote}

    test "create_vote/1 with published poll creates a vote" do
      poll = published_poll_fixture()
      [%PollOption{id: poll_option_id} | _] = poll.poll_options
      poll_option = Polls.get_poll_option!(poll_option_id)
      assert {:ok, %Vote{} = vote} = Polls.create_vote(poll_option)
    end

    test "create_vote/1 with unpublished poll return error" do
      poll = poll_fixture(@with_options_attrs)
      [%PollOption{id: poll_option_id} | _] = poll.poll_options
      poll_option = Polls.get_poll_option!(poll_option_id)
      assert {:error, :unpublished_poll_cant_be_voted_on} = Polls.create_vote(poll_option)
    end
  end
end
