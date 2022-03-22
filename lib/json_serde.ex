defmodule JsonSerde do
  @moduledoc """
  A Json Serialization/Deserialization library that aims to create json documents from any
  nested data structures and deserialize json documents back to same datastructure.

  ```elixir
  iex(1)> map = %{"name" => "Joe", "age" => 21, "birthdate" => Date.new(1970, 1, 1) |> elem(1)}
  %{"age" => 21, "birthdate" => ~D[1970-01-01], "name" => "Joe"}

  iex(2)> {:ok, serialized} = JsonSerde.serialize(map)
  {:ok,
  "{\"age\":21,\"birthdate\":{\"__data_type__\":\"date\",\"value\":\"1970-01-01\"},\"name\":\"Joe\"}"}

  iex(3)> JsonSerde.deserialize(serialized)
  {:ok, %{"age" => 21, "birthdate" => ~D[1970-01-01], "name" => "Joe"}}
  ```

  Custom structs can be marked with an alias, so resulting json does not appear elixir specific
  ```elixir
  iex(2)> defmodule CustomStruct do
  ...(2)> use JsonSerde, alias: "custom"
  ...(2)> defstruct [:name, :age]
  ...(2)> end
  {:module, CustomStruct,
  <<70, 79, 82, 49, 0, 0, 5, 240, 66, 69, 65, 77, 65, 116, 85, 56, 0, 0, 0, 189,
    0, 0, 0, 18, 19, 69, 108, 105, 120, 105, 114, 46, 67, 117, 115, 116, 111,
    109, 83, 116, 114, 117, 99, 116, 8, 95, 95, ...>>,
  %CustomStruct{age: nil, name: nil}}

  iex(3)> c = %CustomStruct{name: "eddie", age: 34}
  %CustomStruct{age: 34, name: "eddie"}

  iex(4)> {:ok, serialized} = JsonSerde.serialize(c)
  {:ok, "{\"age\":34,\"name\":\"eddie\",\"__data_type__\":\"custom\"}"}

  iex(5)> JsonSerde.deserialize(serialized)
  {:ok, %CustomStruct{age: 34, name: "eddie"}}
  ```

  ### Supported Types
    * Map
    * List
    * MapSet
    * Tuple
    * Atom
    * Date
    * DateTime
    * NaiveDateTime
    * Time
    * Custom Structs

  ### Custom Structs

  The type key included in all structs is defaulted to "__data_type__" but can be customized by:

      config :json_serde, :type_key, "type"

  * Note: This configuration is only read at compile time

  """
  @typedoc "A Json representation of the given term"
  @type serialized_term :: String.t()

  defmacro __using__(opts) do
    alias = Keyword.get(opts, :alias)
    exclusions = Keyword.get(opts, :exclude, [])
    construct = Keyword.get(opts, :construct, nil)
    module = __CALLER__.module

    JsonSerde.Alias.setup_alias(module, alias)

    quote do
      def __json_serde_exclusions__() do
        unquote(exclusions)
      end

      def __json_serde_construct__() do
        unquote(construct)
      end
    end
  end

  defmacro data_type_key() do
    data_key = Application.get_env(:json_serde, :type_key, "__data_type__")

    quote do
      unquote(data_key)
    end
  end

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
