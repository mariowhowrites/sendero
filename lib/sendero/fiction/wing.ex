defmodule Sendero.Fiction.Wing do
  @moduledoc """
  A wing is a collection of passages within a given story.

  Wings can be open or closed. When a story begins, all wings are closed except the wing containing the root passage.

  Authors can open wings if that wing has a door connected to a currently open wing.

  Authors open wings in response to reader votes.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "wings" do
    belongs_to :story, Story
    has_many :passages, Passage

    field :status, Ecto.Enum, values: [:closed, :open]

    timestamps(type: :utc_datetime)
  end

  def changeset(wing, attrs) do
    wing
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end

  def all_by_story(story_id) do
    from(w in Wing, where: w.story_id == ^story_id)
  end
end
