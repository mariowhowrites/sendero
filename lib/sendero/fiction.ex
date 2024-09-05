defmodule Sendero.Fiction do
  @moduledoc """
  The Fiction context.
  """

  import Ecto.Query, warn: false
  alias Sendero.Repo

  alias Sendero.Fiction.{Chapter, Link, Story}

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
  Gets a single chapter.

  Raises `Ecto.NoResultsError` if the Chapter does not exist.

  ## Examples

      iex> get_chapter!(123)
      %Chapter{}

      iex> get_chapter!(456)
      ** (Ecto.NoResultsError)
  """
  def get_chapter!(id), do: Repo.get!(Chapter, id)

  def get_chapters_by_story(%Story{} = story) do
    Repo.all(from c in Chapter, where: c.story_id == ^story.id)
  end

  def create_chapter(%Story{} = story, attrs) do
    %Chapter{}
    |> Chapter.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:story, story)
    |> Repo.insert()
  end

  def update_chapter(%Chapter{} = chapter, attrs) do
    chapter
    |> Chapter.changeset(attrs)
    |> Repo.update()
  end

  def change_chapter(%Chapter{} = chapter, attrs \\ %{}) do
    Chapter.changeset(chapter, attrs)
  end

  def create_root_chapter(%Story{} = story, attrs) do
    create_chapter(story, Map.merge(attrs, %{root: true}))
  end

  def create_link(attrs) do
    %Link{}
    |> Link.changeset(attrs)
    |> Repo.insert()
  end

  # let's consider what needs to be done here:
  # we are receiving a Story struct from our Importer
  # first, we can write a Story into our DB.
  # next, we can write each individual Chapter into our DB, without creating any links
  # then, we can write each Link into our DB by looping over the importer structs and using the `links` property to create links between chapters
  def import_story_from_twee(path) do
    twee_story = Sendero.Fiction.Importer.Twee.from_path(path)

    with {:ok, story} <- create_story_from_twee(twee_story),
         :ok <- create_chapters_and_links(story, twee_story.chapters) do
      {:ok, story}
    end
  end

  defp create_story_from_twee(twee_story) do
    create_story(%{
      title: twee_story.title,
      metadata: twee_story.metadata
    })
  end

  defp create_chapters_and_links(story, chapters) do
    chapters
    |> Enum.map(&create_chapter_from_twee(story, &1))
    |> Enum.each(&create_links_for_chapter/1)

    :ok
  end

  defp create_chapter_from_twee(story, raw_chapter) do
    {:ok, chapter} =
      create_chapter(story, %{
        title: raw_chapter.title,
        content: raw_chapter.content,
        root: raw_chapter.title == story.metadata["start"],
        status: :draft,
        story_id: story.id
      })

    {chapter, raw_chapter}
  end

  defp create_links_for_chapter({chapter, raw_chapter}) do
    Enum.each(raw_chapter.links, fn link ->
      destination_chapter = find_destination_chapter(link)
      create_link_between_chapters(chapter, destination_chapter, link)
    end)
  end

  defp find_destination_chapter(link) do
    Repo.one(from c in Chapter, where: c.title == ^link)
  end

  defp create_link_between_chapters(origin, destination, link) do
    create_link(%{
      title: link,
      content: link,
      origin_chapter_id: origin.id,
      destination_chapter_id: destination.id
    })
  end
end
