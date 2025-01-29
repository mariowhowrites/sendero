defmodule SenderoWeb.AdminLive.Dashboard do
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
    <main class="lg:pl-72">
      <div class="xl:pr-96">
        <div class="px-4 py-10 sm:px-6 lg:px-8 lg:py-6">
          <!-- Main area -->
          <.live_component module={StoryImporter} id="story-importer" current_user={@current_user} />
        </div>
      </div>
    </main>

    <aside class="fixed inset-y-0 right-0 hidden w-96 overflow-y-auto border-l border-gray-200 px-4 py-6 sm:px-6 lg:px-8 xl:block">
      <!-- Secondary column (hidden on smaller screens) -->
    </aside>
    """
  end
end
