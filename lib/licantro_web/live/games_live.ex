defmodule LicantroWeb.GamesLive do
  use LicantroWeb, :live_view

  alias Licantro.Games

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(games: Games.list_games())
    |> then(&{:ok, &1})
  end
end
