defmodule Immex.Test.Repo do
  use Ecto.Repo, otp_app: :immex, adapter: Ecto.Adapters.Postgres
end

defmodule Immex.Test.UnboxedRepo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :immex,
    adapter: Ecto.Adapters.Postgres

  def init(_, _) do
    config = Immex.Test.Repo.config()

    {:ok, Keyword.delete(config, :pool)}
  end
end
