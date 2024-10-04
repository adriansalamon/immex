defmodule Immex do
  @moduledoc """
  Documentation for `Immex`.
  """

  use Supervisor
  alias Immex.{Config, Registry}

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
        |> dbg()
      end

      def config do
        Immex.config(__MODULE__)
      end
    end
  end

  def start_link(opts) do
    conf = Config.new(opts)

    Supervisor.start_link(__MODULE__, conf, name: Registry.via(conf.name, conf))
  end

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

  def config(name \\ __MODULE__), do: Registry.config(name)
end
