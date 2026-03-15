defmodule DevtodoWeb.ProjectLive.FormComponent do
  use DevtodoWeb, :live_component

  alias Devtodo.Projects

  @colors ~w(#6366f1 #8b5cf6 #ec4899 #ef4444 #f97316 #eab308 #22c55e #14b8a6 #3b82f6 #06b6d4)

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2 class="text-lg font-semibold text-gray-100 mb-6">{@title}</h2>

      <.simple_form
        for={@form}
        id="project-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} label="Project Name" placeholder="e.g. API Refactor, Frontend, Bug Fixes" autofocus />
        <.input field={@form[:description]} type="textarea" label="Description" placeholder="What is this project about?" />

        <div>
          <label class="block text-xs font-medium text-gray-400 mb-2">Color</label>
          <div class="flex gap-2 flex-wrap">
            <%= for color <- @colors do %>
              <label class="cursor-pointer">
                <input type="radio" name="project[color]" value={color} checked={Phoenix.HTML.Form.input_value(@form, :color) == color} class="sr-only" />
                <span
                  class={[
                    "block w-7 h-7 rounded-full transition-all ring-offset-2 ring-offset-gray-900",
                    Phoenix.HTML.Form.input_value(@form, :color) == color && "ring-2 ring-white scale-110"
                  ]}
                  style={"background-color: #{color}"}
                ></span>
              </label>
            <% end %>
          </div>
        </div>

        <:actions>
          <.button type="button" phx-click={JS.patch(@patch)} class="bg-gray-800 hover:bg-gray-700 text-gray-300">
            Cancel
          </.button>
          <.button type="submit" phx-disable-with="Saving..." class="bg-indigo-600 hover:bg-indigo-500 text-white">
            {if @action == :new, do: "Create Project", else: "Save"}
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{project: project} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:colors, @colors)
     |> assign_new(:form, fn -> to_form(Projects.change_project(project)) end)}
  end

  @impl true
  def handle_event("validate", %{"project" => project_params}, socket) do
    changeset = Projects.change_project(socket.assigns.project, project_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"project" => project_params}, socket) do
    save_project(socket, socket.assigns.action, project_params)
  end

  defp save_project(socket, :edit, project_params) do
    case Projects.update_project(socket.assigns.project, project_params) do
      {:ok, project} ->
        notify_parent({:saved, project})

        {:noreply,
         socket
         |> put_flash(:info, "Project updated")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_project(socket, :new, project_params) do
    case Projects.create_project(project_params) do
      {:ok, project} ->
        notify_parent({:saved, project})

        {:noreply,
         socket
         |> put_flash(:info, "Project created")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
