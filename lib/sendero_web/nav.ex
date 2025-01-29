defmodule SenderoWeb.Nav do
  import Phoenix.LiveView
  use Phoenix.Component

  alias SenderoWeb.{AdminLive, StoryLive}

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     socket
     |> attach_hook(:active_tab, :handle_params, &handle_params/3)
     |> assign(:active_tab, :dashboard)
     |> assign(:story_sidebar_info, Sendero.Fiction.get_story_sidebar_info(socket.assigns.current_user.id))}
  end

  defp handle_params(params, _url, socket) do
    IO.inspect(socket.view)
    IO.inspect(socket.assigns.live_action)

    active_tab =
      case {socket.view, socket.assigns.live_action} do
        {AdminLive.Index, :dashboard} -> :dashboard
        {StoryLive.Edit, :edit} -> {:edit, params["story_id"]}
        {StoryLive.Edit, :edit_passage} -> {:edit_passage, params["story_id"]}
        _ -> :dashboard
      end

    IO.inspect(active_tab)

    {:cont, socket |> assign(:active_tab, active_tab)}
  end
end
