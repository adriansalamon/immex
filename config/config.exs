import Config

config :logger, level: :warning

config :immex, Immex.Test.Repo,
  migration_lock: false,
  name: Immex.Test.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 2 * System.schedulers_online(),
  priv: "test/support/postgres",
  url: System.get_env("DATABASE_URL") || "ecto://postgres:postgres@localhost/immex_test"

config :immex,
  ecto_repos: [Immex.Test.Repo]
