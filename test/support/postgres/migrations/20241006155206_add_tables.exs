defmodule Immex.Test.Repo.Migrations.AddTables do
  use Ecto.Migration

  def up do
    Immex.Migration.up(prefix: "private")
  end

  def down do
    Immex.Migration.down(prefix: "private")
  end
end
