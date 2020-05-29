# JsonSerde

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


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `json_serde` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:json_serde, "~> 1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/json_serde](https://hexdocs.pm/json_serde).

