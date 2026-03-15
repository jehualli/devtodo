defmodule Devtodo.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses [:todo, :in_progress, :done, :blocked]
  @priorities [:low, :medium, :high, :urgent]

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :status, Ecto.Enum, values: @statuses, default: :todo
    field :priority, Ecto.Enum, values: @priorities, default: :medium
    field :due_date, :date
    field :tags, {:array, :string}, default: []
    field :position, :integer, default: 0

    belongs_to :project, Devtodo.Projects.Project

    timestamps(type: :utc_datetime)
  end

  def statuses, do: @statuses
  def priorities, do: @priorities

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :status, :priority, :due_date, :tags, :position, :project_id])
    |> validate_required([:title])
    |> validate_length(:title, min: 1, max: 255)
    |> validate_inclusion(:status, @statuses)
    |> validate_inclusion(:priority, @priorities)
  end
end
