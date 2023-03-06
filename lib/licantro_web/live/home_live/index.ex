defmodule LicantroWeb.HomeLive.Index do
  use LicantroWeb, :live_view

  alias Licantro.Core

  @impl true
  def mount(_params, %{"current_user" => current_user}, socket) do
    socket
    |> assign(current_user: current_user)
    |> assign(show_live: length(Core.list_polls()) > 0)
    |> then(&{:ok, &1})
  end

  defp is_admin?(%{role: "admin"}), do: true
  defp is_admin?(_), do: false
end
