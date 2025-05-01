defmodule Sendero.Fiction.Story do
  alias Sendero.Accounts.User
  alias Sendero.Repo
  alias Sendero.Fiction.Story

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "stories" do
    field :description, :string
    field :title, :string
    field :start_node, :string

    belongs_to :author, User, foreign_key: :author_id
    has_many :passages, Sendero.Fiction.Passage

    timestamps(type: :utc_datetime)
  end

  def changeset(%Story{} = story, attrs \\ %{}) do
    story
    |> cast(attrs, [:title, :description, :start_node, :author_id])
    |> validate_required([:title, :author_id])
    |> foreign_key_constraint(:author_id)
  end

  # CRUD

  def all(), do: Repo.all(Story)

  def get!(id), do: Repo.get!(Story, id)

  def create(attrs \\ %{}) do
    %Story{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def update(%Story{} = story, attrs) do
    story
    |> changeset(attrs)
    |> Repo.update()
  end

  def delete(%Story{} = story) do
    Repo.delete(story)
  end
end
