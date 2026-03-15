defmodule DevtodoWeb.TaskLive.FormComponent do
  use DevtodoWeb, :live_component

  alias Devtodo.Tasks

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2 class="text-lg font-semibold text-gray-100 mb-6">{@title}</h2>

      <.simple_form
        for={@form}
        id="task-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} label="Title" placeholder="What needs to be done?" autofocus />
        <.input field={@form[:description]} type="textarea" label="Description" placeholder="Add details, links, context..." />

        <div class="grid grid-cols-2 gap-4">
          <.input
            field={@form[:status]}
            type="select"
            label="Status"
            options={[{"Todo", :todo}, {"In Progress", :in_progress}, {"Blocked", :blocked}, {"Done", :done}]}
          />
          <.input
            field={@form[:priority]}
            type="select"
            label="Priority"
            options={[{"Low", :low}, {"Medium", :medium}, {"High", :high}, {"Urgent", :urgent}]}
          />
        </div>

        <div class="grid grid-cols-2 gap-4">
          <.input field={@form[:due_date]} type="date" label="Due Date" />
          <.input
            field={@form[:project_id]}
            type="select"
            label="Project"
            prompt="No project"
            options={Enum.map(@projects, &{&1.name, &1.id})}
          />
        </div>

        <div>
          <label class="block text-xs font-medium text-gray-400 mb-1">Tags</label>
          <input
            type="text"
            id="tags-input"
            name="tags_raw"
            value={Enum.join(Phoenix.HTML.Form.input_value(@form, :tags) || [], ", ")}
            placeholder="api, bug, feature, refactor..."
            class="block w-full rounded-lg bg-gray-800 border border-gray-700 text-gray-100
                   px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
          <p class="mt-1 text-xs text-gray-600">Separate tags with commas</p>
        </div>

        <:actions>
          <.button
            type="button"
            phx-click={JS.patch(@patch)}
            class="bg-gray-800 hover:bg-gray-700 text-gray-300"
          >
            Cancel
          </.button>
          <.button
            type="submit"
            phx-disable-with="Saving..."
            class="bg-indigo-600 hover:bg-indigo-500 text-white"
          >
            {if @action == :new, do: "Create Task", else: "Save Changes"}
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{task: task} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn -> to_form(Tasks.change_task(task)) end)}
  end

  @impl true
  def handle_event("validate", %{"task" => task_params} = params, socket) do
    task_params = merge_tags(task_params, params)
    changeset = Tasks.change_task(socket.assigns.task, task_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"task" => task_params} = params, socket) do
    task_params = merge_tags(task_params, params)
    save_task(socket, socket.assigns.action, task_params)
  end

  defp merge_tags(task_params, params) do
    tags_raw = Map.get(params, "tags_raw", "")
    tags =
      tags_raw
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    Map.put(task_params, "tags", tags)
  end

  defp save_task(socket, :edit, task_params) do
    case Tasks.update_task(socket.assigns.task, task_params) do
      {:ok, task} ->
        notify_parent({:saved, task})

        {:noreply,
         socket
         |> put_flash(:info, "Task updated")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_task(socket, :new, task_params) do
    case Tasks.create_task(task_params) do
      {:ok, task} ->
        notify_parent({:saved, task})

        {:noreply,
         socket
         |> put_flash(:info, "Task created")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
