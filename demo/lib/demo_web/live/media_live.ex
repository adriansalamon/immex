defmodule DemoWeb.MediaLive do
  use DemoWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:media, Demo.Immex.list_media())}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-3 gap-2">
      <div :for={media_item <- @media} >
        <img src={media_item.frontend_url} class="rounded-lg"/>
      </div>
    </div>
    """
  end
end
