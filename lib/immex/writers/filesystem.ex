defmodule Immex.Writers.Filesystem do
  @moduledoc false
  require Logger

  def init(_opts) do
    with {:ok, path} <- Plug.Upload.random_file("immex_upload"),
         {:ok, file} <- File.open(path, [:binary, :write]) do
      {:ok, %{file: file, path: path}}
    end
  end

  def meta(state), do: %{url: state.path}

  def write_chunk(data, state) do
    case IO.binwrite(state.file, data) do
      :ok -> {:ok, state}
      {:error, reason} -> {:error, reason, state}
    end
  end

  def close(state, _reason) do
    case File.close(state.file) do
      :ok -> {:ok, state}
      {:error, reason} -> {:error, reason}
    end
  end
end
