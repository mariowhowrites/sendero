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
      |> Sendero.Fiction.Story.create()

    story
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "user@example.com",
        password: "coolpassword123"
      })
      |> Sendero.Accounts.register_user()

    user
  end

  def passage_fixture(attrs \\ %{}) do
    # if attrs[:story_id] is not set, create a story

    story =
      case attrs[:story_id] do
        nil -> story_fixture()
        _ -> Sendero.Fiction.Story.get!(attrs[:story_id])
      end

    passage =
      attrs
      |> Enum.into(%{
        content: "some content",
        status: :active,
        title: "some title",
        story_id: story.id
      })

    {:ok, passage} = Sendero.Fiction.Passage.create_root(passage)

    {passage, story}
  end

  def link_fixture(attrs \\ %{}) do
    origin_passage =
      case attrs[:origin_passage_id] do
        nil -> passage_fixture()
        _ -> Sendero.Fiction.Passage.get!(attrs[:origin_passage_id])
      end

    destination_passage =
      case attrs[:destination_passage_id] do
        nil -> passage_fixture()
        _ -> Sendero.Fiction.Passage.get!(attrs[:destination_passage_id])
      end

    link =
      attrs
      |> Enum.into(%{
        title: "some title",
        content: "some content",
        origin_passage_id: origin_passage.id,
        destination_passage_id: destination_passage.id
      })

    {:ok, link} = Sendero.Fiction.add_destination_link(origin_passage, link)

    link
  end
end
