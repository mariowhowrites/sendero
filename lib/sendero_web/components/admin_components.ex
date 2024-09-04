defmodule SenderoWeb.AdminComponents do
  use Phoenix.Component

  slot :inner_block, required: true
  def main_section(assigns) do
    ~H"""
    <main class="lg:pl-72">
      <div class="xl:pl-96">
        <div class="px-4 py-10 sm:px-6 lg:px-8 lg:py-6">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </main>
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
