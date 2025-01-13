defmodule Sendero.Fiction do
  @moduledoc """
  The Fiction context.
  """

  import Ecto.Query, warn: false
  alias Sendero.Repo
  alias Ecto.Multi

  alias Sendero.Fiction.{Passage, Link, Story}

  @doc """
  Returns the list of stories.

  ## Examples

      iex> list_stories()
      [%Story{}, ...]

  """
  def list_stories do
    Repo.all(Story)
  end

  @doc """
  Gets a single story.

  Raises `Ecto.NoResultsError` if the Story does not exist.

  ## Examples

      iex> get_story!(123)
      %Story{}

      iex> get_story!(456)
      ** (Ecto.NoResultsError)

  """
  def get_story!(id), do: Repo.get!(Story, id)

  @doc """
  Returns the list of stories by author.

  ## Examples

      iex> stories_by_author(123)
      [%Story{}, ...]
  """
  def stories_by_author(author_id) do
    Repo.all(from s in Story, where: s.author_id == ^author_id)
  end

  @doc """
  Creates a story.

  ## Examples

      iex> create_story(%{field: value})
      {:ok, %Story{}}

      iex> create_story(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_story(attrs \\ %{}) do
    %Story{}
    |> Story.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a story.

  ## Examples

      iex> update_story(story, %{field: new_value})
      {:ok, %Story{}}

      iex> update_story(story, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_story(%Story{} = story, attrs) do
    story
    |> Story.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a story.

  ## Examples

      iex> delete_story(story)
      {:ok, %Story{}}

      iex> delete_story(story)
      {:error, %Ecto.Changeset{}}

  """
  def delete_story(%Story{} = story) do
    Repo.delete(story)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking story changes.

  ## Examples

      iex> change_story(story)
      %Ecto.Changeset{data: %Story{}}

  """
  def change_story(%Story{} = story, attrs \\ %{}) do
    Story.changeset(story, attrs)
  end

  @doc """
  Gets a single passage.

  Raises `Ecto.NoResultsError` if the Passage does not exist.

  ## Examples

      iex> get_passage!(123)
      %Passage{}

      iex> get_passage!(456)
      ** (Ecto.NoResultsError)
  """
  def get_passage!(id), do: Repo.get!(Passage, id)

  def get_passages_by_story(%Story{} = story) do
    Repo.all(from c in Passage, where: c.story_id == ^story.id)
  end

  def create_passage(%Story{} = story, attrs) do
    %Passage{}
    |> Passage.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:story, story)
    |> Repo.insert()
  end

  def update_passage(%Passage{} = passage, attrs) do
    passage
    |> Passage.changeset(attrs)
    |> Repo.update()
  end

  def change_passage(%Passage{} = passage, attrs \\ %{}) do
    Passage.changeset(passage, attrs)
  end

  def create_root_passage(%Story{} = story, attrs) do
    create_passage(story, Map.merge(attrs, %{root: true}))
  end

  def get_root_passage(story_id) do
    Repo.one(from p in Passage, where: p.story_id == ^story_id and p.root == true)
  end

  def get_passages_by_story_id(story_id) do
    Repo.all(from p in Passage, where: p.story_id == ^story_id)
  end

  def get_passage_by_link_text(story_id, link_text) do
    Repo.one(from p in Passage, where: p.story_id == ^story_id and p.name == ^link_text)
  end

  def create_link(attrs) do
    %Link{}
    |> Link.changeset(attrs)
    |> Repo.insert()
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
    create_story(%{
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
      create_passage(story, %{
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
    create_link(%{
      title: display,
      content: target,
      origin_passage_id: origin.id,
      destination_passage_id: destination.id
    })
  end

    @doc """
  Creates a story with its passages and links in a single transaction.

  ## Examples

      iex> create_story_with_passages(%{title: "My Story"}, [%{name: "Start", content: "Beginning..."}])
      {:ok, %{story: %Story{}, passages: [%Passage{}], links: [%Link{}]}}

      iex> create_story_with_passages(%{}, [])
      {:error, :story, %Ecto.Changeset{}, %{}}
  """
  def create_story_with_passages(story_attrs, raw_passages) do
    Multi.new()
    |> Multi.insert(:story, Story.changeset(%Story{}, story_attrs))
    |> Multi.run(:passages, fn repo, %{story: story} ->
      results = Enum.map(raw_passages, fn raw_passage ->
        passage_attrs = %{
          name: raw_passage.name,
          content: raw_passage.content,
          root: raw_passage.pid == story.start_node,
          status: :draft,
          story_id: story.id
        }

        %Passage{}
        |> Passage.changeset(passage_attrs)
        |> Ecto.Changeset.put_assoc(:story, story)
        |> repo.insert()
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
      passage_map = Map.new(passages, fn p -> {p.name, p} end)

      results = passages
      |> Enum.flat_map(fn passage ->
        raw_passage = Enum.find(raw_passages, &(&1.name == passage.name))
        Enum.map(raw_passage.links || [], fn {display, target} ->
          destination = passage_map[target]

          %Link{}
          |> Link.changeset(%{
            title: display,
            content: target,
            origin_passage_id: passage.id,
            destination_passage_id: destination && destination.id
          })
          |> repo.insert()
        end)
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
