defmodule LicantroWeb.PollLive.Index do
  use LicantroWeb, :live_view

  alias Licantro.Core

  @impl true
  def mount(%{"game_id" => game_id}, %{"current_user" => current_user}, socket) do
    socket
    |> assign(current_user: current_user)
    |> assign(game: Core.get_game!(game_id))
    |> assign(polls: Core.list_polls_limited(game_id))
    |> then(&{:ok, &1})
  end
end
