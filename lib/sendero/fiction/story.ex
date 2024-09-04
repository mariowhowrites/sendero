defmodule Sendero.Fiction.Story do
  alias Sendero.Accounts.User
  use Ecto.Schema
  import Ecto.Changeset

  schema "stories" do
    field :description, :string
    field :title, :string
    field :metadata, :map

    belongs_to :author, User, foreign_key: :author_id
    has_many :chapters, Sendero.Fiction.Chapter

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(story, attrs) do
    story
    |> cast(attrs, [:title, :description, :metadata])
    |> validate_required([:title])
  end
end
