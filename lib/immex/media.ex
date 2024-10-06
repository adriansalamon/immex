defmodule Immex.DummyUser do
  @moduledoc """
  A dummy user schema for use in the media schema. In a real
  application, this would be replaced with the actual user schema that
  defines ownership of media files.

  To use a different schema, set the `:owner_schema` configuration option
  in your application configuration:

  ```elixir
  config :my_app, Immex,
    owner_schema: MyApp.Accounts.User,
    ...
  ```
  """
  use Ecto.Schema

  @type t :: %__MODULE__{}

  schema "users" do
  end
end

defmodule Immex.Media do
  @moduledoc """
  An Ecto schema for media files.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @owner_schema Application.compile_env(:immex, :owner_schema) ||
                  Immex.DummyUser

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          size: integer(),
          content_type: String.t(),
          url: String.t(),
          owner: @owner_schema.t(),
          metadata: [Immex.Metadata.t()],
          tags: [Immex.Tag.t()],
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "media" do
    field :name, :string
    field :size, :integer
    field :content_type, :string
    field :url, :string

    belongs_to :owner, @owner_schema

    has_many :metadata, Immex.Metadata
    many_to_many :tags, Immex.Tag, join_through: "media_tags"

    timestamps()
  end

  @doc false
  def changeset(media, attrs) do
    media
    |> cast(attrs, [:name, :size, :content_type, :url])
    |> validate_required([:name, :size, :content_type, :url])
  end
end
