defmodule Licantro.Votes.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @foreign_key_type Ecto.ULID
  schema "votes" do
    field :poll_id, Ecto.ULID, primary_key: true
    field :user_id, Ecto.ULID, primary_key: true
    field :vote_id, Ecto.ULID

    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:poll_id, :user_id, :vote_id])
    |> validate_required([:poll_id, :user_id])
  end
end
