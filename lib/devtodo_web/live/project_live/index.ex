defmodule DevtodoWeb.ProjectLive.Index do
  use DevtodoWeb, :live_view

  alias Devtodo.Projects
  alias Devtodo.Projects.Project

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :projects, Projects.list_projects())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Projects")
    |> assign(:project, nil)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Project")
    |> assign(:project, %Project{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Project")
    |> assign(:project, Projects.get_project!(id))
  end

  @impl true
  def handle_info({DevtodoWeb.ProjectLive.FormComponent, {:saved, _project}}, socket) do
    {:noreply, assign(socket, :projects, Projects.list_projects())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    project = Projects.get_project!(id)
    {:ok, _} = Projects.delete_project(project)

    {:noreply,
     socket
     |> assign(:projects, Projects.list_projects())
     |> put_flash(:info, "Project deleted")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-950 p-8">
      <div class="max-w-2xl mx-auto">
        <div class="flex items-center justify-between mb-8">
          <div>
            <.back navigate={~p"/"}>Back to Tasks</.back>
            <h1 class="text-2xl font-bold text-gray-100 mt-4">Projects</h1>
            <p class="text-gray-500 text-sm mt-1">Organize your tasks by project</p>
          </div>
          <.link
            patch={~p"/projects/new"}
            class="flex items-center gap-2 rounded-lg bg-indigo-600 hover:bg-indigo-500 px-4 py-2 text-sm font-medium transition-colors"
          >
            <.icon name="hero-plus" class="h-4 w-4" />
            New Project
          </.link>
        </div>

        <div :if={@projects == []} class="text-center py-16 text-gray-500">
          <.icon name="hero-folder" class="h-12 w-12 mx-auto mb-3 text-gray-700" />
          <p>No projects yet. Create one to organize your tasks.</p>
        </div>

        <div class="space-y-3">
          <%= for project <- @projects do %>
            <div class="flex items-center gap-4 rounded-xl border border-gray-800 bg-gray-900 p-4">
              <div class="w-4 h-4 rounded-full flex-shrink-0" style={"background-color: #{project.color}"}></div>
              <div class="flex-1 min-w-0">
                <p class="font-medium text-gray-100">{project.name}</p>
                <p :if={project.description} class="text-sm text-gray-500 truncate">{project.description}</p>
              </div>
              <div class="flex items-center gap-2">
                <.link
                  patch={~p"/projects/#{project.id}/edit"}
                  class="p-2 rounded-lg text-gray-600 hover:text-gray-300 hover:bg-gray-800 transition-colors"
                >
                  <.icon name="hero-pencil" class="h-4 w-4" />
                </.link>
                <button
                  phx-click="delete"
                  phx-value-id={project.id}
                  data-confirm={"Delete project \"#{project.name}\"? Tasks will be kept but unassigned."}
                  class="p-2 rounded-lg text-gray-600 hover:text-red-400 hover:bg-red-900/20 transition-colors"
                >
                  <.icon name="hero-trash" class="h-4 w-4" />
                </button>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="project-modal"
      show
      on_cancel={JS.patch(~p"/projects")}
    >
      <.live_component
        module={DevtodoWeb.ProjectLive.FormComponent}
        id={@project.id || :new}
        title={@page_title}
        action={@live_action}
        project={@project}
        patch={~p"/projects"}
      />
    </.modal>
    """
  end
end
