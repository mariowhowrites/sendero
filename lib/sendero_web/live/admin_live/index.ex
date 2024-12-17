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
    passages = Fiction.get_passages_by_story(story)
    stories = Fiction.stories_by_author(socket.assigns.current_user.id)

    current_passage =
      case socket.assigns.live_action do
        :new ->
          %Fiction.Passage{
            title: "New Passage",
            content: "",
            status: :draft,
            root: false,
            story: story
          }

        :edit ->
          Fiction.get_passage!(params["passage_id"])
      end

    {:noreply,
     socket
     |> assign(:story, story)
     |> assign(:stories, stories)
     |> stream(:passages, passages)
     |> assign(:current_passage, current_passage)
     |> assign(:passage, current_passage)}
  end

  def handle_params(_params, _, socket) do
    stories = Fiction.stories_by_author(socket.assigns.current_user.id)
    story = stories |> List.first()

    {:noreply, socket |> assign(:stories, stories) |> assign(:story, story)}
  end

  @impl true
  def handle_event("add_passage", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({SenderoWeb.PassageLive.FormComponent, {:created, passage}}, socket) do
    {:noreply, socket |> stream_insert(:passages, passage)}
  end
end
