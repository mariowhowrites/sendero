defmodule SenderoWeb.AdminLive.Index do
  use SenderoWeb, :live_view
  alias Sendero.Fiction.Importer.Wintermute
  on_mount SenderoWeb.UserLiveAuth

  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(:uploaded_stories, [])
      |> allow_upload(:story_upload, accept: ~w(.html))
    }
  end
  def render(assigns) do
    ~H"""
    <div>
      <h1>Story Importer</h1>

      <form id="story-upload-form" phx-change="validate" phx-submit="import">
        <.live_file_input upload={@uploads.story_upload} />
        <.button type="submit">Import</.button>
      </form>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("import", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :story_upload, fn %{path: path}, entry ->
        # IO.inspect(entry)
        # IO.inspect(path)
        # dest = Path.join([:code.priv_dir(:sendero), "static", "uploads", Path.basename(path) <> entry.client_name])
        # File.cp!(path, dest)
        # {:ok, ~p"/uploads/#{Path.basename(dest)}"}
        story = Wintermute.import_from_path(path, socket.assigns.current_user.id)

        # IO.inspect(story)

        {:ok, story}
      end)

    {:noreply, update(socket, :uploaded_stories, &(&1 ++ uploaded_files))}
  end
end
