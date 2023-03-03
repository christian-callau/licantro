defmodule LicantroWeb.AdminPlug do
  @behaviour Plug

  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(
        %{
          private: %{
            plug_session: %{"current_user" => %Licantro.Core.User{role: "admin"}}
          }
        } = conn,
        _opts
      ) do
    conn
  end

  def call(conn, _opts) do
    conn
    |> redirect(to: "/")
    |> halt()
  end
end
