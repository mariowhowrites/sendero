defmodule SenderoWeb.DragAndDropEditorLive do
  use SenderoWeb, :live_component

  def mount(params, session, socket) do
    {:ok, socket |> assign(:value, "Hello World")}
  end

  def render(assigns) do
    ~H"""
    <section class="h-full relative">
      <input type="text" />

      <div class="absolute top-0 left-0 bg-gray-200">
        <%= if connected?(@socket) do %>
          Left: <%= @left %> Top: <%= @top %>
        <% else %>
          Disconnected
        <% end %>
      </div>
      <div class="absolute top-0 right-0 bg-gray-200">
        Top Right
      </div>
      <div class="absolute bottom-0 left-0 bg-gray-200">
        Bottom Left
      </div>
      <div class="absolute bottom-0 right-0 bg-gray-200">
        Bottom Right
      </div>

      <div
        phx-click="click_element"
        phx-target={@myself}
        id="draggable-element"
        phx-hook="StoryEditor"
        class="absolute bg-gray-200"
        style={"top: #{@top}px; left: #{@left}px;"}
      >
        Draggable Element
      </div>
    </section>
    """
  end

  def handle_event("click_element", params, socket) do
    {:noreply, socket}
  end

  def handle_event("drag_end", params, socket) do
    {:noreply, socket |> assign(:top, params["top"]) |> assign(:left, params["left"])}
  end
end
