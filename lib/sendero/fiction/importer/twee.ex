defmodule Sendero.Fiction.Importer.Twee do
  defmodule Story do
    @type t :: %__MODULE__{
      title: String.t(),
      metadata: map(),
      chapters: [map()]
    }

    defstruct title: "", metadata: %{}, chapters: []
  end

  defmodule Chapter do
    @type t :: %__MODULE__{
      title: String.t(),
      tags: [String.t()],
      metadata: map(),
      content: String.t(),
      links: [String.t()]
    }

    defstruct title: "", tags: [], metadata: %{}, content: "", links: []
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

  def parse(":: StoryTitle" <> text, article) do
    Map.put(article, :title, text |> String.trim())
  end

  def parse(":: StoryData" <> text, article) do
    Map.put(article, :metadata, text |> String.trim() |> Jason.decode!())
  end

  def parse(text, article) do
    [header | content] = String.split(text, "\n", parts: 2)

    chapter =
      %Chapter{}
      |> parse_chapter_header(header)
      |> parse_chapter_content(content)

    Map.put(article, :chapters, [chapter | article.chapters])
  end

  # format of chapter headers is :: title [tags] {metadata}
  def parse_chapter_header(chapter, header) do
    # Extract title, tags, and metadata
    [title_and_tags | metadata_part] = String.split(header, "{", parts: 2)
    [title | tags_part] = String.split(title_and_tags, " [", parts: 2)
    title = String.trim_leading(title, ":: ") |> String.trim()

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

    # Update and return the chapter map
    Map.merge(chapter, %{
      title: title,
      tags: tags,
      metadata: metadata
    })
  end

  # within the text content of `raw_content`, separate out any text surrounded by double brackets ([[ ]])
  def parse_chapter_content(chapter, raw_content) do
    raw_content = List.to_string(raw_content)

    links =
      Regex.scan(~r/\[\[(.*?)\]\]/, raw_content)
      |> Enum.map(fn [_pattern, link] -> link end)

    content = Regex.replace(~r/\[\[(.*?)\]\]/, raw_content, "") |> String.trim()

    Map.merge(chapter, %{
      content: content,
      links: links
    })
  end
end
