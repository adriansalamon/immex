defmodule Immex.Registry do
  @moduledoc """
  Local process storage fof Immex.
  """

  @doc false
  def child_spec(_args) do
    [keys: :unique, name: __MODULE__]
    |> Registry.child_spec()
    |> Supervisor.child_spec(id: __MODULE__)
  end

  @doc """
  Returns the config for a given Immex process.

  ## Examples

  Get the default instance config:

      iex> %Immex.Config{} = Immex.Registry.config(Immex)

  Get config for a named instance:

      iex> %Immex.Config{} = Immex.Registry.config(MyApp.Immex)

  """
  def config(name) do
    case lookup(name) do
      {_pid, config} ->
        config

      _ ->
        raise RuntimeError, """
        No Immex process named #{inspect(name)} is running and has no config.
        """
    end
  end

  @doc """
  Looks up a {pid, config} tuple for a given Immex process.

  ## Examples

  Get the default instance:

      iex> {_pid, %Immex.Config{}} = Immex.Registry.lookup(Immex)
  """

  @spec lookup(term()) :: {pid, %Immex.Config{}} | nil

  def lookup(name), do: Registry.lookup(__MODULE__, name) |> List.first()

  @doc """
  Builds a `via` tuple for a given Immex process.

  ## Examples

  Get the default instance:

      iex> {:via, Registry, {Immex.Registry, Immex, "hello"}} = Immex.Registry.via(Immex, "hello")

  Via a named instance:

      iex> {:via, Registry, {Immex.Registry, MyApp.Immex}} = Immex.Registry.via(MyApp.Immex)

  """
  @spec via(term(), term()) :: {:via, Registry, {__MODULE__, term()}}
  def via(name, value \\ nil)
  def via(name, nil), do: {:via, Registry, {__MODULE__, name}}
  def via(name, value), do: {:via, Registry, {__MODULE__, name, value}}
end
