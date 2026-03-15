defmodule DevtodoWeb.TaskLive.Index do
  use DevtodoWeb, :live_view

  alias Devtodo.Tasks
  alias Devtodo.Tasks.Task
  alias Devtodo.Projects

  @impl true
  def mount(_params, _session, socket) do
    projects = Projects.list_projects()
    counts = Tasks.count_by_status()
    tags = Tasks.all_tags()

    {:ok,
     socket
     |> assign(:projects, projects)
     |> assign(:counts, counts)
     |> assign(:tags, tags)
     |> assign(:filters, %{status: :all, priority: :all, project_id: :all, tag: nil, search: ""})
     |> load_tasks()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "DevTodo")
    |> assign(:task, nil)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Task")
    |> assign(:task, %Task{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    task = Tasks.get_task!(id)

    socket
    |> assign(:page_title, "Edit Task")
    |> assign(:task, task)
  end

  @impl true
  def handle_info({DevtodoWeb.TaskLive.FormComponent, {:saved, _task}}, socket) do
    counts = Tasks.count_by_status()
    tags = Tasks.all_tags()

    {:noreply,
     socket
     |> assign(:counts, counts)
     |> assign(:tags, tags)
     |> load_tasks()}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:ok, _} = Tasks.delete_task(task)
    counts = Tasks.count_by_status()

    {:noreply,
     socket
     |> assign(:counts, counts)
     |> load_tasks()
     |> put_flash(:info, "Task deleted")}
  end

  def handle_event("toggle_status", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:ok, _} = Tasks.toggle_status(task)
    counts = Tasks.count_by_status()

    {:noreply,
     socket
     |> assign(:counts, counts)
     |> load_tasks()}
  end

  def handle_event("filter_status", %{"status" => status}, socket) do
    status_atom = if status == "all", do: :all, else: String.to_existing_atom(status)
    filters = Map.put(socket.assigns.filters, :status, status_atom)

    {:noreply,
     socket
     |> assign(:filters, filters)
     |> load_tasks()}
  end

  def handle_event("filter_priority", %{"priority" => priority}, socket) do
    priority_atom = if priority == "all", do: :all, else: String.to_existing_atom(priority)
    filters = Map.put(socket.assigns.filters, :priority, priority_atom)

    {:noreply,
     socket
     |> assign(:filters, filters)
     |> load_tasks()}
  end

  def handle_event("filter_project", %{"project_id" => project_id}, socket) do
    project_id_value =
      cond do
        project_id == "all" -> :all
        project_id == "" -> :all
        true -> String.to_integer(project_id)
      end

    filters = Map.put(socket.assigns.filters, :project_id, project_id_value)

    {:noreply,
     socket
     |> assign(:filters, filters)
     |> load_tasks()}
  end

  def handle_event("filter_tag", %{"tag" => tag}, socket) do
    tag_value = if tag == "", do: nil, else: tag
    filters = Map.put(socket.assigns.filters, :tag, tag_value)

    {:noreply,
     socket
     |> assign(:filters, filters)
     |> load_tasks()}
  end

  def handle_event("search", %{"search" => search}, socket) do
    filters = Map.put(socket.assigns.filters, :search, search)

    {:noreply,
     socket
     |> assign(:filters, filters)
     |> load_tasks()}
  end

  def handle_event("clear_filters", _params, socket) do
    filters = %{status: :all, priority: :all, project_id: :all, tag: nil, search: ""}

    {:noreply,
     socket
     |> assign(:filters, filters)
     |> load_tasks()}
  end

  defp load_tasks(socket) do
    filters = socket.assigns.filters
    opts = [
      status: filters.status,
      priority: filters.priority,
      project_id: filters.project_id,
      tag: filters.tag,
      search: filters.search
    ]
    tasks = Tasks.list_tasks(opts)
    assign(socket, :tasks, tasks)
  end

  # Helpers for templates

  def status_label(:todo), do: "Todo"
  def status_label(:in_progress), do: "In Progress"
  def status_label(:done), do: "Done"
  def status_label(:blocked), do: "Blocked"

  def priority_label(:low), do: "Low"
  def priority_label(:medium), do: "Medium"
  def priority_label(:high), do: "High"
  def priority_label(:urgent), do: "Urgent"

  def status_class(:todo), do: "bg-gray-700 text-gray-300"
  def status_class(:in_progress), do: "bg-blue-900/60 text-blue-300"
  def status_class(:done), do: "bg-green-900/60 text-green-300"
  def status_class(:blocked), do: "bg-red-900/60 text-red-300"

  def priority_class(:low), do: "text-gray-500"
  def priority_class(:medium), do: "text-yellow-500"
  def priority_class(:high), do: "text-orange-500"
  def priority_class(:urgent), do: "text-red-500"

  def priority_dot(:low), do: "bg-gray-500"
  def priority_dot(:medium), do: "bg-yellow-500"
  def priority_dot(:high), do: "bg-orange-500"
  def priority_dot(:urgent), do: "bg-red-500"

  def overdue?(%Task{due_date: nil}), do: false
  def overdue?(%Task{status: :done}), do: false
  def overdue?(%Task{due_date: due_date}) do
    Date.compare(due_date, Date.utc_today()) == :lt
  end

  def due_soon?(%Task{due_date: nil}), do: false
  def due_soon?(%Task{status: :done}), do: false
  def due_soon?(%Task{due_date: due_date}) do
    days = Date.diff(due_date, Date.utc_today())
    days >= 0 && days <= 3
  end

  def status_ring_color(:todo), do: "#4b5563"
  def status_ring_color(:in_progress), do: "#3b82f6"
  def status_ring_color(:done), do: "#22c55e"
  def status_ring_color(:blocked), do: "#ef4444"

  def status_bg_color(:todo), do: "transparent"
  def status_bg_color(:in_progress), do: "rgba(59,130,246,0.1)"
  def status_bg_color(:done), do: "rgba(34,197,94,0.15)"
  def status_bg_color(:blocked), do: "rgba(239,68,68,0.1)"
end
