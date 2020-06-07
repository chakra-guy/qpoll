defmodule Qpoll.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add(:poll_option_id, references(:poll_options, on_delete: :delete_all))

      timestamps()
    end

    create(index(:votes, [:poll_option_id]))
  end
end
