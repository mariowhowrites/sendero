defmodule Sendero.Fiction.Link do
  alias Sendero.Fiction.Chapter
  use Ecto.Schema
  import Ecto.Changeset

  schema "links" do
    field :title, :string
    field :content, :string
    belongs_to :origin_chapter, Chapter, foreign_key: :origin_chapter_id
    belongs_to :destination_chapter, Chapter, foreign_key: :destination_chapter_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [:title, :content, :origin_chapter_id, :destination_chapter_id])
    |> validate_required([:title, :content, :origin_chapter_id, :destination_chapter_id])
  end
end
