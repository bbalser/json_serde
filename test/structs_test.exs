defmodule JsonSerde.StructTests do
  use ExUnit.Case

  defmodule SimpleStruct do
    use JsonSerde, alias: "simple"

    defstruct [:name, :age, :birthdate]
  end

  defmodule StructWithNew do
    defstruct [:name, :age, :birthdate]

    def new(map) do
      struct(__MODULE__, Map.update!(map, :name, &String.upcase/1))
    end
  end

  defmodule StructWithExclusion do
    use JsonSerde, exclude: [:age]

    defstruct [:name, :age, :birthdate]
  end

  test "test with simple struct" do
    input = %SimpleStruct{name: "brian", age: 21, birthdate: Date.utc_today()}

    {:ok, serialized_value} = JsonSerde.serialize(input)

    iso = Date.to_iso8601(input.birthdate)

    assert Jason.decode!(serialized_value) == %{
               "__data_type__" => "simple",
               "name" => "brian",
               "age" => 21,
               "birthdate" => %{"__data_type__" => "date", "value" => iso}
             }

    assert {:ok, input} == JsonSerde.deserialize(serialized_value)
  end

  test "test with struct with new function" do
    input = %StructWithNew{name: "brian", age: 21, birthdate: Date.utc_today()}

    {:ok, serialized_value} = JsonSerde.serialize(input)

    iso = Date.to_iso8601(input.birthdate)

    assert Jason.decode!(serialized_value) == %{
      "__data_type__" => to_string(StructWithNew),
      "name" => "brian",
      "age" => 21,
      "birthdate" => %{"__data_type__" => "date", "value" => iso}
    }

    expected = Map.update!(input, :name, &String.upcase/1)

    assert {:ok, expected} == JsonSerde.deserialize(serialized_value)
  end

  test "will exclude any configured fields from serialized form" do
    input = %StructWithExclusion{name: "Fred", age: 56, birthdate: Date.utc_today()}

    {:ok, serialized_value} = JsonSerde.serialize(input)

    iso = Date.to_iso8601(input.birthdate)

    assert Jason.decode!(serialized_value) == %{
      "__data_type__" => to_string(StructWithExclusion),
      "name" => "Fred",
      "birthdate" => %{"__data_type__" => "date", "value" => iso}
    }
  end
end
