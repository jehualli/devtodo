defmodule Devtodo.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string, null: false
      add :description, :text
      add :color, :string, default: "#6366f1"

      timestamps(type: :utc_datetime)
    end

    create index(:projects, [:name])
  end
end
