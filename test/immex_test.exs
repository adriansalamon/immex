defmodule ImmexTest do
  use ExUnit.Case, async: true
  doctest Immex

  @opts [repo: :test, backend: :test]

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
    defmodule MyImmex do
      use Immex, otp_app: :immex, repo: MyImmex.Repo
    end

    start_supervised!({MyImmex, []})

    assert %{name: MyImmex, repo: MyImmex.Repo} = MyImmex.config()
  end
end
