defmodule LicantroWeb.Admin.GameLive.Show do
  use LicantroWeb, :live_view

  alias Licantro.Games

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:game, Games.get_game!(id))}
  end

  defp page_title(:show), do: "Show Game"
  defp page_title(:edit), do: "Edit Game"
end
