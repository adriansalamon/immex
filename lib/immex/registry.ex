defmodule Immex.Registry do
  def child_spec(_args) do
    [keys: :unique, name: __MODULE__]
    |> Registry.child_spec()
    |> Supervisor.child_spec(id: __MODULE__)
  end

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

  def lookup(name), do: Registry.lookup(__MODULE__, name) |> List.first()

  def via(name, value), do: {:via, Registry, {__MODULE__, name, value}}
end
