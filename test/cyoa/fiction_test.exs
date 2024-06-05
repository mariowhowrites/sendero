defmodule Cyoa.FictionTest do
  use Cyoa.DataCase

  alias Cyoa.Fiction

  describe "stories" do
    alias Cyoa.Fiction.Story

    import Cyoa.FictionFixtures

    @invalid_attrs %{description: nil, title: nil}

    test "list_stories/0 returns all stories" do
      story = story_fixture()
      assert Fiction.list_stories() == [story]
    end

    test "get_story!/1 returns the story with given id" do
      story = story_fixture()
      assert Fiction.get_story!(story.id) == story
    end

    test "create_story/1 with valid data creates a story" do
      valid_attrs = %{description: "some description", title: "some title"}

      assert {:ok, %Story{} = story} = Fiction.create_story(valid_attrs)
      assert story.description == "some description"
      assert story.title == "some title"
    end

    test "create_story/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fiction.create_story(@invalid_attrs)
    end

    test "update_story/2 with valid data updates the story" do
      story = story_fixture()
      update_attrs = %{description: "some updated description", title: "some updated title"}

      assert {:ok, %Story{} = story} = Fiction.update_story(story, update_attrs)
      assert story.description == "some updated description"
      assert story.title == "some updated title"
    end

    test "update_story/2 with invalid data returns error changeset" do
      story = story_fixture()
      assert {:error, %Ecto.Changeset{}} = Fiction.update_story(story, @invalid_attrs)
      assert story == Fiction.get_story!(story.id)
    end

    test "delete_story/1 deletes the story" do
      story = story_fixture()
      assert {:ok, %Story{}} = Fiction.delete_story(story)
      assert_raise Ecto.NoResultsError, fn -> Fiction.get_story!(story.id) end
    end

    test "change_story/1 returns a story changeset" do
      story = story_fixture()
      assert %Ecto.Changeset{} = Fiction.change_story(story)
    end
  end
end
