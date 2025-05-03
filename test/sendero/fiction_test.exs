defmodule Sendero.FictionTest do
  use Sendero.DataCase

  alias Sendero.Fiction

  describe "stories" do
    alias Sendero.Fiction.{Passage, Story}

    import Sendero.FictionFixtures

    @invalid_attrs %{description: nil, title: nil}

    test "creates a passage" do
      user = user_fixture(%{})
      story = story_fixture(%{author_id: user.id})

      passage_attrs = %{
        name: "My Passage",
        content: "This is a test passage",
        status: :draft,
        story_id: story.id
      }

      assert {:ok, %Passage{} = passage} = Fiction.create_passage(passage_attrs)
      assert passage.name == "My Passage"
      assert passage.content == "This is a test passage"
      assert passage.story_id == story.id
      assert passage.status == :draft

      passage = Repo.preload(passage, :story)
      assert passage.story.id == story.id
      assert passage.story.title == story.title
    end

    test "create_story_with_passages/2 creates a story with its passages and links" do
      user = user_fixture()

      input = %{
        links: [
          %{
            title: "run away",
            content: "run away",
            origin_passage_index: 0,
            destination_passage_index: 1
          },
          %{
            title: "try to pet it",
            content: "try to pet it",
            origin_passage_index: 0,
            destination_passage_index: 2
          },
          %{
            title: "keep running",
            content: "keep running",
            origin_passage_index: 1,
            destination_passage_index: 3
          },
          %{
            title: "climb a tree",
            content: "climb a tree",
            origin_passage_index: 1,
            destination_passage_index: 4
          }
        ],
        story: %{
          title: "sample story for great learning",
          start_node: "1",
          author_id: user.id,
          ifid: "B85EACA2-E692-488E-9AF0-244B2E156D01"
        },
        passages: [
          %{
            name: "Chapter 1",
            status: :draft,
            root: true,
            content: "You see a boar in the woods.\n\n[[run away]]\n\n[[try to pet it]]"
          },
          %{
            name: "run away",
            status: :draft,
            root: false,
            content:
              "You turn to run. The boar snorts and follows you\n\n[[keep running]]\n\n[[climb a tree]]"
          },
          %{
            name: "try to pet it",
            status: :draft,
            root: false,
            content: "The boar purrs. You are now friends"
          },
          %{
            name: "keep running",
            status: :draft,
            root: false,
            content: "Haha you thought you could outrun a boar and now you are dead"
          },
          %{
            name: "climb a tree",
            status: :draft,
            root: false,
            content: "that was kinda mean boars cant climb"
          }
        ]
      }

      assert {
               :ok,
               %{
                 story: %Fiction.Story{} = story,
                 passages: passages,
                 links: links
               }
             } = Fiction.create_story_with_passages(input)

      assert length(passages) == 5
      assert Enum.all?(passages, &match?(%Fiction.Passage{}, &1))
      assert length(links) == 4
      assert Enum.all?(links, &match?(%Fiction.Link{}, &1))
    end
  end

  # describe "wings" do
  #   alias Sendero.Fiction.{Wing, Story}

  #   import Sendero.FictionFixtures

  #   test "creating a story creates a default wing with the root passage" do
  #     {passage, story} = passage_fixture()

  #     assert wing.story_id == story.id
  #     assert wing.status == :closed
  #   end
  # end
end
