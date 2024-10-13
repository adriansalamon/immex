defmodule Immex.Test.DummyWriter do
  def finalize(orig_path, path) do
    case orig_path do
      "error" -> {:postpone, "error"}
      _ -> {:ok, path}
    end
  end
end
