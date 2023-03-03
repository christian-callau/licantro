defmodule Licantro.Core.Poll do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "polls" do
    field :closed_at, :naive_datetime
    field :name, :string
    field :opened_at, :naive_datetime
    field :game_id, :binary_id

    many_to_many :users, Licantro.Core.User, join_through: "polls_users"

    timestamps()
  end

  @doc false
  def changeset(poll, attrs) do
    poll
    |> cast(attrs, [:game_id, :name, :opened_at, :closed_at])
    |> validate_required([:game_id, :name, :opened_at, :closed_at])
  end
end
