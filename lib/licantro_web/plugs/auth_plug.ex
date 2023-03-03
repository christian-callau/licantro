defmodule LicantroWeb.AuthPlug do
  @behaviour Plug

  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(
        %{
          private: %{
            plug_session: %{"current_user" => %Licantro.Core.User{}}
          }
        } = conn,
        _opts
      ) do
    conn
  end

  def call(conn, _opts) do
    conn
    |> redirect(to: "/login")
    |> halt()
  end
end
