defmodule Immex.Config do
  @moduledoc """
  The config struct that configures Immex. Typically, this
  is created on initialization and passed around to various
  modules.
  """

  @type t :: %__MODULE__{
          repo: String.t(),
          name: String.t(),
          prefix: String.t(),
          writer: module(),
          base_path: String.t()
        }

  defstruct repo: nil,
            name: Immex,
            prefix: "public",
            writer: Immex.Writers.Filesystem,
            base_path: "priv/uploads"

  def new(opts) when is_list(opts) do
    struct!(__MODULE__, opts)
  end
end
