defmodule Demo.Repo.Migrations.AddImmex do
  use Ecto.Migration

  def up, do: Immex.Migration.up(prefix: "immex")

  def down, do: Immex.Migration.down(prefix: "immex")
end
