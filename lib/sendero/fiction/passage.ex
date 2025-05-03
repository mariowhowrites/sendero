defmodule Sendero.Fiction.Passage do
  alias Sendero.Fiction.{Link, Story, Passage}
  alias Sendero.Repo
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "passages" do
    field :status, Ecto.Enum, values: [:draft, :active, :inactive]
    field :name, :string
    field :content, :string
    field :root, :boolean
    belongs_to :story, Story
    has_many :origin_links, Link, foreign_key: :destination_passage_id
    has_many :destination_links, Link, foreign_key: :origin_passage_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%Passage{} = passage, attrs \\ %{}) do
    passage
    |> cast(attrs, [:name, :content, :status, :root, :story_id])
    |> validate_required([:name, :content, :status, :story_id])
  end

  # CRUD

  def get!(id), do: Repo.get!(Passage, id)

  def create(attrs, repo \\ Repo) do
    %Passage{}
    |> changeset(attrs)
    |> repo.insert()
  end

  def create_root(attrs) do
    attrs
    |> Map.put(:root, true)
    |> create()
  end

  def update(%Passage{} = passage, attrs) do
    passage
    |> changeset(attrs)
    |> Repo.update()
  end

  def delete(%Passage{} = passage) do
    Repo.delete(passage)
  end

  def all_by_story_id(story_id) do
    Repo.all(from p in Passage, where: p.story_id == ^story_id)
  end
end
