defmodule JsonSerde do
  @typedoc "A Json representation of the given term"
  @type serialized_term :: String.t()

  defmacro __using__(opts) do
    alias = Keyword.fetch!(opts, :alias)
    module = __CALLER__.module
    module_contents = quote do
      def alias() do
        unquote(alias)
      end
    end

    name = Module.concat(JsonSerde.Custom.Modules, module)
    Module.create(name, module_contents, Macro.Env.location(__ENV__))

    alias_contents = quote do
      def module() do
        unquote(module)
      end
    end

    name = Module.concat(JsonSerde.Custom.Aliases, alias)
    Module.create(name, alias_contents, Macro.Env.location(__ENV__))

    quote do
      :ok
    end
  end

  defmacro data_type_key(), do: quote do: "__data_type__"

  @spec serialize(term) :: {:ok, serialized_term()} | {:error, term}
  def serialize(term) do
    with {:ok, output} <- JsonSerde.Serializer.serialize(term) do
      Jason.encode(output)
    end
  end

  @spec serialize!(term) :: serialized_term()
  def serialize!(term) do
    case serialize(term) do
      {:ok, value} -> value
      {:error, reason} -> raise reason
    end
  end

  @spec deserialize(serialized_term()) :: {:ok, term} | {:error, term}
  def deserialize(serialized_term) when is_binary(serialized_term) do
    with {:ok, decoded} <- Jason.decode(serialized_term) do
      JsonSerde.Deserializer.deserialize(decoded, decoded)
    end
  end

  @spec deserialize!(serialized_term()) :: term
  def deserialize!(serialized_term) do
    case deserialize(serialized_term) do
      {:ok, value} -> value
      {:error, reason} -> raise reason
    end
  end
end

defprotocol JsonSerde.Serializer do
  @fallback_to_any true
  @spec serialize(t) :: {:ok, map | list | binary | integer | float} | {:error, term}
  def serialize(t)
end

defprotocol JsonSerde.Deserializer do
  @fallback_to_any true
  @spec deserialize(t, map | list | binary | integer | float) :: {:ok, term} | {:error, term}
  def deserialize(t, serialized_term)
end
