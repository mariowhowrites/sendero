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

    # test "add_root_passage/2 adds the root_passage to the story" do
    #   story = story_fixture()

    #   valid_passage_attrs = %{
    #     content: "some content",
    #     status: :active,
    #     title: "some title"
    #   }

    #   assert {:ok, %Sendero.Fiction.Passage{} = root_passage} = Fiction.add_root_passage(story, valid_passage_attrs)
    #   assert root_passage.content == "some content"
    #   assert root_passage.title == "some title"
    #   assert root_passage.status == :active
    #   assert story == root_passage.story
    # end

    # test "add_root_passage/2 with invalid data returns error changeset" do
    #   story = story_fixture()

    #   invalid_passage_attrs = %{
    #     content: nil,
    #     status: :active,
    #     title: nil
    #   }

    #   assert {:error, %Ecto.Changeset{}} = Fiction.add_root_passage(story, invalid_passage_attrs)
    # end

    # test "add_destination_link/2 adds a destination link to the passage" do
    #   passage = passage_fixture()

    #   valid_link_attrs = %{
    #     from_passage_id: passage.id,
    #     content: "some content",
    #     title: "some title"
    #   }

    #   assert {:ok, %Sendero.Fiction.Link{} = link} = Fiction.add_destination_link(passage, valid_link_attrs)
    # end

    test "import_story_from_twee/1 imports a story from a twee file" do
      assert {:ok, %Story{} = story} =
               Fiction.import_story_from_twee("test/support/fixtures/sample story.twee")

      assert story.title == "sample story for great learning"
      assert map_size(story) > 0

      # Verify all passages were created
      passages = Repo.preload(story, :passages).passages
      assert length(passages) == 5

      # Check specific passages
      passage_1 = Enum.find(passages, fn passage -> passage.title == "Passage 1" end)
      assert passage_1.content =~ "You see a boar in the woods."
      assert passage_1.root == true

      passage_2 = Enum.find(passages, fn passage -> passage.title == "run away" end)
      assert passage_2.content =~ "You turn to run. The boar snorts and follows you"

      # Verify links between passages
      links =
        Repo.all(
          from l in Sendero.Fiction.Link,
            where: l.origin_passage_id in ^Enum.map(passages, & &1.id)
        )

      # Total number of links in the sample story
      assert length(links) == 4

      # Check specific links
      passage_1_links = Enum.filter(links, &(&1.origin_passage_id == passage_1.id))
      assert length(passage_1_links) == 2
      assert Enum.any?(passage_1_links, &(&1.destination_passage_id == passage_2.id))

      # Verify the "climb a tree" passage is linked from "run away"
      climb_tree_passage = Enum.find(passages, fn passage -> passage.title == "climb a tree" end)

      assert Enum.any?(
               links,
               &(&1.origin_passage_id == passage_2.id and
                   &1.destination_passage_id == climb_tree_passage.id)
             )
    end
  end
end
