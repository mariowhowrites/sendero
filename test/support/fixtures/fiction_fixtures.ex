defmodule Cyoa.FictionFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Cyoa.Fiction` context.
  """

  @doc """
  Generate a story.
  """
  def story_fixture(attrs \\ %{}) do
    {:ok, story} =
      attrs
      |> Enum.into(%{
        description: "some description",
        title: "some title"
      })
      |> Cyoa.Fiction.create_story()

    story
  end
end
