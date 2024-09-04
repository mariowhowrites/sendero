defmodule Sendero.FictionFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sendero.Fiction` context.
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
      |> Sendero.Fiction.create_story()

    story
  end

  def chapter_fixture(attrs \\ %{}) do
    # if attrs[:story_id] is not set, create a story

    story =
      case attrs[:story_id] do
        nil -> story_fixture()
        _ -> Sendero.Fiction.get_story!(attrs[:story_id])
      end

    chapter =
      attrs
      |> Enum.into(%{
        content: "some content",
        status: :active,
        title: "some title",
        story_id: story.id
      })

    {:ok, chapter} = Sendero.Fiction.add_root_chapter(story, chapter)

    chapter
  end

  def link_fixture(attrs \\ %{}) do
    origin_chapter =
      case attrs[:origin_chapter_id] do
        nil -> chapter_fixture()
        _ -> Sendero.Fiction.get_chapter!(attrs[:origin_chapter_id])
      end

    destination_chapter =
      case attrs[:destination_chapter_id] do
        nil -> chapter_fixture()
        _ -> Sendero.Fiction.get_chapter!(attrs[:destination_chapter_id])
      end

    link =
      attrs
      |> Enum.into(%{
        title: "some title",
        content: "some content",
        origin_chapter_id: origin_chapter.id,
        destination_chapter_id: destination_chapter.id
      })

    {:ok, link} = Sendero.Fiction.add_destination_link(origin_chapter, link)

    link
  end
end
