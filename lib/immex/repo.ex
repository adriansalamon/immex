defmodule Immex.Repo do
  @moduledoc """
  Wrapper around Ecto.Repo. Each function sets the correct repo instance
  and prefix according to `Immex.Config`.


  """

  # Note: This code is taken from/inspired by Oban.Repo, since they have the exact same use case/problem.

  alias Immex.Config

  @callbacks_without_opts [
    config: 0,
    default_options: 1,
    get_dynamic_repo: 0,
    in_transaction?: 0,
    load: 2,
    put_dynamic_repo: 1,
    rollback: 1
  ]

  @callbacks_with_opts [
    aggregate: 3,
    all: 2,
    checkout: 2,
    delete!: 2,
    delete: 2,
    delete_all: 2,
    exists?: 2,
    get!: 3,
    get: 3,
    get_by!: 3,
    get_by: 3,
    insert!: 2,
    insert: 2,
    insert_all: 3,
    insert_or_update!: 2,
    insert_or_update: 2,
    one!: 2,
    one: 2,
    preload: 3,
    reload!: 2,
    reload: 2,
    stream: 2,
    transaction: 2,
    update!: 2,
    update: 2,
    update_all: 3
  ]

  for {fun, arity} <- @callbacks_without_opts do
    args = [Macro.var(:conf, __MODULE__) | Macro.generate_arguments(arity, __MODULE__)]

    @doc """
    Wraps `c:Ecto.Repo.#{fun}/#{arity}` with an additional `Immex.Config` argument.
    """
    def unquote(fun)(unquote_splicing(args)) do
      __dispatch__(unquote(fun), unquote(args))
    end
  end

  for {fun, arity} <- @callbacks_with_opts do
    args = [Macro.var(:conf, __MODULE__) | Macro.generate_arguments(arity - 1, __MODULE__)]

    @doc """
    Wraps `c:Ecto.Repo.#{fun}/#{arity}` with an additional `Immex.Config` argument.
    """
    def unquote(fun)(unquote_splicing(args), opts \\ []) do
      __dispatch__(unquote(fun), unquote(args), opts)
    end
  end

  # Manually Defined

  def default_options(%Config{prefix: prefix}) do
    if prefix, do: [prefix: prefix], else: []
  end

  def query(conf, statement, params \\ [], opts \\ []) do
    __dispatch__(:query, [conf, statement, params], opts)
  end

  def query!(conf, statement, params \\ [], opts \\ []) do
    __dispatch__(:query!, [conf, statement, params], opts)
  end

  def to_sql(conf, kind, queryable) do
    query =
      queryable
      |> Ecto.Queryable.to_query()
      |> Map.put(:prefix, conf.prefix)

    conf.repo.to_sql(kind, query)
  end

  defp __dispatch__(name, [%Config{} = conf | args]) do
    apply_repo(conf, name, args)
  end

  defp __dispatch__(name, [%Config{} = conf | args], opts) when is_list(opts) do
    opts =
      conf
      |> default_options()
      |> Keyword.merge(opts)

    apply_repo(conf, name, args ++ [opts])
  end

  defp apply_repo(conf, name, args) do
    apply(conf.repo, name, args)
  end
end
