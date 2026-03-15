defmodule Devtodo.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :name, :string
    field :description, :string
    field :color, :string, default: "#6366f1"

    has_many :tasks, Devtodo.Tasks.Task

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :description, :color])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 100)
  end
end
