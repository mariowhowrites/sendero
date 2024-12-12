defmodule SenderoWeb.AdminLive.LinkEditor do
  use SenderoWeb, :live_component

  alias Sendero.Fiction

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    IO.inspect(assigns, label: "ASSIGNS")

    links = case !is_nil(assigns.chapter) and !is_nil(assigns.chapter.id) do
      false -> []
      true -> get_chapter_links(assigns.  chapter)
    end

    {:ok, socket |> assign(assigns) |> assign(:links, links)}
  end

  def render(assigns) do
    ~H"""
    <div class="px-4 sm:px-6 lg:px-8">
      <div class="sm:flex sm:items-center">
        <div class="sm:flex-auto">
          <h1 class="text-base font-semibold leading-6 text-gray-900">Chapter Links</h1>
          <p class="mt-2 text-sm text-gray-700">
            A list of all links associated with this chapter.
          </p>
        </div>
        <div class="mt-4 sm:ml-16 sm:mt-0 sm:flex-none">
          <button
            type="button"
            phx-click="add_link"
            phx-target={@myself}
            class="block rounded-md bg-indigo-600 px-3 py-2 text-center text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
          >
            Add a new link
          </button>
        </div>
      </div>
      <div class="mt-8 flow-root">
        <div class="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
          <div class="inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8">
            <table class="min-w-full divide-y divide-gray-300">
              <thead>
                <tr>
                  <th scope="col" class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-0">
                    Link Title
                  </th>
                  <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                    Status
                  </th>
                  <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                    Linked Chapter
                  </th>
                  <th scope="col" class="relative py-3.5 pl-3 pr-4 sm:pr-0">
                    <span class="sr-only">Edit</span>
                  </th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-200">
                <%= for link <- @links do %>
                  <tr>
                    <td class="whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium text-gray-900 sm:pl-0">
                      <%= link.title %>
                    </td>
                    <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                      <%= link_status(@chapter, link) %>
                    </td>
                    <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                      <%= linked_chapter_title(@chapter, link) %>
                    </td>
                    <td class="relative whitespace-nowrap py-4 pl-3 pr-4 text-right text-sm font-medium sm:pr-0">
                      <a href="#" class="text-indigo-600 hover:text-indigo-900">
                        Edit<span class="sr-only">, <%= link.title %></span>
                      </a>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp get_chapter_links(chapter) do
    Fiction.get_chapter_links(chapter)
  end

  defp link_status(chapter, link) do
    if link.origin_chapter_id == chapter.id, do: "Outgoing", else: "Incoming"
  end

  defp linked_chapter_title(chapter, link) do
    if link.origin_chapter_id == chapter.id do
      link.destination_chapter.title
    else
      link.origin_chapter.title
    end
  end

  def handle_event("add_link", _, socket) do
    # For now, this does nothing
    {:noreply, socket}
  end
end
