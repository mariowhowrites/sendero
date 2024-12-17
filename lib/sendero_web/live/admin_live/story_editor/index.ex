defmodule SenderoWeb.AdminLive.StoryEditor.Index do
  use SenderoWeb, :live_component

  def render(assigns) do
    ~H"""
    <.live_component
      id={@current_chapter.id || "new_chapter"}
      module={SenderoWeb.ChapterLive.FormComponent}
      action={@live_action}
      story={@story}
      chapter={@current_chapter}
    />

    <.live_component
      id="link-editor"
      module={SenderoWeb.AdminLive.LinkEditor}
      story={@story}
      chapter={@current_chapter}
    />
    <.secondary_sidebar>
      <h2 class="text-xl font-semibold mb-8"><%= @story.title %></h2>

      <%!-- <div class="flex flex-col gap-4" phx-update="stream" id="passages-index">
    <p class="text-gray-500 only:block hidden">No passages yet</p>
    <%= for {dom_id, passage} <- @streams.passages do %>
      <.link id={dom_id} patch={~p"/stories/#{@story.id}/edit/#{passage.id}"}>
        <%= passage.title %>
      </.link>
    <% end %>
    </div> --%>
      <div class="text-xs font-semibold leading-6 text-gray-400">Passages</div>
      <ul role="list" class="-mx-2 my-2 space-y-1">
        <li class="only:flex hidden group gap-x-3 rounded-md p-2 text-sm font-semibold leading-6 text-gray-700 hover:bg-gray-50 hover:text-indigo-600">
          No passages yet
        </li>
        <%= for {dom_id, passage} <- @streams.passages do %>
          <li id={dom_id}>
            <!-- Current: "bg-gray-50 text-indigo-600", Default: "text-gray-700 hover:text-indigo-600 hover:bg-gray-50" -->
            <.link
              patch={~p"/admin/stories/#{@story.id}/edit/#{passage.id}"}
              class={"group flex gap-x-3 rounded-md p-2 text-sm font-semibold leading-6 #{if @current_passage.id == passage.id, do: "bg-gray-50 text-indigo-600", else: "text-gray-700 hover:text-indigo-600 hover:bg-gray-50"}"}
            >
              <span class="truncate"><%= passage.title %></span>
            </.link>
          </li>
        <% end %>
      </ul>

      <.link
        patch={~p"/adminstories/#{@story.id}/edit"}
        class="bg-blue-500 text-white px-4 py-2 rounded-md"
      >
        New Passage
      </.link>
    </.secondary_sidebar>
    """
  end
end
