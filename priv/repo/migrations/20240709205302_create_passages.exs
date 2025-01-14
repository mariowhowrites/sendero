defmodule Sendero.Repo.Migrations.CreatePassages do
  use Ecto.Migration

  def change do
    create table(:passages) do
      add :name, :string
      add :content, :text
      add :status, :string
      add :root, :boolean, default: false
      add :story_id, references(:stories, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:passages, [:story_id])
  end
end
