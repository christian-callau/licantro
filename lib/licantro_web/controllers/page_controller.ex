defmodule LicantroWeb.PageController do
  use LicantroWeb, :controller

  def login(conn, _params) do
    render(conn, :login, layout: false)
  end
end
