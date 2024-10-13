defmodule Immex.Tag do
  @moduledoc """
  Schema for tags. Tags are used to categorize media.
  A tag can have a parent tag, and thus used to create a tree structure.

  Tags can be associated with media, where a media can have multiple tags.
  """
  use Ecto.Schema
  import Ecto.Changeset

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

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :parent_id])
    |> validate_required([:name])
    |> put_slug()
  end

  defp put_slug(changeset) do
    case get_change(changeset, :name) do
      nil -> changeset
      name -> put_change(changeset, :slug, slugify(name))
    end
  end

  @split_re ~r/[\00-\57]/

  defp slugify(string) do
    string
    |> String.split(@split_re)
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("-")
    |> String.downcase()
    |> String.trim_leading("-")
    |> String.trim_trailing("-")
  end
end
