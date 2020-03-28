defimpl JsonSerde.Serializer, for: Any do
  def serialize(term) do
    {:ok, term}
  end
end

defimpl JsonSerde.Deserializer, for: Any do
  def deserialize(_, term) do
    {:ok, term}
  end
end
