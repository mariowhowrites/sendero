defmodule SenderoWeb.AdminLive.Index do
  use SenderoWeb, :live_view
  on_mount SenderoWeb.UserLiveAuth

  alias SenderoWeb.Components.StoryImporter
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
    }
  end

  def render(assigns) do
    ~H"""
    <.live_component module={StoryImporter} id="story-importer" current_user={@current_user} />
    """
  end
end
