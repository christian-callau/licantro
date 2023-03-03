defmodule LicantroWeb.AuthController do
  use LicantroWeb, :controller

  plug Ueberauth

  alias Ueberauth.Auth
  alias Licantro.Core.User
  alias Licantro.Repo

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: ~p"/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: ~p"/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    {:ok, user} = upsert_user(auth)

    conn
    |> put_session(:current_user, user)
    |> configure_session(renew: true)
    |> redirect(to: ~p"/")
  end

  defp upsert_user(%Auth{info: %{name: name}, uid: fbid}) do
    update_name(fbid, name)
  end

  defp update_name(fbid, name) do
    case Repo.get_by(User, fbid: fbid) do
      nil ->
        update_fbid(fbid, name)

      user ->
        user
        |> Ecto.Changeset.change(name: name)
        |> Repo.update()
    end
  end

  defp update_fbid(fbid, name) do
    case Repo.get_by(User, name: name) do
      nil ->
        inser_user(fbid, name)

      user ->
        user
        |> Ecto.Changeset.change(fbid: fbid)
        |> Repo.update()
    end
  end

  defp inser_user(fbid, name) do
    Repo.insert(%User{fbid: fbid, name: name})
  end
end
