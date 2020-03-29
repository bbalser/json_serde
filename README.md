# JsonSerde

A Json Serializatin/Deserialization library that aims to create json documents from any
nested data structures and deserialize json documents back to same datastructure.

```elixir
iex(1)> map = %{"name" => "Joe", "age" => 21, "birthdate" => Date.new(1970, 1, 1) |> elem(1)}
%{"age" => 21, "birthdate" => ~D[1970-01-01], "name" => "Joe"}
iex(2)> {:ok, serialized} = JsonSerde.serialize(map)
{:ok,
 "{\"age\":21,\"birthdate\":{\"__data_type__\":\"date\",\"value\":\"1970-01-01\"},\"name\":\"Joe\"}"}
iex(3)> JsonSerde.deserialize(serialized)
{:ok, %{"age" => 21, "birthdate" => ~D[1970-01-01], "name" => "Joe"}}
iex(4)> 
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `json_serde` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:json_serde, "~> 0.1"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/json_serde](https://hexdocs.pm/json_serde).

