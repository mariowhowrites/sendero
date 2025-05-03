defmodule Sendero.Repo.Migrations.CreateStories do
  use Ecto.Migration

  def change do
    create table(:wings) do
      add :status, :string
      add :story_id, references(:stories, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:wings, [:story_id])
  end
end
