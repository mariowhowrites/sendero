defmodule Sendero.FictionTweeImporterTest do
  use Sendero.DataCase

  alias Sendero.Fiction.Importer.Twee
  alias Sendero.Fiction.Importer.Twee.Story

  describe "twee" do
    test "from_path/1 takes a .twee file and returns a story struct" do
      path = "test/support/fixtures/sample story.twee"
      story = Twee.from_path(path)

      assert story.title == "sample story for great learning"

      assert story.metadata == %{
               "format" => "Harlowe",
               "format-version" => "3.3.9",
               "ifid" => "B85EACA2-E692-488E-9AF0-244B2E156D01",
               "start" => "Passage 1",
               "tag-colors" => %{
                 "tag1" => "orange",
                 "tag2" => "purple"
               },
               "zoom" => 1
             }

      assert length(story.passages) == 5
    end

    test "passages_from_path/1 divides the file into passages" do
      path = "test/support/fixtures/sample story.twee"
      passages = Twee.passages_from_path(path)

      assert length(passages) == 7
    end

    test "parse/2 returns the title of the story" do
      text = """
      :: StoryTitle
      Sample Story
      """

      story = Twee.parse(text, %Story{})

      assert story.title == "Sample Story"
    end

    test "parse/2 returns story metadata" do
      text = """
      :: StoryData
      {
        "something": "something else",
        "wow": "cool"
      }
      """

      story = Twee.parse(text, %Story{})

      assert story.metadata == %{
               "something" => "something else",
               "wow" => "cool"
             }
    end

    test "parse/2 returns passage data (no links)" do
      text = """
      :: try to pet it [tag1 tag2] {"position":"775,450","size":"100,100"}
      The boar purrs. You are now friends
      """

      story = Twee.parse(text, %Story{})

      assert length(story.passages) == 1
      [passage] = story.passages

      assert passage.title == "try to pet it"
      assert passage.tags == ["tag1", "tag2"]

      assert passage.metadata == %{
               "position" => "775,450",
               "size" => "100,100"
             }

      assert passage.content == "The boar purrs. You are now friends"
      assert passage.links == []
    end

    test "parse/2 returns passage data (with links)" do
      text = """
      :: run away [tag3] {"position":"637.5,450","size":"100,100"}
      You turn to run. The boar snorts and follows you

      [[keep running]]

      [[climb a tree]]
      """

      story = Twee.parse(text, %Story{})

      assert length(story.passages) == 1
      [passage] = story.passages

      assert passage.title == "run away"
      assert passage.tags == ["tag3"]

      assert passage.metadata == %{
               "position" => "637.5,450",
               "size" => "100,100"
             }

      assert passage.content ==
               """
               You turn to run. The boar snorts and follows you
               """
               |> String.trim_trailing("\n")

      assert passage.links == ["keep running", "climb a tree"]
    end

    test "parse/2 propely treats tags and metadata as optional" do
      text = ":: Passage 1"
      story = Twee.parse(text, %Story{})
      [passage] = story.passages

      assert passage.title == "Passage 1"
      assert passage.tags == []
      assert passage.metadata == %{}

      text = ":: Passage 2 [tag1 tag2]"
      story = Twee.parse(text, %Story{})
      [passage] = story.passages

      assert passage.title == "Passage 2"
      assert passage.tags == ["tag1", "tag2"]
      assert passage.metadata == %{}

      text = ":: Passage 3 {\"position\":\"775,450\",\"size\":\"100,100\"}"
      story = Twee.parse(text, %Story{})
      [passage] = story.passages

      assert passage.title == "Passage 3"
      assert passage.tags == []
      assert passage.metadata == %{"position" => "775,450", "size" => "100,100"}
    end
  end
end
