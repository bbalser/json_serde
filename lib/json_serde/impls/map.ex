defimpl JsonSerde.Serializer, for: Map do
  alias JsonSerde.Ok

  def serialize(map) do
    map
    |> Ok.transform(fn {key, value} ->
      JsonSerde.Serializer.serialize(value)
      |> Ok.map(fn v -> {key, v} end)
    end)
    |> Ok.map(&Map.new/1)
  end
end

defimpl JsonSerde.Deserializer, for: Map do
  import JsonSerde, only: [data_type_key: 0]
  alias JsonSerde.Ok

  def deserialize(_, %{data_type_key() => "atom"} = map) do
    Map.get(map, "value")
    |> String.to_atom()
    |> Ok.ok()
  end

  def deserialize(_, %{data_type_key() => "tuple"} = map) do
    with values <- Map.get(map, "values"),
         {:ok, deserialized} <- JsonSerde.Deserializer.deserialize(values, values),
         tuple <- List.to_tuple(deserialized) do
      {:ok, tuple}
    end
  end

  def deserialize(_, %{data_type_key() => alias} = map) do
    struct = JsonSerde.Alias.from_alias(alias) |> struct()
    JsonSerde.Deserializer.deserialize(struct, map)
  end

  def deserialize(_, map) do
    map
    |> Ok.transform(fn {key, value} ->
      JsonSerde.Deserializer.deserialize(value, value)
      |> Ok.map(fn v -> {key, v} end)
    end)
    |> Ok.map(&Map.new/1)
  end
end
