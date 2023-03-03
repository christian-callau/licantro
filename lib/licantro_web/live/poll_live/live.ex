defmodule LicantroWeb.PollLive.Live do
  use LicantroWeb, :live_view

  alias Licantro.Core

  @impl true
  def mount(
        %{"game_id" => game_id, "poll_id" => poll_id},
        %{"current_user" => current_user},
        socket
      ) do
    socket
    |> assign(game: Core.get_game!(game_id))
    |> assign(poll: Core.get_poll!(poll_id))
    |> assign(current_user: current_user)
    |> then(&{:ok, &1})
  end
end
