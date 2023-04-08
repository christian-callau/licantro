defmodule LicantroWeb.AuthController do
  use LicantroWeb, :controller

  plug Ueberauth

  alias Licantro.Users
  alias Ueberauth.Auth

  def login(conn, _params) do
    render(conn, :login)
  end

  def delete(conn, _params) do
    if live_socket_id = get_session(conn, :live_socket_id) do
      LicantroWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> redirect(to: ~p"/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: ~p"/")
  end

  def callback(
        %{assigns: %{ueberauth_auth: %Auth{uid: uid, info: %{name: name}}}} = conn,
        _params
      ) do
    Users.upsert_user(%{uid: uid, name: name})
    user_return_to = get_session(conn, :user_return_to)

    conn
    |> renew_session()
    |> put_uid_in_session(uid)
    |> redirect(to: user_return_to || ~p"/")
  end

  defp renew_session(conn) do
    preferred_locale = get_session(conn, :preferred_locale)

    conn
    |> configure_session(renew: true)
    |> clear_session()
    |> put_session(:preferred_locale, preferred_locale)
  end

  defp put_uid_in_session(conn, uid) do
    conn
    |> put_session(:user_uid, uid)
    |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(uid)}")
  end
end
