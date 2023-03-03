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
    Repo.all(Poll)
  end

  def list_polls(game_id) do
    Repo.all(from p in Poll, where: p.game_id == ^game_id, order_by: [desc: :closed_at])
  end

  def get_poll!(id), do: Repo.get!(Poll, id)

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

  alias Licantro.Core.PollUser

  def list_poll_users(poll_id) do
    Repo.all(from p in PollUser, where: p.poll_id == ^poll_id)
  end

  def get_poll_users(poll_id) do
    poll_id
    |> get_poll!()
    |> Ecto.assoc(:users)
    |> Repo.all()
  end

  def get_poll_user!(ids), do: Repo.get_by!(PollUser, ids)

  def create_poll_user(attrs \\ %{}) do
    %PollUser{}
    |> PollUser.changeset(attrs)
    |> Repo.insert()
  end

  def update_poll_user(%PollUser{} = poll_user, attrs) do
    poll_user
    |> PollUser.changeset(attrs)
    |> Repo.update()
  end

  def delete_poll_user(%PollUser{} = poll_user) do
    Repo.delete(poll_user)
  end

  def change_poll_user(%PollUser{} = poll_user, attrs \\ %{}) do
    PollUser.changeset(poll_user, attrs)
  end
end
