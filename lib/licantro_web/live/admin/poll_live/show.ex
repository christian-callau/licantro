defmodule LicantroWeb.Admin.PollLive.Show do
  use LicantroWeb, :live_view

  alias Licantro.Games
  alias Licantro.Polls

  @impl true
  def mount(%{"game_id" => game_id}, _session, socket) do
    socket
    |> assign(game: Games.get_game!(game_id))
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:poll, Polls.get_poll!(id))}
  end

  defp page_title(:show), do: "Show Poll"
  defp page_title(:edit), do: "Edit Poll"
end
