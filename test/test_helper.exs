Application.ensure_all_started(:postgrex)

Immex.Test.Repo.start_link()
Immex.Test.UnboxedRepo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Immex.Test.Repo, :manual)

ExUnit.start()

defmodule MyApp.Immex do
  use Immex, otp_app: :immex, repo: Immex.Test.Repo
end
