defmodule Immex.Config do
  defstruct backend: nil, repo: nil, name: nil

  def new(opts) when is_list(opts) do
    struct!(__MODULE__, opts)
  end
end
