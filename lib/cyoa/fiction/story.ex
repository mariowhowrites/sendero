defmodule Cyoa.Fiction.Story do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stories" do
    field :description, :string
    field :title, :string
    field :author_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(story, attrs) do
    story
    |> cast(attrs, [:title, :description])
    |> validate_required([:title, :description])
  end
end
