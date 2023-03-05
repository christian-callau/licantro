defmodule Licantro.Core.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :fbid, :string
    field :name, :string
    field :role, :string, default: "user"
    field :voters, {:array, :map}, virtual: true

    many_to_many :polls, Licantro.Core.Poll, join_through: "votes"

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:fbid, :name, :role])
    |> validate_required([:name, :role])
    |> unique_constraint(:fbid)
    |> unique_constraint(:name)
  end
end
