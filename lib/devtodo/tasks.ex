defmodule Devtodo.Tasks do
  import Ecto.Query, warn: false
  alias Devtodo.Repo
  alias Devtodo.Tasks.Task

  def list_tasks(opts \\ []) do
    base_query()
    |> apply_filters(opts)
    |> apply_search(opts[:search])
    |> order_by_priority_and_due()
    |> Repo.all()
  end

  defp base_query do
    from t in Task, preload: [:project]
  end

  defp apply_filters(query, opts) do
    query
    |> filter_by_status(opts[:status])
    |> filter_by_priority(opts[:priority])
    |> filter_by_project(opts[:project_id])
    |> filter_by_tag(opts[:tag])
  end

  defp filter_by_status(query, nil), do: query
  defp filter_by_status(query, :all), do: query
  defp filter_by_status(query, status), do: where(query, [t], t.status == ^status)

  defp filter_by_priority(query, nil), do: query
  defp filter_by_priority(query, :all), do: query
  defp filter_by_priority(query, priority), do: where(query, [t], t.priority == ^priority)

  defp filter_by_project(query, nil), do: query
  defp filter_by_project(query, :all), do: query
  defp filter_by_project(query, project_id), do: where(query, [t], t.project_id == ^project_id)

  defp filter_by_tag(query, nil), do: query
  defp filter_by_tag(query, ""), do: query
  defp filter_by_tag(query, tag) do
    where(query, [t], fragment("? LIKE ?", t.tags, ^"%#{tag}%"))
  end

  defp apply_search(query, nil), do: query
  defp apply_search(query, ""), do: query
  defp apply_search(query, search) do
    term = "%#{search}%"
    where(query, [t], ilike(t.title, ^term) or ilike(t.description, ^term))
  end

  defp order_by_priority_and_due(query) do
    from t in query,
      order_by: [
        asc: fragment("CASE t0.status WHEN 'blocked' THEN 0 WHEN 'in_progress' THEN 1 WHEN 'todo' THEN 2 WHEN 'done' THEN 3 ELSE 4 END"),
        asc: fragment("CASE t0.priority WHEN 'urgent' THEN 0 WHEN 'high' THEN 1 WHEN 'medium' THEN 2 WHEN 'low' THEN 3 ELSE 4 END"),
        asc: t.due_date,
        asc: t.inserted_at
      ]
  end

  def get_task!(id), do: Repo.get!(Task, id) |> Repo.preload(:project)

  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  def delete_task(%Task{} = task), do: Repo.delete(task)

  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  def toggle_status(%Task{} = task) do
    next = next_status(task.status)
    update_task(task, %{status: next})
  end

  defp next_status(:todo), do: :in_progress
  defp next_status(:in_progress), do: :done
  defp next_status(:done), do: :todo
  defp next_status(:blocked), do: :todo

  def count_by_status do
    from(t in Task,
      group_by: t.status,
      select: {t.status, count(t.id)}
    )
    |> Repo.all()
    |> Enum.into(%{})
  end

  def all_tags do
    from(t in Task, select: t.tags)
    |> Repo.all()
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort()
  end
end
