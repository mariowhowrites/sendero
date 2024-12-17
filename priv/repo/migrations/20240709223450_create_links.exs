defmodule Sendero.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :title, :string
      add :content, :text
      add :origin_passage_id, references(:passages, on_delete: :nothing)
      add :destination_passage_id, references(:passages, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:links, [:origin_passage_id])
    create index(:links, [:destination_passage_id])
  end
end
