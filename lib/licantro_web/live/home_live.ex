defmodule LicantroWeb.HomeLive do
  use LicantroWeb, :live_view

  alias Licantro.Users
  alias Licantro.Polls

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(show_live: length(Polls.list_polls()) > 0)
    |> then(&{:ok, &1})
  end
end
