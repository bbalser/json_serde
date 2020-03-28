defmodule JsonSerdeTest do
  use ExUnit.Case

  import JsonSerde, only: [data_type_key: 0]

  test "simple map" do
    input = %{
      "one" => 1,
      "two" => 2,
      "date" => Date.utc_today()
    }

    iso = Date.to_iso8601(input["date"])

    {:ok, serialized_term} = JsonSerde.serialize(input)

    assert serialized_term ==
             Jason.encode!(%{
               "one" => 1,
               "two" => 2,
               "date" => %{"__data_type__" => "date", "value" => iso}
             })

    assert {:ok, input} == JsonSerde.deserialize(serialized_term)
  end

  test "date" do
    input = Date.utc_today()

    {:ok, serialized_term} = JsonSerde.serialize(input)

    assert serialized_term ==
             Jason.encode!(%{
               data_type_key() => "date",
               "value" => Date.to_iso8601(input)
             })

    assert {:ok, input} == JsonSerde.deserialize(serialized_term)
  end

  test "time" do
    input = Time.utc_now()

    {:ok, serialized_term} = JsonSerde.serialize(input)

    assert serialized_term ==
             Jason.encode!(%{
               data_type_key() => "time",
               "value" => Time.to_iso8601(input)
             })

    assert {:ok, input} == JsonSerde.deserialize(serialized_term)
  end

  test "datetime" do
    input = DateTime.utc_now()

    {:ok, serialized_term} = JsonSerde.serialize(input)

    assert serialized_term ==
             Jason.encode!(%{
               data_type_key() => "date_time",
               "value" => DateTime.to_iso8601(input)
             })

    assert {:ok, input} == JsonSerde.deserialize(serialized_term)
  end

  test "naivedatetime" do
    input = NaiveDateTime.utc_now()

    {:ok, serialized_term} = JsonSerde.serialize(input)

    assert serialized_term ==
             Jason.encode!(%{
               data_type_key() => "naive_date_time",
               "value" => NaiveDateTime.to_iso8601(input)
             })

    assert {:ok, input} == JsonSerde.deserialize(serialized_term)
  end

  test "list" do
    input = [1, 2, Date.utc_today(), 4]

    {:ok, serialized_term} = JsonSerde.serialize(input)

    assert serialized_term ==
             Jason.encode!([
               1,
               2,
               %{
                 "__data_type__" => "date",
                 "value" => Date.utc_today() |> Date.to_iso8601()
               },
               4
             ])

    assert {:ok, input} == JsonSerde.deserialize(serialized_term)
  end

  test "mapset" do
    input = MapSet.new([1, 2, Date.utc_today(), 4])

    {:ok, serialized_term} = JsonSerde.serialize(input)

    {:ok, values} = JsonSerde.Serializer.serialize(MapSet.to_list(input))

    assert serialized_term ==
             Jason.encode!(%{
               "__data_type__" => "map_set",
               "values" => values
             })

    assert {:ok, input} == JsonSerde.deserialize(serialized_term)
  end

  test "keyword list" do
    input = [localhost: 9092, option: "value"]

    {:ok, serialized_term} = JsonSerde.serialize(input)

    assert serialized_term ==
             Jason.encode!(%{
               data_type_key() => "keyword_list",
               "values" => [["localhost", 9092], ["option", "value"]]
             })

    assert {:ok, input} == JsonSerde.deserialize(serialized_term)
  end
end
