defmodule Licantro.Repo.Migrations.CreatePollsUsers do
  use Ecto.Migration

  def change do
    create table(:polls_users, primary_key: false) do
      add :poll_id, references(:polls, on_delete: :delete_all, type: :binary_id),
        primary_key: true

      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id),
        primary_key: true

      add :vote_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:polls_users, [:poll_id])
    create index(:polls_users, [:user_id])
  end
end
