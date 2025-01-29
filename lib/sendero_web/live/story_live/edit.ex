defmodule SenderoWeb.StoryLive.Edit do
  use SenderoWeb, :live_view

  alias Sendero.Fiction

  @impl true
  def mount(params, _session, socket) do
    story = Fiction.get_story!(params["story_id"])
    passages = Fiction.get_passages_by_story(story)

    {:ok,
     socket
     |> assign(:story, story)
     |> stream(:passages, passages, reset: true)
     |> assign(:current_passage, Fiction.get_root_passage(story.id))}
  end

  def handle_params(%{"story_id" => story_id, "passage_id" => passage_id}, _, socket) do
    passages = Fiction.get_passages_by_story_id(story_id)
    current_passage = passages |> Enum.find(&(&1.id == String.to_integer(passage_id)))

    {:noreply,
     socket
     |> assign(:current_passage, current_passage)
     |> stream(:passages, passages, reset: true)}
  end

  def handle_params(%{"story_id" => story_id}, _, socket)
      when socket.assigns.live_action == :new_passage do
    current_passage = %Fiction.Passage{}
    passages = Fiction.get_passages_by_story_id(story_id)

    {:noreply,
     socket
     |> assign(:current_passage, current_passage)
     |> stream(:passages, passages, reset: true)}
  end

  @impl true
  def handle_params(params, _, socket) do
    IO.inspect(params)

    {:noreply, socket}
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
