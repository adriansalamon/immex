defmodule Immex.Case do
  @moduledoc false

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox
  alias Immex.Test.{Repo, UnboxedRepo}

  using do
    quote do
      import Immex.Case

      alias Immex.Test.Repo
      alias Immex.Test.{Repo, UnboxedRepo}
    end
  end

  setup context do
    pid = Sandbox.start_owner!(Repo, shared: not context[:async])
    on_exit(fn -> Sandbox.stop_owner(pid) end)
  end
end
