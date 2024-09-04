defmodule Sendero.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :title, :string
      add :content, :text
      add :origin_chapter_id, references(:chapters, on_delete: :nothing)
      add :destination_chapter_id, references(:chapters, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:links, [:origin_chapter_id])
    create index(:links, [:destination_chapter_id])
  end
end
