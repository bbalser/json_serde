defimpl JsonSerde.Serializer, for: List do
  require JsonSerde
  import Brex.Result.Mappers

  def serialize(list) do
    map_while_success(list, &JsonSerde.Serializer.serialize/1)
  end
end

defimpl JsonSerde.Deserializer, for: List do
  import Brex.Result.Mappers

  def deserialize(_, list) do
    map_while_success(list, &JsonSerde.Deserializer.deserialize(&1, &1))
  end
end
