defmodule ImmexTest do
  use Immex.Case, async: true
  doctest Immex

  @opts [repo: Repo, prefix: "private", writer: Immex.Test.DummyWriter]

  describe "child_spec/1" do
    test "name is used as a default child id" do
      assert Supervisor.child_spec(Immex, []).id == Immex
    end
  end

  describe "start_link/1" do
    test "name can be an arbitrary term" do
      opts = Keyword.put(@opts, :name, make_ref())

      assert {:ok, _} = start_supervised({Immex, opts})
    end

    test "name must be unique" do
      name = make_ref()
      opts = Keyword.put(@opts, :name, name)

      {:ok, pid} = Immex.start_link(opts)
      {:error, {:already_started, ^pid}} = Immex.start_link(opts)
    end
  end

  test "config/0 of a facade instance" do
    start_supervised!({MyApp.Immex, []})

    assert %{name: MyApp.Immex, repo: Immex.Test.Repo} = MyApp.Immex.config()
  end

  describe "put_media/2" do
    defmacrop consume_fn(url) do
      quote do
        fn func ->
          result = func.(%{url: unquote(url)})

          case result do
            {:ok, return} ->
              {:ref, return}

            {:postpone, return} ->
              {:postpone, return}
          end
        end
      end
    end

    test "inserts a media entry" do
      start_supervised!({Immex, @opts})

      attrs = %{name: "avatar", content_type: "image/jpeg"}

      {:ok, media} = Immex.put(attrs, consume_fn("success"))

      assert %Immex.Media{} = media
      assert Repo.all(Immex.Media, prefix: "private") == [media]
    end

    test "returns an error if the media entry is invalid" do
      start_supervised!({Immex, @opts})

      attrs = %{name: "avatar"}

      assert {:error, changeset} = Immex.put(attrs, consume_fn("success"))

      assert changeset.errors == [
               {:content_type, {"unsupported content type", []}},
               {:content_type, {"can't be blank", [validation: :required]}}
             ]

      assert Repo.all(Immex.Media, prefix: "private") == []
    end

    test "returns an error if the consume function fails" do
      start_supervised!({Immex, @opts})

      attrs = %{name: "avatar", content_type: "image/jpeg"}

      # The dummy writer will error when the url is "error"
      assert {:error, "failed to consume uploaded entry"} = Immex.put(attrs, consume_fn("error"))
      assert Repo.all(Immex.Media, prefix: "private") == []
    end
  end
end
