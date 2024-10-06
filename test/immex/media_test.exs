defmodule Immex.MediaTest do
  alias Immex.Media
  alias Immex.MediaFixtures

  use Immex.Case

  setup do
    start_supervised!({Immex, [repo: Immex.Test.Repo, prefix: "private"]})

    :ok
  end

  test "changeset/2 with valid attributes" do
    media = MediaFixtures.media_fixture()

    assert %Media{} = media
  end
end
