defmodule Licantro.Votes do
  import Ecto.Query, warn: false
  alias Licantro.Repo

  alias Licantro.Votes.Vote

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(Licantro.PubSub, topic)
  end

  def broadcast({:ok, vote}, tag) do
    Phoenix.PubSub.broadcast(Licantro.PubSub, vote.poll_id, {tag, vote})
    {:ok, vote}
  end

  def broadcast({:error, _changeset} = error, _tag), do: error

  def list_votes do
    Repo.all(Vote)
  end

  def list_votes(poll_id) do
    Repo.all(from p in Vote, where: p.poll_id == ^poll_id)
  end

  def get_vote!(%{poll_id: poll_id, user_id: user_id}),
    do: Repo.get_by!(Vote, poll_id: poll_id, user_id: user_id)

  def create_vote(attrs \\ %{}) do
    %Vote{}
    |> Vote.changeset(attrs)
    |> Repo.insert()
  end

  def update_vote(%Vote{} = vote, attrs) do
    vote
    |> Vote.changeset(attrs)
    |> Repo.update()
    |> broadcast(:vote_updated)
  end

  def delete_vote(%Vote{} = vote) do
    Repo.delete(vote)
  end

  def change_vote(%Vote{} = vote, attrs \\ %{}) do
    Vote.changeset(vote, attrs)
  end
end
