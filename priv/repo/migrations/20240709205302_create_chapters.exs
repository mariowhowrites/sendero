defmodule Sendero.Repo.Migrations.CreateChapters do
  use Ecto.Migration

  def change do
    create table(:chapters) do
      add :title, :string
      add :content, :text
      add :status, :string
      add :root, :boolean, default: false
      add :story_id, references(:stories, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:chapters, [:story_id])
  end
end
