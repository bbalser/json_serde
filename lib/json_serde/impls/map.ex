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

  def deserialize(_, %{data_type_key() => "keyword_list"} = map) do
    Map.get(map, "values")
    |> Ok.transform(fn [key, value] ->
      with {:ok, term} <- JsonSerde.Deserializer.deserialize(value, value) do
        {:ok, {String.to_atom(key), term}}
      end
    end)
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
