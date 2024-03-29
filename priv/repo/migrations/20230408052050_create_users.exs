defmodule Licantro.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :uid, :string
      add :name, :string
      add :role, :string

      timestamps()
    end

    create unique_index(:users, [:uid])
    create unique_index(:users, [:name])
  end
end
