defmodule LicantroWeb.Admin.PollLive.FormComponent do
  use LicantroWeb, :live_component

  alias Licantro.Core

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="poll-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:opened_at]} type="datetime-local" label="Opened at" />
        <.input field={@form[:closed_at]} type="datetime-local" label="Closed at" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Poll</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{poll: poll} = assigns, socket) do
    changeset = Core.change_poll(poll)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"poll" => poll_params}, socket) do
    changeset =
      socket.assigns.poll
      |> Core.change_poll(poll_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"poll" => poll_params}, socket) do
    save_poll(socket, socket.assigns.action, poll_params)
  end

  defp save_poll(socket, :edit, poll_params) do
    case Core.update_poll(socket.assigns.poll, poll_params) do
      {:ok, poll} ->
        notify_parent({:saved, poll})

        {:noreply,
         socket
         |> put_flash(:info, "Poll updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_poll(socket, :new, poll_params) do
    game_id = socket.assigns.game.id

    votes =
      case game_id |> Core.list_polls() |> List.first() do
        %Core.Poll{id: poll_id} -> Core.list_votes(poll_id)
        _ -> []
      end

    case poll_params |> Map.put("game_id", game_id) |> Core.create_poll() do
      {:ok, poll} ->
        for %{user_id: user_id} <- votes do
          Core.create_vote(%{poll_id: poll.id, user_id: user_id})
        end

        notify_parent({:saved, poll})

        {:noreply,
         socket
         |> put_flash(:info, "Poll created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
