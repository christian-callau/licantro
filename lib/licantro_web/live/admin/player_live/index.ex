defmodule LicantroWeb.Admin.PlayerLive.Index do
  use LicantroWeb, :live_view_admin

  alias Licantro.Core
  alias Licantro.Core.User
  alias Licantro.Core.Vote

  @impl true
  def mount(%{"game_id" => game_id, "poll_id" => poll_id}, _session, socket) do
    socket
    |> assign(game: Core.get_game!(game_id))
    |> assign(poll: Core.get_poll!(poll_id))
    |> assign_users(poll_id)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("add", %{"poll_id" => poll_id, "user_id" => user_id}, socket) do
    %{poll_id: poll_id, user_id: user_id}
    |> Core.create_vote()

    socket
    |> assign_users(poll_id)
    |> then(&{:noreply, &1})
  end

  def handle_event("remove", %{"poll_id" => poll_id, "user_id" => user_id}, socket) do
    %{poll_id: poll_id, user_id: user_id}
    |> Core.get_vote!()
    |> Core.delete_vote()

    socket
    |> assign_users(poll_id)
    |> then(&{:noreply, &1})
  end

  defp assign_users(socket, poll_id) do
    users = Core.list_users()
    votes = Core.list_votes(poll_id)

    {users_included, users_excluded} =
      Enum.split_with(users, fn %User{id: id} ->
        Enum.any?(votes, fn %Vote{user_id: user_id} -> user_id == id end)
      end)

    socket
    |> assign(:users_included, users_included)
    |> assign(:users_excluded, users_excluded)
  end
end
