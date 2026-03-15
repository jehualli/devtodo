defmodule DevtodoWeb.Router do
  use DevtodoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DevtodoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DevtodoWeb do
    pipe_through :browser

    live "/", TaskLive.Index, :index
    live "/tasks/new", TaskLive.Index, :new
    live "/tasks/:id/edit", TaskLive.Index, :edit

    live "/projects", ProjectLive.Index, :index
    live "/projects/new", ProjectLive.Index, :new
    live "/projects/:id/edit", ProjectLive.Index, :edit
  end

end
