defmodule LicantroWeb.PollLive do
  use LicantroWeb, :live_view

  alias Licantro.Games
  alias Licantro.Polls
  alias Licantro.Votes
  alias Licantro.Votes.Vote

  @impl true
  def mount(params, _session, socket) do
    poll =
      if Map.has_key?(params, "poll_id"),
        do: Polls.get_poll!(params["poll_id"]),
        else: Polls.get_newest_poll!()

    game = Games.get_game!(poll.game_id)
    users = Polls.list_poll_users(poll) |> Enum.sort(&(normalize(&1.name) < normalize(&2.name)))
    votes = Votes.list_votes(poll.id)

    is_poll_open = is_poll_open?(poll)
    is_user_poll = is_user_poll?(users, socket.assigns.current_user)

    if connected?(socket) do
      Votes.subscribe(poll.id)

      if is_poll_open do
        :timer.send_interval(1000, self(), :tick)
      end
    end

    socket
    |> assign(game: game)
    |> assign(poll: poll)
    |> assign(users: users)
    |> assign(votes: votes)
    |> assign(users_votes: compute_users_votes(users, votes))
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
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
  end

  defp apply_action(%{assigns: %{users: users, votes: votes}} = socket, :novote, _params) do
    users_novote =
      Enum.filter(users, fn user ->
        %Vote{vote_id: vote_id} = Enum.find(votes, &(&1.user_id == user.id))
        vote_id == nil and user.uid != nil
      end)

    socket
    |> assign(:users_novote, users_novote)
  end

  defp apply_action(%{assigns: %{users_votes: users_votes}} = socket, :votes, %{
         "user_id" => user_id
       }) do
    socket
    |> assign(:user_votes, Enum.find(users_votes, &(&1.id == user_id)))
  end

  @impl true
  def handle_event(
        "vote",
        %{"vote_id" => vote_id},
        %{assigns: %{votes: votes, current_user: current_user}} = socket
      ) do
    votes
    |> Enum.find(&(&1.user_id == current_user.id))
    |> update_vote(vote_id)

    {:noreply, socket}
  end

  defp update_vote(nil, _vote_id), do: nil

  defp update_vote(%{vote_id: vote_id} = vote, vote_id) do
    Votes.update_vote(vote, %{vote_id: nil})
  end

  defp update_vote(vote, vote_id) do
    Votes.update_vote(vote, %{vote_id: vote_id})
  end

  @impl true
  def handle_info({:vote_updated, vote}, %{assigns: %{users: users, votes: votes}} = socket) do
    votes = Enum.map(votes, fn v -> if v.user_id == vote.user_id, do: vote, else: v end)

    socket
    |> assign(votes: votes)
    |> assign(users_votes: compute_users_votes(users, votes))
    |> then(&{:noreply, &1})
  end

  def handle_info(:tick, %{assigns: %{poll: poll}} = socket) do
    is_poll_open = is_poll_open?(poll)

    socket
    |> assign(is_poll_open: is_poll_open)
    |> assign(clock: compute_clock(poll, is_poll_open))
    |> then(&{:noreply, &1})
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

  defp is_voting?(voters, uid) do
    Enum.any?(voters, fn voter -> voter.uid == uid end)
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
    down = NaiveDateTime.diff(closed_at, NaiveDateTime.utc_now()) + 1

    %{time: time, down: down}
  end

  defp format_down(down) do
    [
      down |> div(3600) |> Integer.to_string() |> String.pad_leading(2, "0"),
      down |> div(60) |> rem(60) |> Integer.to_string() |> String.pad_leading(2, "0"),
      down |> rem(60) |> Integer.to_string() |> String.pad_leading(2, "0")
    ]
    |> Enum.join(":")
  end
end
