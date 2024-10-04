# Immex

A "simple" Elixir library for managing image libraries. In the future,
it might have support for multiple storage backends, but for now it
only support S3 compatible object storage.

It will also need persistent storage for metadata and indexing, and
will be implemented using Ecto, with initial support for PostgreSQL
and maybe SQLite.

## Goals

- [ ] It should be possible to upload images, in a variety of formats
- [ ] It should be possible to download images, and to generate
      presigned URLs
- [ ] It should be possible to delete images
- [ ] It should be possible to list images
- [ ] It should be possible to sync the image library with the storage
      backend and recover from inconsistencies
- [ ] It should be possible to generate image variants, ie. transcode
      images

Further down the line:

- [ ] It should be possible organize images in collections
- [ ] It should be possible to tag images
- [ ] It should be possible to search images by tags, metadata and
      collections

Maybemaybemaybe:

- [ ] It should be possible to generate image variants on the fly
- [ ] It can use an ML model (eg. CLIP) to generate image descriptions
      and metadata

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be
installed by adding `immex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:immex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with
[ExDoc](https://github.com/elixir-lang/ex_doc) and published on
[HexDocs](https://hexdocs.pm). Once published, the docs can be found
at <https://hexdocs.pm/immex>.
