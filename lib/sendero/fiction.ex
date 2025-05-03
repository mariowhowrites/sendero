defmodule Sendero.Fiction do
  @moduledoc """
  The Fiction context.
  """

  import Ecto.Query, warn: false
  alias Sendero.Repo
  alias Ecto.Multi

  alias Sendero.Fiction.{Passage, Link, Story}

  def delete_story(story_id) do
    story = Story.get!(story_id)

    story_id
    |> Passage.all_by_story_id()
    |> Enum.each(&delete_passage/1)

    Story.delete(story)
  end

  def delete_passage(passage) do
    passage
    |> get_passage_links()
    |> Enum.each(&Link.delete/1)

    Passage.delete(passage)
  end

  def get_root_passage(story_id) do
    Repo.one(from p in Passage, where: p.story_id == ^story_id and p.root == true)
  end

  def get_passage_by_link_text(story_id, link_text) do
    Repo.one(from p in Passage, where: p.story_id == ^story_id and p.name == ^link_text)
  end

  def get_passage_links(%Passage{} = passage) do
    Repo.all(from l in Link, where: l.origin_passage_id == ^passage.id)
  end

  def import_story_from_twee(path) do
    twee_story = Sendero.Fiction.Importer.Twee.from_path(path)

    with {:ok, story} <- create_story_from_twee(twee_story),
         :ok <- create_passages_and_links(story, twee_story.passages) do
      {:ok, story}
    end
  end

  defp create_story_from_twee(twee_story) do
    Story.create(%{
      title: twee_story.title,
      metadata: twee_story.metadata
    })
  end

  def create_passages_and_links(story, passages) do
    passages
    |> Enum.map(&create_passage_from_twee(story, &1))
    |> Enum.each(&create_links_for_passage/1)

    :ok
  end

  defp create_passage_from_twee(story, raw_passage) do
    {:ok, passage} =
      Passage.create(%{
        name: raw_passage.name,
        content: raw_passage.content,
        root: raw_passage.pid == story.start_node,
        status: :draft,
        story_id: story.id
      })

    {passage, raw_passage}
  end

  defp create_links_for_passage({passage, raw_passage}) do
    Enum.each(raw_passage.links, fn {display, target} ->
      destination_passage = find_destination_passage(target)
      create_link_between_passages(passage, destination_passage, {display, target})
    end)
  end

  defp find_destination_passage(link) do
    Repo.one(from p in Passage, where: p.name == ^link)
  end

  defp create_link_between_passages(origin, destination, {display, target}) do
    Link.create(%{
      title: display,
      content: target,
      origin_passage_id: origin.id,
      destination_passage_id: destination.id
    })
  end

  @doc """
  Prepares story and passage data for database insertion by interpreting and validating the input.

  ## Examples

      iex> prepare_story_data(%{title: "My Story"}, [%{name: "Start", content: "Beginning...", pid: "start", links: []}])
      {:ok, %{
        story_attrs: %{title: "My Story"},
        passages: [%{name: "Start", content: "Beginning...", root: true, status: :draft}],
        links: [%{title: "Next", content: "Next", origin_passage_name: "Start", destination_passage_name: "Next"}]
      }}
  """
  def prepare_story_data(story_attrs, raw_passages) do
    # Prepare passage data
    passages =
      Enum.map(raw_passages, fn raw_passage ->
        %{
          name: raw_passage.name,
          content: raw_passage.content,
          root: raw_passage.pid == story_attrs.start_node,
          status: :draft
        }
      end)

    # Create a map of passage names to their indices for link resolution
    passage_index_map =
      Map.new(Enum.with_index(passages), fn {passage, idx} -> {passage.name, idx} end)

    # Prepare link data with passage indices
    links =
      Enum.flat_map(raw_passages, fn raw_passage ->
        Enum.map(raw_passage.links || [], fn {display, target} ->
          %{
            title: display,
            content: target,
            origin_passage_index: passage_index_map[raw_passage.name],
            destination_passage_index: passage_index_map[target]
          }
        end)
      end)

    {:ok,
     %{
       story_attrs: story_attrs,
       passages: passages,
       links: links
     }}
  end

  @doc """
  Creates a story with its passages and links in a single transaction.

  ## Examples

      iex> create_story_with_passages(%{title: "My Story"}, [%{name: "Start", content: "Beginning..."}])
      {:ok, %{story: %Story{}, passages: [%Passage{}], links: [%Link{}]}}

      iex> create_story_with_passages(%{}, [])
      {:error, :story, %Ecto.Changeset{}, %{}}
  """
  def create_story_with_passages(%{story: story_attrs, passages: passages, links: links}) do
    Multi.new()
    |> Multi.insert(:story, Story.changeset(%Story{}, story_attrs))
    |> Multi.run(:passages, fn repo, %{story: story} ->
      results =
        Enum.map(passages, fn passage_attrs ->
          Passage.create(Map.put(passage_attrs, :story_id, story.id), repo)
        end)

      case Enum.split_with(results, fn
             {:ok, _} -> true
             {:error, _} -> false
           end) do
        {passages, []} -> {:ok, Enum.map(passages, fn {:ok, p} -> p end)}
        {_, errors} -> {:error, errors}
      end
    end)
    |> Multi.run(:links, fn repo, %{passages: passages} ->
      results =
        links
        |> Enum.map(fn link_attrs ->
          Link.create(
            %{
              title: link_attrs.title,
              content: link_attrs.content,
              origin_passage_id: Enum.at(passages, link_attrs.origin_passage_index).id,
              destination_passage_id: Enum.at(passages, link_attrs.destination_passage_index).id
            },
            repo
          )
        end)

      case Enum.split_with(results, fn
             {:ok, _} -> true
             {:error, _} -> false
           end) do
        {links, []} -> {:ok, Enum.map(links, fn {:ok, l} -> l end)}
        {_, errors} -> {:error, errors}
      end
    end)
    |> Repo.transaction()
  end
end
