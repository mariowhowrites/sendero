defmodule Sendero.FictionTest do
  use Sendero.DataCase

  alias Sendero.Fiction

  describe "stories" do
    alias Sendero.Fiction.Story

    import Sendero.FictionFixtures

    @invalid_attrs %{description: nil, title: nil}

    # test "list_stories/0 returns all stories" do
    #   story = story_fixture()
    #   assert Fiction.list_stories() == [story]
    # end

    # test "get_story!/1 returns the story with given id" do
    #   story = story_fixture()
    #   assert Fiction.get_story!(story.id) == story
    # end

    # test "create_story/1 with valid data creates a story" do
    #   valid_attrs = %{description: "some description", title: "some title"}

    #   assert {:ok, %Story{} = story} = Fiction.create_story(valid_attrs)
    #   assert story.description == "some description"
    #   assert story.title == "some title"
    # end

    # test "create_story/1 with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} = Fiction.create_story(@invalid_attrs)
    # end

    # test "update_story/2 with valid data updates the story" do
    #   story = story_fixture()
    #   update_attrs = %{description: "some updated description", title: "some updated title"}

    #   assert {:ok, %Story{} = story} = Fiction.update_story(story, update_attrs)
    #   assert story.description == "some updated description"
    #   assert story.title == "some updated title"
    # end

    # test "update_story/2 with invalid data returns error changeset" do
    #   story = story_fixture()
    #   assert {:error, %Ecto.Changeset{}} = Fiction.update_story(story, @invalid_attrs)
    #   assert story == Fiction.get_story!(story.id)
    # end

    # test "delete_story/1 deletes the story" do
    #   story = story_fixture()
    #   assert {:ok, %Story{}} = Fiction.delete_story(story)
    #   assert_raise Ecto.NoResultsError, fn -> Fiction.get_story!(story.id) end
    # end

    # test "change_story/1 returns a story changeset" do
    #   story = story_fixture()
    #   assert %Ecto.Changeset{} = Fiction.change_story(story)
    # end

    # test "add_root_chapter/2 adds the root_chapter to the story" do
    #   story = story_fixture()

    #   valid_chapter_attrs = %{
    #     content: "some content",
    #     status: :active,
    #     title: "some title"
    #   }

    #   assert {:ok, %Sendero.Fiction.Chapter{} = root_chapter} = Fiction.add_root_chapter(story, valid_chapter_attrs)
    #   assert root_chapter.content == "some content"
    #   assert root_chapter.title == "some title"
    #   assert root_chapter.status == :active
    #   assert story == root_chapter.story
    # end

    # test "add_root_chapter/2 with invalid data returns error changeset" do
    #   story = story_fixture()

    #   invalid_chapter_attrs = %{
    #     content: nil,
    #     status: :active,
    #     title: nil
    #   }

    #   assert {:error, %Ecto.Changeset{}} = Fiction.add_root_chapter(story, invalid_chapter_attrs)
    # end

    # test "add_destination_link/2 adds a destination link to the chapter" do
    #   chapter = chapter_fixture()

    #   valid_link_attrs = %{
    #     from_chapter_id: chapter.id,
    #     content: "some content",
    #     title: "some title"
    #   }

    #   assert {:ok, %Sendero.Fiction.Link{} = link} = Fiction.add_destination_link(chapter, valid_link_attrs)
    # end

    test "import_story_from_twee/1 imports a story from a twee file" do
      assert {:ok, %Story{} = story} =
               Fiction.import_story_from_twee("test/support/fixtures/sample story.twee")

      assert story.title == "sample story for great learning"
      assert map_size(story.metadata) > 0

      # Verify all chapters were created
      chapters = Repo.preload(story, :chapters).chapters
      assert length(chapters) == 5

      # Check specific chapters
      chapter_1 = Enum.find(chapters, fn chapter -> chapter.title == "Chapter 1" end)
      assert chapter_1.content =~ "You see a boar in the woods."
      assert chapter_1.root == true

      chapter_2 = Enum.find(chapters, fn chapter -> chapter.title == "run away" end)
      assert chapter_2.content =~ "You turn to run. The boar snorts and follows you"

      # Verify links between chapters
      links =
        Repo.all(
          from l in Sendero.Fiction.Link, where: l.origin_chapter_id in ^Enum.map(chapters, &(&1.id))
        )

      # Total number of links in the sample story
      assert length(links) == 4

      # Check specific links
      chapter_1_links = Enum.filter(links, &(&1.origin_chapter_id == chapter_1.id))
      assert length(chapter_1_links) == 2
      assert Enum.any?(chapter_1_links, &(&1.destination_chapter_id == chapter_2.id))

      # Verify the "climb a tree" chapter is linked from "run away"
      climb_tree_chapter = Enum.find(chapters, fn chapter -> chapter.title == "climb a tree" end)

      assert Enum.any?(
               links,
               &(&1.origin_chapter_id == chapter_2.id and
                   &1.destination_chapter_id == climb_tree_chapter.id)
             )
    end
  end
end
