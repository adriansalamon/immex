defmodule Immex.Config do
  @moduledoc """
  The config struct that configures Immex. Typically, this
  is created on initialization and passed around to various
  modules.
  """

  defstruct repo: nil, name: Immex, prefix: "public"

  def new(opts) when is_list(opts) do
    struct!(__MODULE__, opts)
  end
end
