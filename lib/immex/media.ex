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

  alias Immex.{Config, Metadata, Tag, Media}

  @owner_schema Application.compile_env(:immex, :owner_schema) ||
                  Immex.DummyUser

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          size: integer(),
          content_type: String.t(),
          url: String.t(),
          owner: @owner_schema.t(),
          metadata: [Metadata.t()],
          tags: [Tag.t()],
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "media" do
    field :name, :string
    field :size, :integer
    field :content_type, :string
    field :url, :string

    field :frontend_url, :string, virtual: true

    belongs_to :owner, @owner_schema

    has_many :metadata, Metadata
    many_to_many :tags, Tag, join_through: "media_tags"

    timestamps()
  end

  @doc false
  def changeset(media, attrs) do
    media
    |> cast(attrs, [:name, :size, :content_type, :owner_id])
    |> validate_required([:name, :content_type])
    |> validate_content_type()
    |> put_url()
  end

  @doc false
  def preload_frontend_url(%Media{} = media, config) do
    base_path = Config.frontend_path(config)
    Map.put(media, :frontend_url, "#{base_path}/#{media.url}")
  end

  def preload_frontend_url(media, config) when is_list(media) do
    media
    |> Enum.map(&preload_frontend_url(&1, config))
  end

  defp validate_content_type(changeset) do
    content_type = get_field(changeset, :content_type)

    case file_extension(content_type) do
      :not_supported ->
        add_error(changeset, :content_type, "unsupported content type")

      _ ->
        changeset
    end
  end

  defp put_url(changeset) do
    case get_field(changeset, :content_type) do
      type when is_binary(type) ->
        put_change(changeset, :url, Ecto.UUID.generate() <> file_extension(type))

      nil ->
        changeset
    end
  end

  defp file_extension(content_type) do
    case content_type do
      "image/jpeg" -> ".jpg"
      "image/png" -> ".png"
      "image/gif" -> ".gif"
      _ -> :not_supported
    end
  end
end
