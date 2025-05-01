defmodule Sendero.Fiction.Importer.Twee do
  defmodule Story do
    @type t :: %__MODULE__{
            title: String.t(),
            metadata: map(),
            passages: [map()]
          }

    defstruct title: "", metadata: %{}, passages: []
  end

  defmodule Passage do
    @type t :: %__MODULE__{
            name: String.t(),
            tags: [String.t()],
            metadata: map(),
            content: String.t(),
            links: [String.t()]
          }

    defstruct name: "", tags: [], metadata: %{}, content: "", links: []
  end

  @spec from_path(Path.t()) :: Story.t()
  def from_path(path) do
    passages_from_path(path)
    |> Enum.reduce(%Story{}, &parse/2)
  end

  def passages_from_path(path) do
    File.read!(path)
    |> String.split("\n\n\n")
  end

  def parse(":: StoryTitle" <> text, story) do
    Map.put(story, :title, text |> String.trim())
  end

  def parse(":: StoryData" <> text, story) do
    Map.put(story, :metadata, text |> String.trim() |> Jason.decode!())
  end

  def parse(text, story) do
    [header | content] = String.split(text, "\n", parts: 2)

    passage =
      %Passage{}
      |> Map.merge(parse_passage_header(header))
      |> Map.merge(parse_passage_content(content))

    Map.put(story, :passages, [passage | story.passages])
  end

  # format of passage headers is :: name [tags] {metadata}
  def parse_passage_header(header) do
    # Extract name, tags, and metadata
    [name_and_tags | metadata_part] = String.split(header, "{", parts: 2)
    [name | tags_part] = String.split(name_and_tags, " [", parts: 2)
    name = String.trim_leading(name, ":: ") |> String.trim()

    # Process tags
    tags =
      case tags_part do
        [tags_string] ->
          tags_string
          |> String.trim()
          |> String.trim_trailing("]")
          |> String.split(" ", trim: true)

        [] ->
          []
      end

    # Process metadata
    metadata =
      case metadata_part do
        [metadata_string] ->
          ("{" <> metadata_string)
          |> Jason.decode!()

        [] ->
          %{}
      end

    # Update and return the passage map
    %{
      name: name,
      tags: tags,
      metadata: metadata
    }
  end

  # within the text content of `raw_content`, separate out any text surrounded by double brackets ([[ ]])
  def parse_passage_content(raw_content) do
    raw_content = List.to_string(raw_content)

    links =
      Regex.scan(~r/\[\[(.*?)\]\]/, raw_content)
      |> Enum.map(fn [_pattern, link] -> link end)

    content = Regex.replace(~r/\[\[(.*?)\]\]/, raw_content, "") |> String.trim()

    %{
      content: content,
      links: links
    }
  end
end
