defmodule Licantro.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes, primary_key: false) do
      add :poll_id, references(:polls, on_delete: :delete_all, type: :binary_id),
        primary_key: true

      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id),
        primary_key: true

      add :vote_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:votes, [:poll_id])
    create index(:votes, [:user_id])
    create index(:votes, [:vote_id])
  end
end
