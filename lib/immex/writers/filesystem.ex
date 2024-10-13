defmodule Immex.Writers.Filesystem do
  @moduledoc false
  require Logger

  @behaviour Phoenix.LiveView.UploadWriter

  @impl Phoenix.LiveView.UploadWriter
  def init(_opts) do
    with {:ok, path} <- Plug.Upload.random_file("immex_upload"),
         {:ok, file} <- File.open(path, [:binary, :write]) do
      {:ok, %{file: file, path: path}}
    end
  end

  @impl Phoenix.LiveView.UploadWriter
  def meta(state), do: %{url: state.path}

  @impl Phoenix.LiveView.UploadWriter
  def write_chunk(data, state) do
    case IO.binwrite(state.file, data) do
      :ok -> {:ok, state}
      {:error, reason} -> {:error, reason, state}
    end
  end

  @impl Phoenix.LiveView.UploadWriter
  def close(state, _reason) do
    case File.close(state.file) do
      :ok -> {:ok, state}
      {:error, reason} -> {:error, reason}
    end
  end

  def finalize(path, dst_path) do
    File.mkdir_p!(Path.dirname(dst_path))
    File.copy!(path, dst_path)
    {:ok, dst_path}
  end
end
