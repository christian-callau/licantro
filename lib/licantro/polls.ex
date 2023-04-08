defmodule Licantro.Polls do
  import Ecto.Query, warn: false
  alias Licantro.Repo

  alias Licantro.Polls.Poll

  def list_polls do
    date = NaiveDateTime.utc_now()

    Repo.all(from p in Poll, where: p.opened_at <= ^date, order_by: [desc: :closed_at])
  end

  def list_polls(game_id) do
    Repo.all(
      from p in Poll,
        where: p.game_id == ^game_id,
        order_by: [desc: :closed_at]
    )
  end

  def list_polls_limited(game_id) do
    date = NaiveDateTime.utc_now()

    Repo.all(
      from p in Poll,
        where: p.game_id == ^game_id and p.opened_at <= ^date,
        order_by: [desc: :closed_at]
    )
  end

  def list_poll_users(%Poll{} = poll) do
    poll
    |> Ecto.assoc(:users)
    |> Repo.all()
  end

  def get_poll!(id), do: Repo.get!(Poll, id)

  def get_newest_poll!() do
    date = NaiveDateTime.utc_now()

    Repo.all(
      from p in Poll,
        where: p.opened_at <= ^date,
        order_by: [desc: :closed_at],
        limit: 1
    )
    |> List.first()
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
end
