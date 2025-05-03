defmodule Sendero.Fiction.Link do
  alias Sendero.Fiction.{Passage, Link}
  alias Sendero.Repo
  import Ecto.Changeset
  import Ecto.Query, warn: false
  use Ecto.Schema

  schema "links" do
    field :title, :string
    field :content, :string
    belongs_to :origin_passage, Passage, foreign_key: :origin_passage_id
    belongs_to :destination_passage, Passage, foreign_key: :destination_passage_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [:title, :content, :origin_passage_id, :destination_passage_id])
    |> validate_required([:title, :content, :origin_passage_id, :destination_passage_id])
  end

  # CRUD

  def create(attrs, repo \\ Repo) do
    %Link{}
    |> Link.changeset(attrs)
    |> repo.insert()
  end

  def delete(%Link{} = link) do
    Repo.delete(link)
  end
end
