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

    def published_poll_with_votes_fixture() do
      {:ok, poll} = poll_fixture(@with_options_attrs) |> Polls.publish_poll()

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
      {:ok, poll_option} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Polls.create_poll_option()

      poll_option
    end

    test "list_poll_options/0 returns all poll_options" do
      poll_option = poll_option_fixture()
      assert Polls.list_poll_options() == [poll_option]
    end

    test "get_poll_option!/1 returns the poll_option with given id" do
      poll_option = poll_option_fixture()
      assert Polls.get_poll_option!(poll_option.id) == poll_option
    end

    test "create_poll_option/1 with valid data creates a poll_option" do
      assert {:ok, %PollOption{} = poll_option} = Polls.create_poll_option(@valid_attrs)
      assert poll_option.option == "some option"
    end

    test "create_poll_option/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Polls.create_poll_option(@invalid_attrs)
    end

    test "update_poll_option/2 with valid data updates the poll_option" do
      poll_option = poll_option_fixture()

      assert {:ok, %PollOption{} = poll_option} =
               Polls.update_poll_option(poll_option, @update_attrs)

      assert poll_option.option == "some updated option"
    end

    test "update_poll_option/2 with invalid data returns error changeset" do
      poll_option = poll_option_fixture()
      assert {:error, %Ecto.Changeset{}} = Polls.update_poll_option(poll_option, @invalid_attrs)
      assert poll_option == Polls.get_poll_option!(poll_option.id)
    end

    test "delete_poll_option/1 deletes the poll_option" do
      poll_option = poll_option_fixture()
      assert {:ok, %PollOption{}} = Polls.delete_poll_option(poll_option)
      assert_raise Ecto.NoResultsError, fn -> Polls.get_poll_option!(poll_option.id) end
    end

    test "change_poll_option/1 returns a poll_option changeset" do
      poll_option = poll_option_fixture()
      assert %Ecto.Changeset{} = Polls.change_poll_option(poll_option)
    end
  end

  describe "votes" do
    alias Qpoll.Polls.Vote

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def vote_fixture(attrs \\ %{}) do
      {:ok, vote} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Polls.create_vote()

      vote
    end

    test "list_poll_votes/0 returns all votes" do
      vote = vote_fixture()
      assert Polls.list_poll_votes() == [vote]
    end

    test "get_vote!/1 returns the vote with given id" do
      vote = vote_fixture()
      assert Polls.get_vote!(vote.id) == vote
    end

    test "create_vote/1 with valid data creates a vote" do
      assert {:ok, %Vote{} = vote} = Polls.create_vote(@valid_attrs)
    end

    test "create_vote/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Polls.create_vote(@invalid_attrs)
    end

    test "update_vote/2 with valid data updates the vote" do
      vote = vote_fixture()
      assert {:ok, %Vote{} = vote} = Polls.update_vote(vote, @update_attrs)
    end

    test "update_vote/2 with invalid data returns error changeset" do
      vote = vote_fixture()
      assert {:error, %Ecto.Changeset{}} = Polls.update_vote(vote, @invalid_attrs)
      assert vote == Polls.get_vote!(vote.id)
    end

    test "delete_vote/1 deletes the vote" do
      vote = vote_fixture()
      assert {:ok, %Vote{}} = Polls.delete_vote(vote)
      assert_raise Ecto.NoResultsError, fn -> Polls.get_vote!(vote.id) end
    end

    test "change_vote/1 returns a vote changeset" do
      vote = vote_fixture()
      assert %Ecto.Changeset{} = Polls.change_vote(vote)
    end
  end
end
