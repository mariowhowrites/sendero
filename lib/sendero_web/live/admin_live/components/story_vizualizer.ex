defmodule SenderoWeb.StoryLive.VisualizerComponent do
  use SenderoWeb, :live_component
  alias Sendero.Fiction

  def render(assigns) do
    ~H"""
    <div>
      <div
        id={"story-graph-#{@story.id}"}
        phx-hook="StoryVisualizer"
        class="w-full h-[600px]"
        phx-target={@myself}
        data-story-id={@story.id}
      >
      </div>
    </div>
    """
  end

  def format_graph_data(story, passages, links) do
    nodes =
      Enum.map(passages, fn passage ->
        %{
          data: %{
            id: "p#{passage.id}",
            label: passage.name,
            root: if(passage.root, do: "true", else: "false")
          }
        }
      end)

    edges =
      Enum.map(links, fn link ->
        %{
          data: %{
            id: "l#{link.id}",
            source: "p#{link.origin_passage_id}",
            target: "p#{link.destination_passage_id}",
            label: link.title
          }
        }
      end)

    %{
      nodes: nodes,
      edges: edges
    }
  end

  def handle_event("load_graph_data", %{"story_id" => story_id}, socket) do
    # Add validation to ensure story_id is a valid integer
    case Integer.parse(story_id) do
      {id, _} ->
        story = Fiction.get_story!(id)
        passages = Fiction.get_passages_by_story(story)
        links = Enum.flat_map(passages, &Fiction.get_passage_links/1)

        graph_data = format_graph_data(story, passages, links)
        {:reply, %{elements: graph_data}, socket}

      :error ->
        {:reply, %{error: "Invalid story ID"}, socket}
    end
  end
end
