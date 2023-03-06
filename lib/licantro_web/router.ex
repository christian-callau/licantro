defmodule LicantroWeb.Router do
  use LicantroWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LicantroWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :require_user do
    plug(LicantroWeb.AuthPlug)
  end

  pipeline :require_admin do
    plug(LicantroWeb.AdminPlug)
  end

  scope "/auth", LicantroWeb do
    pipe_through :browser
    get "/facebook", AuthController, :request
    get "/facebook/callback", AuthController, :callback

    pipe_through :require_user
    delete "/logout", AuthController, :delete
  end

  scope "/", LicantroWeb do
    pipe_through :browser
    get "/login", PageController, :login

    pipe_through :require_user
    live "/", HomeLive.Index

    live "/roles", RolesLive.Index

    live "/games", GameLive.Index

    live "/games/:game_id/polls", PollLive.Index

    live "/games/:game_id/polls/:poll_id/live", PollLive.Live, :index
    live "/games/:game_id/polls/:poll_id/live/novote", PollLive.Live, :novote
    live "/games/:game_id/polls/:poll_id/live/:user_id/votes", PollLive.Live, :votes

    live "/live", PollLive.Live, :index
    live "/live/novote", PollLive.Live, :novote
    live "/live/:user_id/votes", PollLive.Live, :votes

    scope "/admin", Admin do
      pipe_through :require_admin
      live "/", HomeLive.Index

      live "/users", UserLive.Index, :index
      live "/users/new", UserLive.Index, :new
      live "/users/:id/edit", UserLive.Index, :edit
      live "/users/:id", UserLive.Show, :show
      live "/users/:id/show/edit", UserLive.Show, :edit

      live "/games", GameLive.Index, :index
      live "/games/new", GameLive.Index, :new
      live "/games/:id/edit", GameLive.Index, :edit
      live "/games/:id", GameLive.Show, :show
      live "/games/:id/show/edit", GameLive.Show, :edit

      live "/games/:game_id/polls", PollLive.Index, :index
      live "/games/:game_id/polls/new", PollLive.Index, :new
      live "/games/:game_id/polls/:id/edit", PollLive.Index, :edit
      live "/games/:game_id/polls/:id", PollLive.Show, :show
      live "/games/:game_id/polls/:id/show/edit", PollLive.Show, :edit

      live "/games/:game_id/polls/:poll_id/players", PlayerLive.Index, :index
      live "/games/:game_id/polls/:poll_id/players/new", PlayerLive.Index, :new
      live "/games/:game_id/polls/:poll_id/players/:id/edit", PlayerLive.Index, :edit
    end
  end
end
