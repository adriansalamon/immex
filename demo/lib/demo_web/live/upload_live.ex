defmodule DemoWeb.UploadLive do
  require Immex.UploadWriter
  use DemoWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     allow_upload(socket, :avatar,
       accept: ~w(.jpg .jpeg),
       writer: Immex.UploadWriter.writer(Demo.Immex)
     )}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("save", _params, socket) do
    attrs = %{
      name: "avatar",
      content_type: "image/jpeg"
    }
    {[entry], _} = uploaded_entries(socket, :avatar)

    case Demo.Immex.put(attrs, &consume_uploaded_entry(socket, entry, &1)) do
      {:ok, media} -> IO.inspect(media)
      {:error, changeset} -> IO.inspect(changeset)
    end

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div>
      <form id="upload-form" phx-submit="save" phx-change="validate">
        <.live_file_input upload={@uploads.avatar} />
        <button type="submit">Upload</button>
      </form>
    </div>
    """
  end
end
