defmodule SenderoWeb.AdminLive.Index do
  use SenderoWeb, :live_view

  alias Sendero.Fiction

  @impl true
  def mount(params, session, socket) do
    {:ok, socket, layout: {SenderoWeb.Layouts, :app}}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    story = Fiction.get_story!(id)
    chapters = Fiction.get_chapters_by_story(story)
    stories = Fiction.list_stories()

    current_chapter = case socket.assigns.live_action do
      :new -> %Fiction.Chapter{title: "New Chapter", content: "", status: :draft, root: false, story: story}
      :edit -> Fiction.get_chapter!(params["chapter_id"])
    end

    {:noreply,
     socket
     |> assign(:story, story)
     |> assign(:stories, stories)
     |> stream(:chapters, chapters)
     |> assign(:current_chapter, current_chapter)}
  end

  @impl true
  def handle_event("add_chapter", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({SenderoWeb.ChapterLive.FormComponent, {:created, chapter}}, socket) do
    {:noreply, socket |> stream_insert(:chapters, chapter)}
  end
end
