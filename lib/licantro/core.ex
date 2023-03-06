defmodule Licantro.Core do
  import Ecto.Query, warn: false
  alias Licantro.Repo

  alias Licantro.Core.User

  def list_users do
    Repo.all(from u in User, order_by: [:name])
  end

  def get_user!(id), do: Repo.get!(User, id)

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  alias Licantro.Core.Game

  def list_games do
    Repo.all(from g in Game, order_by: [desc: :inserted_at])
  end

  def get_game!(id), do: Repo.get!(Game, id)

  def create_game(attrs \\ %{}) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  def change_game(%Game{} = game, attrs \\ %{}) do
    Game.changeset(game, attrs)
  end

  alias Licantro.Core.Poll

  def list_polls do
    date = NaiveDateTime.utc_now()
    Repo.all(from p in Poll, where: p.opened_at <= ^date)
  end

  def list_polls(game_id) do
    Repo.all(from p in Poll, where: p.game_id == ^game_id, order_by: [desc: :closed_at])
  end

  def list_polls_limited(game_id) do
    date = NaiveDateTime.utc_now()

    Repo.all(
      from p in Poll,
        where: p.game_id == ^game_id and p.opened_at <= ^date,
        order_by: [desc: :closed_at]
    )
  end

  def get_poll!(id), do: Repo.get!(Poll, id)

  def get_newest_poll!() do
    Repo.all(from p in Poll, order_by: [desc: :closed_at], limit: 1) |> List.first()
  end

  def create_poll(attrs \\ %{}) do
    %Poll{}
    |> Poll.changeset(attrs)
    |> Repo.insert()
  end

  def update_poll(%Poll{} = poll, attrs) do
    poll
    |> Poll.changeset(attrs)
    |> Repo.update()
  end

  def delete_poll(%Poll{} = poll) do
    Repo.delete(poll)
  end

  def change_poll(%Poll{} = poll, attrs \\ %{}) do
    Poll.changeset(poll, attrs)
  end

  alias Licantro.Core.Vote

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
  end

  def delete_vote(%Vote{} = vote) do
    Repo.delete(vote)
  end

  def change_vote(%Vote{} = vote, attrs \\ %{}) do
    Vote.changeset(vote, attrs)
  end

  # Custom Bussines Logic

  def broadcast({:error, _reason} = error, _topic, _event), do: error

  def broadcast({:ok, entity}, topic, event) do
    Phoenix.PubSub.broadcast(Licantro.PubSub, topic, {event, entity})
    {:ok, entity}
  end

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(Licantro.PubSub, topic)
  end

  def list_poll_users(%Licantro.Core.Poll{} = poll) do
    poll
    |> Ecto.assoc(:users)
    |> Repo.all()
  end
end
