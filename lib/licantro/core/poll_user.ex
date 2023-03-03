defmodule Licantro.Core.PollUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id
  schema "polls_users" do
    field :poll_id, :binary_id, primary_key: true
    field :user_id, :binary_id, primary_key: true
    field :vote_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(poll_user, attrs) do
    poll_user
    |> cast(attrs, [:poll_id, :user_id, :vote_id])
    |> validate_required([:poll_id, :user_id])
  end
end
