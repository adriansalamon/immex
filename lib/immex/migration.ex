defmodule Immex.Migration do
  @moduledoc """
  Migrations create and modify database tables that Immex needs and uses.

  ## Usage

  To use Immex in your application, you need to run the migrations. You
  should generate a migration file in your application that calls
  `Immex.Migration`.

  ```bash
  mix ecto.gen.migration add_immex
  ```

  Then, in the generated migration file, add calls to `Immex.Migration`:

  ```elixir
  defmodule MyApp.Repo.Migrations.AddImmex do
    use Ecto.Migration

    def up, do: Immex.Migration.up()

    def down, do: Immex.Migration.down()
  end
  ```

  This will run all the migrations that Immex needs to set up the database. You
  can then run the migrations with:

  ```bash
  mix ecto.migrate
  ```

  TODO: Add support for versioning migrations between releases.

  ## Prefixing

  Immex supports prefixing tables with a schema. This is useful for
  isolating tables under different namespaces in the database.

  To use a prefix, you need to pass it when creating your migrations:

  ```elixir
  defmodule MyApp.Repo.Migrations.AddImmex do
    use Ecto.Migration

    def up, do: Immex.Migration.up(prefix: "my_prefix")

    def down, do: Immex.Migration.down(prefix: "my_prefix")
  end
  ```

  This will create all Immex tables under the `my_prefix` schema. You
  will then need to configure Immex to use the same prefix in your
  configuration.

  ```elixir
  config :my_app, Immex,
    repo: MyApp.Repo,
    prefix: "my_prefix"
  ```

  """
  use Ecto.Migration

  @doc """
  Migrates the database to the latest version.
  """
  @spec up(Keyword.t()) :: :ok
  def up(opts \\ []) do
    migrator().up(opts)
  end

  @doc """
  Rolls back the database to the previous version.
  """
  @spec down(Keyword.t()) :: :ok

  def down(opts \\ []) do
    migrator().down(opts)
  end

  defp migrator do
    case repo().__adapter__() do
      Ecto.Adapters.Postgres -> Immex.Migrations.Postgres
      _ -> raise "Unsupported adapter"
    end
  end
end
