defmodule LicantroWeb.Admin.HomeLive do
  use LicantroWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> then(&{:ok, &1})
  end
end
