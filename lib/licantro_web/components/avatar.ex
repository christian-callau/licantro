defmodule LicantroWeb.Avatar do
  use Phoenix.Component

  @doc """
  Renders a facebook avatar.

  """
  attr :uid, :string, required: true
  attr :name, :string, required: true

  def avatar(assigns) do
    ~H"""
    <%= if @uid == nil do %>
      <span class="flex justify-center items-center bg-blue-400 rounded-full w-[52px] h-[52px] text-2xl border border-neutral-700">
        <%= initials(@name) %>
      </span>
    <% else %>
      <img
        src={"https://res.cloudinary.com/dffgulrte/image/fetch/f_webp/https://graph.facebook.com/#{@uid}/picture"}
        alt={initials(@name)}
        class="rounded-full border border-neutral-700"
      />
    <% end %>
    """
  end

  def avatar_md(assigns) do
    ~H"""
    <%= if @uid == nil do %>
      <span class="flex justify-center items-center bg-blue-400 rounded-full w-10 h-10 text-xl border border-neutral-700">
        <%= initials(@name) %>
      </span>
    <% else %>
      <img
        src={"https://res.cloudinary.com/dffgulrte/image/fetch/f_webp/https://graph.facebook.com/#{@uid}/picture"}
        alt={initials(@name)}
        class="rounded-full w-10 h-10 border border-neutral-700"
      />
    <% end %>
    """
  end

  def avatar_sm(assigns) do
    ~H"""
    <%= if @uid == nil do %>
      <span class="flex justify-center items-center bg-blue-400 rounded-full w-6 h-6 text-sm border border-neutral-700">
        <%= initials(@name) %>
      </span>
    <% else %>
      <img
        src={"https://res.cloudinary.com/dffgulrte/image/fetch/f_webp/https://graph.facebook.com/#{@uid}/picture"}
        alt={initials(@name)}
        class="rounded-full w-6 h-6 border border-neutral-700"
      />
    <% end %>
    """
  end

  defp initials(name) do
    name
    |> String.split(" ")
    |> Enum.slice(0, 2)
    |> Enum.map(&String.at(&1, 0))
    |> Enum.join()
    |> String.upcase()
  end
end
