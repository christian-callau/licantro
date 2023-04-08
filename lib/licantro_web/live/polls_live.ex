defmodule LicantroWeb.PollsLive do
  use LicantroWeb, :live_view

  alias Licantro.Games
  alias Licantro.Polls

  @impl true
  def mount(%{"game_id" => game_id}, _session, socket) do
    socket
    |> assign(game: Games.get_game!(game_id))
    |> assign(polls: Polls.list_polls_limited(game_id))
    |> then(&{:ok, &1})
  end
end
