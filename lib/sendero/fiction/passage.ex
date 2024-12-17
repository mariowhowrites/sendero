defmodule Sendero.Fiction.Passage do
  alias Sendero.Fiction.{Link, Story}
  use Ecto.Schema
  import Ecto.Changeset

  schema "passages" do
    field :status, Ecto.Enum, values: [:draft, :active, :inactive]
    field :title, :string
    field :content, :string
    field :root, :boolean
    belongs_to :story, Story
    has_many :origin_links, Link, foreign_key: :destination_passage_id
    has_many :destination_links, Link, foreign_key: :origin_passage_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(passage, attrs) do
    passage
    |> cast(attrs, [:title, :content, :status, :root])
    |> validate_required([:title, :content, :status])
  end
end
