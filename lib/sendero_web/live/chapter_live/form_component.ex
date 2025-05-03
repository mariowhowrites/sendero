defmodule SenderoWeb.PassageLive.FormComponent do
  use SenderoWeb, :live_component

  alias Sendero.Fiction

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @passage.title %>
        <:subtitle>Use this form to manage passage records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="passage-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:content]} type="textarea" label="Content" />
        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          options={["draft", "active", "inactive"]}
        />
        <.input field={@form[:root]} type="checkbox" label="Root" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Passage</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{passage: passage} = assigns, socket) do
    changeset = Fiction.Passage.changeset(passage)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"passage" => passage_params}, socket) do
    changeset =
      socket.assigns.passage
      |> Fiction.Passage.changeset(passage_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"passage" => passage_params}, socket) do
    save_passage(socket, socket.assigns.action, passage_params)
  end

  defp save_passage(socket, :edit, passage_params) do
    case Fiction.Passage.update(socket.assigns.passage, passage_params) do
      {:ok, _passage} ->
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_passage(socket, :new, passage_params) do
    result = passage_params
    |> Map.put(:story_id, socket.assigns.story.id)
    |> Fiction.create_passage()

    case result do
      {:ok, passage} ->
        notify_parent({:created, passage})
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
