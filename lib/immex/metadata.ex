defmodule Immex.Metadata do
  @moduledoc """
  An Ecto schema for metadata. Metadata can be any key-value pair
  associated with a media file. Keys are unique per media file.
  """
  use Ecto.Schema

  @type t :: %__MODULE__{
          id: integer(),
          key: String.t(),
          value: String.t(),
          media: Immex.Media.t()
        }

  schema "metadata" do
    field :key, :string
    field :value, :string

    belongs_to :media, Immex.Media
  end
end
