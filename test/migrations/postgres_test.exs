defmodule Immex.Migrations.PostgresTest do
  use Immex.Case, async: true

  @base_version 20_300_000_000_000

  defmodule DefaultMigration do
    use Ecto.Migration

    def up do
      Immex.Migration.up(prefix: "migrating")
    end

    def down do
      Immex.Migration.down(prefix: "migrating")
    end
  end

  test "migrate up works" do
    Ecto.Migrator.up(UnboxedRepo, @base_version, DefaultMigration)
  after
    clear_migrated()
  end

  test "migrate down works" do
    Ecto.Migrator.up(UnboxedRepo, @base_version, DefaultMigration)
    Ecto.Migrator.down(UnboxedRepo, @base_version, DefaultMigration)
  after
    clear_migrated()
  end

  defp clear_migrated do
    UnboxedRepo.query("DELETE FROM schema_migrations WHERE version >= #{@base_version}")
    UnboxedRepo.query("DROP SCHEMA IF EXISTS migrating CASCADE")
  end
end
