defmodule AtomKeysTest do
  use ExUnit.Case

  defmodule AtomSimpleStruct do
    use JsonSerde, alias: "atom_simple"

    defstruct [:name, :age, :birthdate]
  end

  defmodule AtomNestedStruct do
    use JsonSerde, alias: "atom_nested"

    defstruct [:tag, :simple]
  end

  setup do
    Application.put_env(:json_serde, :encode_atom_keys, true)
    :ok
  end

  test "map with mixed keys" do
    input = %{
      "a" => "1",
      b: 2
    }

    {:ok, serialized_term} = JsonSerde.serialize(input)

    assert serialized_term ==
             Jason.encode!(%{
               "a" => "1",
               "b__is_atom__" => 2
             })

    assert {:ok, input} == JsonSerde.deserialize(serialized_term)
  end

  test "nested map with mixed keys" do
    input = %{
      "a" => "1",
      b: 2,
      c: %{
        "d" => "3",
        e: 4
      }
    }

    {:ok, serialized_term} = JsonSerde.serialize(input)

    assert serialized_term ==
             Jason.encode!(%{
               "a" => "1",
               "b__is_atom__" => 2,
               "c__is_atom__" => %{
                 "d" => "3",
                 "e__is_atom__" => 4
               }
             })

    assert {:ok, input} == JsonSerde.deserialize(serialized_term)
  end

  describe "do not atomize structs" do
    test "test with nested struct" do
      input = %AtomNestedStruct{
        tag: "dev",
        simple: %AtomSimpleStruct{name: "brian", age: 21, birthdate: Date.utc_today()}
      }

      {:ok, serialized_value} = JsonSerde.serialize(input)

      assert {:ok, input} == JsonSerde.deserialize(serialized_value)
    end

    test "test with simple struct" do
      input = %AtomSimpleStruct{name: "brian", age: 21, birthdate: Date.utc_today()}

      {:ok, serialized_value} = JsonSerde.serialize(input)

      iso = Date.to_iso8601(input.birthdate)

      assert Jason.decode!(serialized_value) == %{
               "__data_type__" => "atom_simple",
               "name" => "brian",
               "age" => 21,
               "birthdate" => %{"__data_type__" => "date", "value" => iso}
             }

      assert {:ok, input} == JsonSerde.deserialize(serialized_value)
    end
  end
end
