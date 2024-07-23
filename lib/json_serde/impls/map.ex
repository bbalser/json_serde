defimpl JsonSerde.Serializer, for: Map do
  import Brex.Result.Base, only: [fmap: 2]
  import Brex.Result.Mappers

  require JsonSerde

  def serialize(map) do
    is_struct = Map.has_key?(map, JsonSerde.data_type_key())

    map
    |> map_while_success(fn {key, value} ->
      k = JsonSerde.AtomKey.encode(key, is_struct)

      JsonSerde.Serializer.serialize(value)
      |> fmap(fn v -> {k, v} end)
    end)
    |> fmap(&Map.new/1)
  end
end

defimpl JsonSerde.Deserializer, for: Map do
  import JsonSerde, only: [data_type_key: 0]
  import Brex.Result.Base, only: [ok: 1, fmap: 2]
  import Brex.Result.Mappers

  def deserialize(_, %{data_type_key() => "atom"} = map) do
    Map.get(map, "value")
    |> String.to_atom()
    |> ok()
  end

  def deserialize(_, %{data_type_key() => "tuple"} = map) do
    with values <- Map.get(map, "values"),
         {:ok, deserialized} <- JsonSerde.Deserializer.deserialize(values, values),
         tuple <- List.to_tuple(deserialized) do
      ok(tuple)
    end
  end

  def deserialize(_, %{data_type_key() => alias} = map) do
    struct = JsonSerde.Alias.from_alias(alias) |> struct()
    JsonSerde.Deserializer.deserialize(struct, map)
  end

  def deserialize(_, map) do
    map
    |> map_while_success(fn {key, value} ->
      k = JsonSerde.AtomKey.decode(key)

      JsonSerde.Deserializer.deserialize(value, value)
      |> fmap(fn v -> {k, v} end)
    end)
    |> fmap(&Map.new/1)
  end
end
