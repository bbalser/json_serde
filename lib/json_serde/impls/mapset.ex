defimpl JsonSerde.Serializer, for: MapSet do
  require JsonSerde

  def serialize(mapset) do
    with list <- MapSet.to_list(mapset),
         {:ok, value} <- JsonSerde.Serializer.serialize(list) do
      {:ok,
       %{
         JsonSerde.data_type_key() => JsonSerde.Alias.to_alias(MapSet),
         "values" => value
       }}
    end
  end
end

defimpl JsonSerde.Deserializer, for: MapSet do
  def deserialize(_, map) do
    with values <- Map.get(map, "values"),
         {:ok, deserialized} <- JsonSerde.Deserializer.deserialize(values, values) do
      {:ok, MapSet.new(deserialized)}
    end
  end
end
