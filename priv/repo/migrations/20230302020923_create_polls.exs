defmodule Licantro.Repo.Migrations.CreatePolls do
  use Ecto.Migration

  def change do
    create table(:polls, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :opened_at, :naive_datetime
      add :closed_at, :naive_datetime
      add :game_id, references(:games, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:polls, [:game_id])
  end
end
