defmodule Sendero.Fiction.StoryTest do
  use Sendero.DataCase

  alias Sendero.Fiction.Story
  import Sendero.FictionFixtures

  describe "all/0" do
    test "returns all stories" do
      user = user_fixture()
      story = story_fixture(%{author_id: user.id})
      assert Story.all() == [story]
    end
  end

  describe "create/1" do
    test "requires an author" do
      assert {:error, changeset} = Story.create(%{title: "My Story"})
      assert "can't be blank" in errors_on(changeset).author_id
    end

    test "requires a title" do
      assert {:error, changeset} = Story.create(%{author_id: 1})
      assert "can't be blank" in errors_on(changeset).title
    end

    test "requires a valid author" do
      assert {:error, changeset} = Story.create(%{title: "My Story", author_id: 999})
      assert "does not exist" in errors_on(changeset).author_id
    end

    test "creates a story" do
      user = user_fixture()
      assert {:ok, story} = Story.create(%{title: "My Story", author_id: user.id})
      assert story.title == "My Story"
      assert story.author_id == user.id
    end
  end

  describe "delete/1" do
    test "deletes a story" do
      user = user_fixture()
      story = story_fixture(%{author_id: user.id})
      assert {:ok, _} = Story.delete(story)
      assert_raise Ecto.NoResultsError, fn -> Story.get!(story.id) end
    end
  end
end
