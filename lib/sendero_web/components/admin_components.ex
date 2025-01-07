defmodule SenderoWeb.AdminComponents do
  use Phoenix.Component

  slot :inner_block, required: true

  def main_section(assigns) do
    ~H"""
    <section class="lg:pl-72 flex-grow flex flex-col">
      <div class="flex-grow">
        <%= render_slot(@inner_block) %>
      </div>
    </section>
    """
  end

  slot :inner_block, required: true

  def secondary_sidebar(assigns) do
    ~H"""
    <aside class="fixed inset-y-0 left-72 hidden w-96 overflow-y-auto border-r border-gray-200 px-4 py-6 sm:px-6 lg:px-8 xl:block">
      <%= render_slot(@inner_block) %>
    </aside>
    """
  end
end
