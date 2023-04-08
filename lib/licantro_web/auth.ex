defmodule LicantroWeb.Auth do
  use LicantroWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Licantro.Users

  def fetch_current_user(conn, _opts) do
    user_uid = get_session(conn, :user_uid)
    current_user = user_uid && Users.get_user_by_uid!(user_uid)
    assign(conn, :current_user, current_user)
  end

  def redirect_if_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: ~p"/")
      |> halt()
    else
      conn
    end
  end

  def require_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      # |> put_flash(:error, "You must log in to access this page.")
      |> maybe_store_return_to()
      |> redirect(to: ~p"/login")
      |> halt()
    end
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :user_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  def on_mount(:mount_current_user, _params, session, socket) do
    {:cont, mount_current_user(session, socket)}
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    socket = mount_current_user(session, socket)
    socket = Phoenix.Component.assign(socket, :layout, {LicantroWeb.Layouts, :app})

    if socket.assigns.current_user do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You must log in to access this page.")
        |> Phoenix.LiveView.redirect(to: ~p"/login")

      {:halt, socket}
    end
  end

  def on_mount(:ensure_administrator, _params, session, socket) do
    socket = mount_current_user(session, socket)
    socket = Phoenix.Component.assign(socket, :layout, {LicantroWeb.Layouts, :admin})

    if Users.is_admin?(socket.assigns.current_user) do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You must log in to access this page.")
        |> Phoenix.LiveView.redirect(to: ~p"/login")

      {:halt, socket}
    end
  end

  def on_mount(:redirect_if_authenticated, _params, session, socket) do
    socket = mount_current_user(session, socket)

    if socket.assigns.current_user do
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    else
      {:cont, socket}
    end
  end

  defp mount_current_user(session, socket) do
    Phoenix.Component.assign_new(socket, :current_user, fn ->
      if user_uid = session["user_uid"] do
        Users.get_user_by_uid!(user_uid)
      end
    end)
  end
end
