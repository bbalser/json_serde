defmodule AtomKeysTest do
  use ExUnit.Case

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
end
