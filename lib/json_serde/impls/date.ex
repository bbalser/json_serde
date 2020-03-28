defimpl JsonSerde.Serializer, for: Date do
  require JsonSerde

  def serialize(date) do
    {:ok,
     %{
       JsonSerde.data_type_key() => JsonSerde.Alias.to_alias(Date),
       "value" => Date.to_iso8601(date)
     }}
  end
end

defimpl JsonSerde.Deserializer, for: Date do
  def deserialize(_, map) do
    Map.get(map, "value")
    |> Date.from_iso8601()
  end
end
