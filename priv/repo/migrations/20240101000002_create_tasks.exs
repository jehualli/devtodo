defmodule Devtodo.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string, null: false
      add :description, :text
      add :status, :string, default: "todo", null: false
      add :priority, :string, default: "medium", null: false
      add :due_date, :date
      add :tags, :string, default: "[]"
      add :position, :integer, default: 0
      add :project_id, references(:projects, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:tasks, [:status])
    create index(:tasks, [:priority])
    create index(:tasks, [:project_id])
    create index(:tasks, [:due_date])
  end
end
