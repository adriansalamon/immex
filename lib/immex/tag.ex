defmodule Immex.Tag do
  @moduledoc """
  Schema for tags. Tags are used to categorize media.
  A tag can have a parent tag, and thus used to create a tree structure.

  Tags can be associated with media, where a media can have multiple tags.
  """
  use Ecto.Schema

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          slug: String.t(),
          parent: Immex.Tag.t(),
          children: [Immex.Tag.t()],
          media: [Immex.Media.t()]
        }

  schema "tags" do
    field :name, :string
    field :slug, :string

    belongs_to :parent, Immex.Tag
    has_many :children, Immex.Tag, foreign_key: :parent_id

    many_to_many :media, Immex.Media, join_through: "media_tags"
  end
end
