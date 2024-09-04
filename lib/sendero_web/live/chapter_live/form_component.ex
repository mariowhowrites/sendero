defmodule SenderoWeb.ChapterLive.FormComponent do
  use SenderoWeb, :live_component

  alias Sendero.Fiction

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @chapter.title %>
        <:subtitle>Use this form to manage chapter records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="chapter-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:content]} type="textarea" label="Content" />
        <.input field={@form[:status]} type="select" label="Status" options={["draft", "active", "inactive"]} />
        <.input field={@form[:root]} type="checkbox" label="Root" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Chapter</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{chapter: chapter} = assigns, socket) do
    changeset = Fiction.change_chapter(chapter)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"chapter" => chapter_params}, socket) do
    changeset =
      socket.assigns.chapter
      |> Fiction.change_chapter(chapter_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"chapter" => chapter_params}, socket) do
    save_chapter(socket, socket.assigns.action, chapter_params)
  end

  defp save_chapter(socket, :edit, chapter_params) do
    case Fiction.update_chapter(socket.assigns.chapter, chapter_params) do
      {:ok, _chapter} ->
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_chapter(socket, :new, chapter_params) do
    case Fiction.create_chapter(socket.assigns.story, chapter_params) do
      {:ok, chapter} ->
        notify_parent({:created, chapter})
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
