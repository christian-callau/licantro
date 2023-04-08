defmodule LicantroWeb.RolesLive do
  use LicantroWeb, :live_view

  alias Licantro.Roles

  @blacklist ~w(
    spellcaster
    village_idiot
    ghost
    lone_wolf
    old_hag
    pacifist
    troublemaker
  )s

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(roles: Roles.get_roles() |> Enum.filter(&(not blacklisted?(&1))))
    |> then(&{:ok, &1})
  end

  defp blacklisted?({key, _}) do
    Enum.any?(@blacklist, &String.equivalent?(&1, key))
  end
end
