defmodule Immex.UploadWriter do
  @moduledoc """
  The upload writer behaviour for Immex. Implements the `Phoenix.LiveView.UploadWriter`
  behaviour to write the uploaded file to the backend.
  """

  @behaviour Phoenix.LiveView.UploadWriter

  @impl true
  def init(opts) do
    module = Keyword.get(opts, :module, Immex)
    conf = Immex.config(module)

    case conf.writer.init(conf) do
      {:ok, state} -> {:ok, Map.put(state, :writer, conf.writer)}
      error -> error
    end
  end

  @impl true
  def meta(state), do: state.writer.meta(state)

  @impl true
  def write_chunk(data, state) do
    state.writer.write_chunk(data, state)
  end

  @impl true
  def close(state, reason) do
    state.writer.close(state, reason)
  end

  def writer(module) when is_atom(module) do
    fn _, _, _ -> {Immex.UploadWriter, module: module} end
  end
end
