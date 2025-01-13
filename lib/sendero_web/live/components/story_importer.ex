defmodule SenderoWeb.Components.StoryImporter do
  use SenderoWeb, :live_component
  alias Sendero.Fiction.Importer.Wintermute

  @impl true
  def mount(socket) do
    {
      :ok,
      socket
      |> allow_upload(:story_upload, accept: ~w(.html))
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1>Story Importer</h1>

      <form id="story-upload-form" phx-change="validate" phx-submit="import" phx-target={@myself}>
        <.live_file_input upload={@uploads.story_upload} />
        <.button type="submit">Import</.button>
      </form>
    </div>
    """
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("import", _params, socket) do
    [story_id] =
      consume_uploaded_entries(socket, :story_upload, fn %{path: path}, _entry ->
        %{story: story} = Wintermute.import_from_path(path, socket.assigns.current_user.id)

        {:ok, story.id}
      end)

    {:noreply, socket|> push_navigate(to: ~p"/stories/#{story_id}")}
  end
end
