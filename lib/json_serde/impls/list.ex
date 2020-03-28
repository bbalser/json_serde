defimpl JsonSerde.Serializer, for: List do
  alias JsonSerde.Ok

  def serialize(list) do
    Ok.transform(list, &JsonSerde.Serializer.serialize/1)
  end
end

defimpl JsonSerde.Deserializer, for: List do
  alias JsonSerde.Ok

  def deserialize(_, list) do
    Ok.transform(list, &JsonSerde.Deserializer.deserialize(&1, &1))
  end
end
