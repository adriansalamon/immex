defmodule Immex.MediaFixtures do
  alias Immex.Media
  alias Immex.Repo

  def media_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        name: "test.jpg",
        size: 1024,
        content_type: "image/jpeg",
        url: "https://example.com/test.jpg"
      })

    changeset =
      %Media{}
      |> Media.changeset(attrs)

    conf = Immex.config()
    {:ok, media} = Repo.insert(conf, changeset)

    media
  end
end
