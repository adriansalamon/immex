defmodule Immex.Migrations.Postgres do
  @moduledoc false

  use Ecto.Migration

  @default_prefix "public"

  def up(opts) do
    prefix = Keyword.get(opts, :prefix, @default_prefix)

    execute "CREATE SCHEMA IF NOT EXISTS #{prefix}"

    create table(:media, prefix: prefix) do
      add :name, :string
      add :size, :integer
      add :content_type, :string
      add :url, :string

      add :owner_id, :integer

      timestamps()
    end

    create index(:media, [:owner_id], prefix: prefix)

    create table(:metadata, prefix: prefix) do
      add :key, :string
      add :value, :string

      add :media_id, references(:media, prefix: prefix)

      timestamps()
    end

    create unique_index(:metadata, [:key, :media_id], prefix: prefix)
    create index(:metadata, [:media_id], prefix: prefix)

    create table(:tags, prefix: prefix) do
      add :name, :string
      add :slug, :string

      add :parent_id, references(:tags, prefix: prefix)

      timestamps()
    end

    create index(:tags, [:parent_id], prefix: prefix)

    create table(:media_tags, prefix: prefix) do
      add :media_id, references(:media, prefix: prefix)
      add :tag_id, references(:tags, prefix: prefix)

      timestamps()
    end

    create index(:media_tags, [:media_id], prefix: prefix)
    create index(:media_tags, [:tag_id], prefix: prefix)
  end

  def down(opts) do
    prefix = Keyword.get(opts, :prefix)

    drop table(:media_tags, prefix: prefix)
    drop table(:metadata, prefix: prefix)
    drop table(:tags, prefix: prefix)
    drop table(:media, prefix: prefix)

    if prefix do
      execute "DROP SCHEMA IF EXISTS #{prefix} CASCADE"
    end
  end
end
