defmodule LicantroWeb.Admin.PollLive.Index do
  use LicantroWeb, :live_view_admin

  alias Licantro.Core
  alias Licantro.Core.Poll

  @impl true
  def mount(%{"game_id" => game_id}, _session, socket) do
    socket
    |> assign(game: Core.get_game!(game_id))
    |> stream(:polls, Core.list_polls(game_id))
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Poll")
    |> assign(:poll, Core.get_poll!(id))
  end

  defp apply_action(socket, :new, %{"game_id" => game_id}) do
    socket
    |> assign(:page_title, "New Poll")
    |> assign(:poll, %Poll{
      game_id: game_id,
      opened_at: NaiveDateTime.new!(Date.utc_today(), ~T[08:00:00]),
      closed_at: NaiveDateTime.new!(Date.utc_today(), ~T[21:00:00])
    })
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Polls")
    |> assign(:poll, nil)
  end

  @impl true
  def handle_info({LicantroWeb.Admin.PollLive.FormComponent, {:saved, poll}}, socket) do
    {:noreply, stream_insert(socket, :polls, poll, at: 0)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    poll = Core.get_poll!(id)
    {:ok, _} = Core.delete_poll(poll)

    {:noreply, stream_delete(socket, :polls, poll)}
  end
end
