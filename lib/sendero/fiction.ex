defmodule Sendero.Fiction do
  @moduledoc """
  The Fiction context.
  """

  import Ecto.Query, warn: false
  alias Sendero.Repo

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

  defp create_passages_and_links(story, passages) do
    passages
    |> Enum.map(&create_passage_from_twee(story, &1))
    |> Enum.each(&create_links_for_passage/1)

    :ok
  end

  defp create_passage_from_twee(story, raw_passage) do
    {:ok, passage} =
      create_passage(story, %{
        title: raw_passage.title,
        content: raw_passage.content,
        root: raw_passage.title == story.metadata["start"],
        status: :draft,
        story_id: story.id
      })

    {passage, raw_passage}
  end

  defp create_links_for_passage({passage, raw_passage}) do
    Enum.each(raw_passage.links, fn link ->
      destination_passage = find_destination_passage(link)
      create_link_between_passages(passage, destination_passage, link)
    end)
  end

  defp find_destination_passage(link) do
    Repo.one(from c in Passage, where: c.title == ^link)
  end

  defp create_link_between_passages(origin, destination, link) do
    create_link(%{
      title: link,
      content: link,
      origin_passage_id: origin.id,
      destination_passage_id: destination.id
    })
  end
end
