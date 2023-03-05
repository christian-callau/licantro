defmodule LicantroWeb.PollLive.Live do
  use LicantroWeb, :live_view

  alias Licantro.Core.Vote
  alias Licantro.Core

  @impl true
  def mount(
        %{"game_id" => game_id, "poll_id" => poll_id},
        %{"current_user" => current_user},
        socket
      ) do
    game = Core.get_game!(game_id)
    poll = Core.get_poll!(poll_id)
    users = Core.list_poll_users(poll) |> Enum.sort(&(normalize(&1.name) < normalize(&2.name)))
    votes = Core.list_votes(poll_id)
    is_poll_open = is_poll_open?(poll)
    is_user_poll = is_user_poll?(users, current_user)

    if connected?(socket) do
      Core.subscribe(poll_id)

      if is_poll_open do
        :timer.send_interval(1000, self(), :tick)
      end
    end

    socket
    |> assign(current_user: current_user)
    |> assign(game: game)
    |> assign(poll: poll)
    |> assign(users: users)
    |> assign(votes: votes)
    |> assign_users_votes()
    |> assign(is_poll_open: is_poll_open)
    |> assign(is_user_poll: is_user_poll)
    |> assign(clock: compute_clock(poll, is_poll_open))
    |> then(&{:ok, &1})
  end

  defp normalize(string) do
    string
    |> String.normalize(:nfd)
    |> String.replace(~r/[^A-z\s]/u, "")
  end

  @impl true
  def handle_event(
        "vote",
        %{"vote_id" => vote_id},
        %{assigns: %{poll: %{id: poll_id}, votes: votes, current_user: %{id: user_id}}} = socket
      ) do
    votes
    |> Enum.find(&(&1.user_id == user_id))
    |> case do
      %Vote{} = vote ->
        vote
        |> update_vote(vote_id)
        |> Core.broadcast(poll_id, :vote)

      _ ->
        nil
    end

    {:noreply, socket}
  end

  defp update_vote(%{vote_id: vote_id} = vote, vote_id) do
    Core.update_vote(vote, %{vote_id: nil})
  end

  defp update_vote(vote, vote_id) do
    Core.update_vote(vote, %{vote_id: vote_id})
  end

  @impl true
  def handle_info({:vote, vote}, %{assigns: %{votes: votes}} = socket) do
    IO.puts("handle_info_vote")

    votes = Enum.map(votes, fn v -> if v.user_id == vote.user_id, do: vote, else: v end)

    socket
    |> assign(votes: votes)
    |> assign_users_votes()
    |> then(&{:noreply, &1})
  end

  def handle_info(:tick, %{assigns: %{poll: poll}} = socket) do
    is_poll_open = is_poll_open?(poll)

    socket
    |> assign(is_poll_open: is_poll_open)
    |> assign(clock: compute_clock(poll, is_poll_open))
    |> then(&{:noreply, &1})
  end

  defp assign_users_votes(%{assigns: %{users: users, votes: votes}} = socket) do
    assign(socket, users_votes: compute_users_votes(users, votes))
  end

  defp compute_users_votes(users, votes) do
    users
    |> Enum.map(fn user ->
      votes
      |> Enum.filter(fn %{vote_id: vote_id} -> vote_id == user.id end)
      |> Enum.map(fn %{user_id: user_id} -> Enum.find(users, &(&1.id == user_id)) end)
      |> then(&%{user | voters: &1})
    end)
    |> Enum.sort(&(length(&1.voters) >= length(&2.voters)))
  end

  defp is_voting?(voters, fbid) do
    Enum.any?(voters, fn voter -> voter.fbid == fbid end)
  end

  defp is_user_poll?(users, %{id: user_id}) do
    Enum.any?(users, &(&1.id == user_id))
  end

  defp is_poll_open?(%{opened_at: opened_at, closed_at: closed_at}) do
    utc_now = NaiveDateTime.utc_now()
    NaiveDateTime.diff(utc_now, opened_at) > 0 and NaiveDateTime.diff(closed_at, utc_now) > 0
  end

  defp compute_clock(%{closed_at: closed_at}, false) do
    %{time: closed_at, down: 0}
  end

  defp compute_clock(%{closed_at: closed_at}, true) do
    time = Time.utc_now()
    down = Time.diff(closed_at, time) + 1

    %{time: time, down: down}
  end

  defp format_time(time) do
    time
    |> Time.add(3600)
    |> Time.to_string()
    |> String.split(".")
    |> List.first()
  end

  defp format_down(down) do
    [
      down |> div(3600) |> rem(60) |> Integer.to_string() |> String.pad_leading(2, "0"),
      down |> div(60) |> rem(60) |> Integer.to_string() |> String.pad_leading(2, "0"),
      down |> div(1) |> rem(60) |> Integer.to_string() |> String.pad_leading(2, "0")
    ]
    |> Enum.join(":")
  end
end
