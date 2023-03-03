defmodule LicantroWeb.Admin.HomeLive.Index do
  use LicantroWeb, :live_view_admin

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
