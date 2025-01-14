defmodule Sendero.Fiction.Importer.Wintermute do
  @moduledoc """
  Imports Wintermute-formatted HTML files into Sendero's internal format.
  """
  alias Sendero.Fiction

  @doc """
  Imports a Wintermute HTML file from the given path.
  """
  def import_from_path(path, user_id) do
    with {:ok, html} <- File.read(path),
         {:ok, story} <- import_from_html(html, user_id) do
      story
    end
  end

  def import_from_html(html, user_id) do
    with {:ok, document} <- Floki.parse_document(html),
         {:ok, story_content} <- parse_story_from_document(document, user_id) do
      Fiction.create_story_with_passages(story_content.story, story_content.passages)
    end
  end

  def parse_story_from_document(document, user_id) do
    with {:ok, story_data} <- extract_story_data(document),
         {:ok, passages} <- extract_passages(document) do
      {:ok,
       %{
         story: Map.put(story_data, :author_id, user_id),
         passages: passages
       }}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp extract_story_data(document) do
    case Floki.find(document, "tw-storydata") do
      [story_element | _] ->
        {_tag, attributes, _children} = story_element

        story_data = %{
          title: find_attribute(attributes, "name"),
          start_node: find_attribute(attributes, "startnode"),
          creator: find_attribute(attributes, "creator"),
          creator_version: find_attribute(attributes, "creator-version"),
          ifid: find_attribute(attributes, "ifid")
        }

        {:ok, story_data}

      [] ->
        {:error, :no_story_data_found}
    end
  end

  defp extract_passages(document) do
    passages =
      document
      |> Floki.find("tw-passagedata")
      |> Enum.map(fn passage_element ->
        {_tag, attributes, children} = passage_element
        content = Floki.text(children)

        %{
          pid: find_attribute(attributes, "pid"),
          name: find_attribute(attributes, "name"),
          tags: extract_tags(attributes),
          position: extract_position(attributes),
          content: content,
          links: extract_links(content)
        }
      end)

    {:ok, passages}
  end

  defp find_attribute(attributes, name) do
    case List.keyfind(attributes, name, 0) do
      {^name, value} -> value
      nil -> nil
    end
  end

  defp extract_tags(attributes) do
    case find_attribute(attributes, "tags") do
      nil -> []
      tags -> String.split(tags, " ", trim: true)
    end
  end

  defp extract_position(attributes) do
    case find_attribute(attributes, "position") do
      nil ->
        %{x: 0, y: 0}

      position ->
        [x, y] =
          String.split(position, ",", trim: true)
          |> Enum.map(fn pos ->
            {int, _remainder} = Integer.parse(pos)
            int
          end)

        %{x: x, y: y}
    end
  end

  # returns a list of tuples of structure {link_display_text, target_passage_name}
  defp extract_links(content) do
    ~r/\[\[([^\]]+)\]\]/
    |> Regex.scan(content)
    |> Enum.map(fn [_full_match, link_text] ->
      # we need to handle both [[display->target]] and [[target]] links here, so split on "->" and see how many parts we have
      case String.split(link_text, "->", parts: 2) do
        [display, target] -> {String.trim(display), String.trim(target)}
        [text] -> {String.trim(text), String.trim(text)}
      end
    end)
  end
end
