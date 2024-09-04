defmodule SenderoWeb.StoryLive.Index do
  use SenderoWeb, :live_view

  alias Sendero.Fiction
  alias Sendero.Fiction.Story

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :stories, Fiction.list_stories())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Story")
    |> assign(:story, Fiction.get_story!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Story")
    |> assign(:story, %Story{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Stories")
    |> assign(:story, nil)
  end

  @impl true
  def handle_info({SenderoWeb.StoryLive.FormComponent, {:saved, story}}, socket) do
    {:noreply, stream_insert(socket, :stories, story)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    story = Fiction.get_story!(id)
    {:ok, _} = Fiction.delete_story(story)

    {:noreply, stream_delete(socket, :stories, story)}
  end
end
