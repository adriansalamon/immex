defmodule Immex.RegistryTest do
  use Immex.Case

  @opts [repo: Repo, prefix: "private"]

  setup do
    start_supervised!({MyApp.Immex, []})
    start_supervised!({Immex, @opts})

    :ok
  end

  doctest Immex.Registry
end
