defmodule SenderoWeb.StoryLive.Show do
  use SenderoWeb, :live_view

  alias Sendero.Fiction

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    starting_passage = Fiction.get_root_passage(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:story, Fiction.get_story!(id))
     |> assign(:current_passage, parse_passage(starting_passage))
     |> assign(:history, [])}
  end

  defp parse_passage(passage) do
    %{passage | content: parse_links(passage.content)}
  end

  defp parse_links(content) do
    content
    |> String.replace(~r/\[\[(.*?)\]\]/, fn full_match ->
      # Extract just the text between the [[ and ]]
      link_text =
        full_match
        |> String.replace(~r/[\[\]]/, "")
        |> String.trim()

      {display, target} =
        case String.split(link_text, "->", parts: 2) do
          [display, target] -> {String.trim(display), String.trim(target)}
          [text] -> {String.trim(text), String.trim(text)}
        end

      # Create a regular HTML link
      ~s(<a class="text-blue-500 underline" href="#" phx-click="choose-passage" phx-value-text="#{target}">#{display}</a>)
    end)
  end

  defp page_title(:show), do: "Show Story"

  @impl true
  def handle_event("choose-passage", %{"text" => link_text}, socket) do
    new_passage = Fiction.get_passage_by_link_text(socket.assigns.story.id, link_text)

    {:noreply,
     socket
     |> assign(:history, [socket.assigns.current_passage | socket.assigns.history])
     |> assign(:current_passage, parse_passage(new_passage))}
  end

  def handle_event("back", _, socket) do
    [new_current | new_history] = socket.assigns.history

    {:noreply,
     socket
     |> assign(:current_passage, parse_passage(new_current))
     |> assign(:history, new_history)}
  end
end
