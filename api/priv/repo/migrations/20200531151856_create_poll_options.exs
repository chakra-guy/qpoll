defmodule Qpoll.Repo.Migrations.CreatePollOptions do
  use Ecto.Migration

  def change do
    create table(:poll_options) do
      add(:option, :string, null: false)
      add(:poll_id, references(:polls, on_delete: :delete_all))

      timestamps()
    end

    create(index(:poll_options, [:poll_id]))
  end
end
