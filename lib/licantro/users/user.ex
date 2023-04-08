defmodule Licantro.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "users" do
    field :uid, :string
    field :name, :string
    field :role, :string, default: "USER"
    field :voters, {:array, :map}, virtual: true

    many_to_many :polls, Licantro.Polls.Poll, join_through: "votes"

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:uid, :name, :role])
    |> validate_required([:name, :role])
    |> unique_constraint(:uid)
    |> unique_constraint(:name)
  end
end
