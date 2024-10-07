defmodule Immex do
  @moduledoc """
  Documentation for `Immex`, a media management library.
  """

  use Supervisor
  alias Immex.Media
  alias Immex.{Config, Registry, Repo}

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

      def upload(file, file_name, content_type) do
        Immex.upload(__MODULE__, file, file_name, content_type)
      end

      def put(attrs, consume_fn) do
        Immex.put(__MODULE__, attrs, consume_fn)
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

  def upload(file, file_name, content_type) do
    upload(__MODULE__, file, file_name, content_type)
  end

  # Proof of concept: Maybe something like this?
  def upload(name, _file, file_name, content_type) do
    conf =
      config(name)

    with {:ok, _file} <- {:ok, "test"},
         changeset <-
           Media.changeset(%Media{}, %{
             name: file_name,
             size: 0,
             content_type: content_type,
             url: "http://example.com"
           }),
         {:ok, media} <- Repo.insert(conf, changeset, prefix: conf.prefix) do
      {:ok, media}
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

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
        consume_fn.(fn %{url: tmp_path} ->
          path = media_path(name, media)
          File.mkdir_p!(Path.dirname(path))
          File.copy!(tmp_path, path)
          {:ok, media}
        end)

        {:ok, media}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp media_path(name, media) do
    Path.join([config(name).base_path, "media", media.url])
  end
end
