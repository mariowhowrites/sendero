defmodule Sendero.Fiction.Story do
  alias Sendero.Accounts.User
  use Ecto.Schema
  import Ecto.Changeset

  schema "stories" do
    field :description, :string
    field :title, :string
    field :start_node, :string

    belongs_to :author, User, foreign_key: :author_id
    has_many :passages, Sendero.Fiction.Passage

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(story, attrs) do
    story
    |> cast(attrs, [:title, :description, :start_node, :author_id])
    |> validate_required([:title, :author_id])
  end
end
