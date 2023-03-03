defmodule LicantroWeb.GameLive.Index do
  use LicantroWeb, :live_view

  alias Licantro.Core

  @impl true
  def mount(_params, %{"current_user" => current_user}, socket) do
    socket
    |> assign(current_user: current_user)
    |> assign(games: Core.list_games())
    |> then(&{:ok, &1})
  end
end
