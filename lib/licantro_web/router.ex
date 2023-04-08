defmodule LicantroWeb.Router do
  use LicantroWeb, :router

  import LicantroWeb.Auth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LicantroWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  scope "/", LicantroWeb do
    pipe_through [:browser, :redirect_if_authenticated]

    get "/login", AuthController, :login
    get "/auth/facebook", AuthController, :request
    get "/auth/facebook/callback", AuthController, :callback
  end

  scope "/", LicantroWeb do
    pipe_through [:browser]

    delete "/auth/logout", AuthController, :delete
  end

  scope "/", LicantroWeb do
    pipe_through [:browser, :require_authenticated]

    live_session :require_authenticated, on_mount: [{LicantroWeb.Auth, :ensure_authenticated}] do
      live "/", HomeLive
      live "/roles", RolesLive
      live "/games", GamesLive

      scope "/games/:game_id" do
        live "/polls", PollsLive

        scope "/polls/:poll_id" do
          live "/live", PollLive, :index
          live "/live/novote", PollLive, :novote
          live "/live/:user_id/votes", PollLive, :votes
        end
      end

      live "/live", PollLive, :index
      live "/live/novote", PollLive, :novote
      live "/live/:user_id/votes", PollLive, :votes
    end

    live_session :require_administrator, on_mount: [{LicantroWeb.Auth, :ensure_administrator}] do
      scope "/admin", Admin do
        live "/", HomeLive

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

        scope "/games/:game_id" do
          live "/polls", PollLive.Index, :index
          live "/polls/new", PollLive.Index, :new
          live "/polls/:id/edit", PollLive.Index, :edit
          live "/polls/:id", PollLive.Show, :show
          live "/polls/:id/show/edit", PollLive.Show, :edit

          scope "/polls/:poll_id" do
            live "/players", VoteLive.Index, :index
            live "/players/new", VoteLive.Index, :new
            live "/players/:id/edit", VoteLive.Index, :edit
          end
        end
      end
    end
  end
end
