defmodule Licantro.Polls.Poll do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "polls" do
    field :game_id, Ecto.ULID
    field :name, :string
    field :opened_at, :naive_datetime
    field :closed_at, :naive_datetime

    many_to_many :users, Licantro.Users.User, join_through: "votes"

    timestamps()
  end

  @doc false
  def changeset(poll, attrs) do
    poll
    |> cast(attrs, [:game_id, :name, :opened_at, :closed_at])
    |> validate_required([:game_id, :name, :opened_at, :closed_at])
  end
end
