defmodule Licantro.Users do
  import Ecto.Query, warn: false
  alias Licantro.Repo

  alias Licantro.Users.User

  @admin "ADMIN"

  def list_users do
    Repo.all(from User, order_by: [:name])
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_uid!(uid), do: Repo.get_by!(User, uid: uid)

  def upsert_user(%{uid: uid, name: name}) do
    case Repo.get_by(User, uid: uid) do
      %User{} = user ->
        update_user(user, %{name: name})

      nil ->
        create_user(%{uid: uid, name: name})
    end
  end

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

  def is_admin?(%User{role: @admin}), do: true
  def is_admin?(_), do: false
end
