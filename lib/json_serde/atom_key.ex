defmodule JsonSerde.AtomKey do
  @moduledoc """
  Handles encoding and decoding atom keys to support serializing and deserializing maps with atom keys.

  This would be a breaking change, so it is disabled by default.
  To enable it, add the following to your config.exs:

      config :json_serde, :encode_atom_keys, true
  """

  @atom_key "__is_atom__"
  @key_length String.length(@atom_key) + 1

  @doc """
  Encodes a key if it an atom, otherwise returns the key unaltered.

  If the key is an atom, it will be converted to a string and appended with "#{@atom_key}".

  Examples:

      iex> JsonSerde.AtomKey.encode(:foo)
      "foo__is_atom__"

      iex> JsonSerde.AtomKey.encode("foo")
      "foo"

  Note: Encoding atom keys is disabled by defualt and must be enabled in your config.exs.
  """
  @spec encode(key :: any(), boolean()) :: any()
  def encode(key, is_struct) do
    if enabled?() && !is_struct && is_atom(key) do
      key
      |> Atom.to_string()
      |> Kernel.<>(@atom_key)
    else
      key
    end
  end

  @doc """
  Decodes a key if it ends with "__is_atom__", otherwise returns the key unaltered.

  If the key ends with "__is_atom__", it will be converted to an atom.

  Examples:

      iex> JsonSerde.AtomKey.decode("foo__is_atom__")
      :foo

      iex> JsonSerde.AtomKey.decode("foo")
      "foo"

    Note: Decoding atom keys is disabled by defualt and must be enabled in your config.exs.
  """
  def decode(key) do
    if enabled?() && String.ends_with?(key, @atom_key) do
      key
      |> String.slice(0..-@key_length//1)
      |> String.to_atom()
    else
      key
    end
  end

  defp enabled? do
    Application.get_env(:json_serde, :encode_atom_keys, false)
  end
end
