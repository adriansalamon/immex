defmodule Immex do
  @moduledoc """
  Documentation for `Immex`, a media management library.
  """

  use Supervisor
  alias Immex.Media
  alias Immex.{Config, Registry, Repo}

  import Ecto.Query

  @doc """
  Creates a facade for `Immex` that can be included in an OTP application.

  Facade modules support configuration via the application environment under an OTP application
  key. For example, the facade:

      defmodule MyApp.Immex do
        use Immex, otp_app: MyApp
      end

  Could be configured with:

      config :my_app, Immex, repo: MyApp.Repo

  Then you can include `MyApp.Immex` in your application's supervision tree without passing extra
  options:

      defmodule MyApp.Application do
        use Application

        def start(_type, _args) do
          children = [
            MyApp.Repo,
            MyApp.Immex
          ]

          opts = [strategy: :one_for_one, name: MyApp.Supervisor]
          Supervisor.start_link(children, opts)
        end
      end
  """
  defmacro __using__(opts \\ []) do
    {otp_app, child_opts} = Keyword.pop!(opts, :otp_app)

    quote do
      def child_spec(opts) do
        unquote(child_opts)
        |> Keyword.merge(Application.get_env(unquote(otp_app), __MODULE__, []))
        |> Keyword.merge(opts)
        |> Keyword.put(:name, __MODULE__)
        |> Immex.child_spec()
      end

      def config do
        Immex.config(__MODULE__)
      end

      def put(attrs, consume_fn) do
        Immex.put(__MODULE__, attrs, consume_fn)
      end

      def list_media() do
        Immex.list_media(__MODULE__)
      end

      def get_media(id) do
        Immex.get_media(__MODULE__, id)
      end

      def update_media(id, attrs) do
        Immex.update_media(__MODULE__, id, attrs)
      end

      def delete_media(id) do
        Immex.delete_media(__MODULE__, id)
      end

      def get_metadata(media_id) do
        Immex.get_metadata(__MODULE__, media_id)
      end

      def put_metadata(media_id, metadata_attrs) do
        Immex.put_metadata(__MODULE__, media_id, metadata_attrs)
      end

      def create_tag(attrs) do
        Immex.create_tag(__MODULE__, attrs)
      end

      def list_tags() do
        Immex.list_tags(__MODULE__)
      end

      def delete_tag(id) do
        Immex.delete_tag(__MODULE__, id)
      end

      def add_tag_to_media(media_id, tag_id) do
        Immex.add_tag_to_media(__MODULE__, media_id, tag_id)
      end

      def get_media_by_tag(tag_id) do
        Immex.get_media_by_tag(__MODULE__, tag_id)
      end
    end
  end

  @doc """
  Starts an `Immex` supervision tree with the given options.

  ## Options

  These options are required:

  * `:repo` - The Ecto repo module to use for database operations.

  These options are optional:

  * `:name` - The name of the registry process. Defaults to `Immex`.
  * `:prefix` - The prefix or namespace to use for database tables.
    Defaults to `public`.
  * `:owner_schema` - The schema module that owns media files. Defaults to
    `Immex.DummyUser`.

  If you are using the local file system for storage, you will need to specify

  * `:base_path` - The base path where media files will be stored.
  """

  @spec start_link(Keyword.t()) :: Supervisor.on_start()
  def start_link(opts) do
    conf = Config.new(opts)

    Supervisor.start_link(__MODULE__, conf, name: Registry.via(conf.name, conf))
  end

  @doc false
  def child_spec(opts) do
    opts
    |> super()
    |> Supervisor.child_spec(id: Keyword.get(opts, :name, __MODULE__))
  end

  @impl Supervisor
  def init(%Config{} = _conf) do
    children = []

    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc """
  Returns the config for a given `Immex` process.

  ## Examples

  Get the default instance config:

      %Immex.Config{} = Immex.config()

  Get config for a named instance:

      %Immex.Config{} = Immex.config(MyApp.Immex)

  """
  def config(name \\ __MODULE__), do: Registry.config(name)

  ## PUBLIC API

  @doc """
  Puts a media file into the media store.

  ## Examples

  Put a media file into the default media store:

      attrs = %{
        name: "avatar",
        content_type: "image/jpeg"
      }

      Immex.put(attrs, &consume_uploaded_entry(socket, entry, &1))
  """
  def put(attrs, consume_fn) do
    put(__MODULE__, attrs, consume_fn)
  end

  def put(name, attrs, consume_fn) when is_function(consume_fn, 1) do
    conf = config(name)

    changeset =
      %Media{}
      |> Media.changeset(attrs)

    case Repo.insert(conf, changeset) do
      {:ok, media} ->
        result = consume_fn.(fn %{url: tmp_path} ->
          conf.writer.finalize(tmp_path, media_path(name, media))
        end)

        case result do
          {:postpone, _} ->
            Repo.delete!(conf, media)
            {:error, "failed to consume uploaded entry"}

          _ -> {:ok, media}
        end



      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Lists all media files in the media store.
  """
  def list_media() do
    list_media(__MODULE__)
  end

  def list_media(name) do
    conf = config(name)

    Repo.all(conf, Media)
    |> Media.preload_frontend_url(conf)
  end

  @doc """
  Get a media file from the media store by ID.
  """
  def get_media(id) do
    get_media(__MODULE__, id)
  end

  def get_media(name, id) do
    conf = config(name)

    Repo.get(conf, Media, id)
    |> Media.preload_frontend_url(conf)
  end

  @doc """
  Updates a media file in the media store.
  """
  def update_media(id, attrs) do
    update_media(__MODULE__, id, attrs)
  end

  def update_media(name, id, attrs) do
    conf = config(name)

    case Repo.get(conf, Media, id) do
      nil ->
        {:error, "media not found"}

      media ->
        changeset = Media.changeset(media, attrs)

        case Repo.update(conf, changeset) do
          {:ok, media} ->
            {:ok, media |> Media.preload_frontend_url(conf)}

          {:error, changeset} ->
            {:error, changeset}
        end
    end
  end

  @doc """
  Delete a media file from the media store.
  """
  def delete_media(id) do
    delete_media(__MODULE__, id)
  end

  def delete_media(name, id) do
    conf = config(name)

    case Repo.get(conf, Media, id) do
      nil ->
        {:error, "media not found"}

      media ->
        path = media_path(name, media)
        File.rm(path)

        Repo.delete(conf, media)
    end
  end

  alias Immex.Metadata

  @doc """
  Fetches all metadata for a media item.
  """
  def get_metadata(media_id) do
    get_metadata(__MODULE__, media_id)
  end

  def get_metadata(name, media_id) do
    conf = config(name)
    query = from m in Metadata, where: m.media_id == ^media_id

    Repo.all(conf, query)
  end

  @doc """
  Puts metadata to a media item.

  ## Examples

  Put metadata to a media item:

      metadata_attrs = %{
        "country" => "USA",
        "city" => "San Francisco"
      }

      Immex.put_metadata(media_id, metadata_attrs)
  """
  def put_metadata(media_id, metadata_attrs) do
    put_metadata(__MODULE__, media_id, metadata_attrs)
  end

  def put_metadata(_name, _media_id, metadata_attrs) when is_map(metadata_attrs) do
    ## Unimplemented
  end

  alias Immex.Tag

  @doc """
  Create a new tag.
  """
  def create_tag(attrs) do
    create_tag(__MODULE__, attrs)
  end

  def create_tag(name, attrs) do
    conf = config(name)
    changeset = Tag.changeset(%Tag{}, attrs)

    Repo.insert(conf, changeset)
  end

  @doc """
  Lists all tags.
  """
  def list_tags() do
    list_tags(__MODULE__)
  end

  def list_tags(name) do
    conf = config(name)

    query =
      from t in Tag,
        preload: [:parent, :children]

    Repo.all(conf, query)
  end

  @doc """
  Delete a tag.
  """
  def delete_tag(id) do
    delete_tag(__MODULE__, id)
  end

  def delete_tag(name, id) do
    conf = config(name)

    case Repo.get(conf, Tag, id) do
      nil ->
        {:error, "tag not found"}

      tag ->
        Repo.delete(conf, tag)
    end
  end

  @doc """
  Adds a tag to a media item.
  """
  def add_tag_to_media(media_id, tag_id) do
    add_tag_to_media(__MODULE__, media_id, tag_id)
  end

  def add_tag_to_media(name, media_id, tag_id) do
    conf = config(name)

    case {Repo.get(conf, Media, media_id), Repo.get(conf, Tag, tag_id)} do
      {nil, _} ->
        {:error, "media not found"}

      {_, nil} ->
        {:error, "tag not found"}

      {media, tag} ->
        Repo.insert(conf, Ecto.build_assoc(media, :tags, [tag]))
    end
  end

  @doc """
  Get all media items associated with a tag.
  """
  def get_media_by_tag(tag_id) do
    get_media_by_tag(__MODULE__, tag_id)
  end

  def get_media_by_tag(name, tag_id) do
    conf = config(name)

    query =
      from m in Media,
        join: t in assoc(m, :tags),
        where: t.id == ^tag_id

    Repo.all(conf, query)
  end

  defp media_path(name, media) do
    Path.join([config(name).base_path, "media", media.url])
  end
end
